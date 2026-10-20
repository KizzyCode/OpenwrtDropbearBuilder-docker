# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        file \
        g++ \
        gawk \
        git \
        libncurses-dev \
        make \
        patch \
        python3 \
        rsync \
        unzip \
        wget \
        zstd

RUN useradd --create-home --shell /bin/bash builder
USER builder
WORKDIR /home/builder

ARG OPENWRT_SDK_URL
ARG OPENWRT_SDK_SHA256
ADD --checksum=sha256:${OPENWRT_SDK_SHA256} --chown=builder:builder ${OPENWRT_SDK_URL} sdk.tar
RUN tar -xf sdk.tar --strip-components=1 && rm sdk.tar

# The SDK pins the base feed to the source revision used for this release.
RUN ./scripts/feeds update base \
    && ./scripts/feeds install -p base dropbear

COPY --chown=builder:builder <<'CONFIG' .config
# CONFIG_ALL is not set
# CONFIG_ALL_KMODS is not set
# CONFIG_ALL_NONSHARED is not set
CONFIG_PACKAGE_dropbear=y
CONFIG_DROPBEAR_ECDSA=y
CONFIG_DROPBEAR_ECC_256=y
CONFIG

RUN make defconfig \
    && grep -Fx 'CONFIG_DROPBEAR_ECDSA=y' .config \
    && grep -Fx 'CONFIG_DROPBEAR_ECC_256=y' .config
RUN make -j"$(nproc)" package/dropbear/compile V=s


FROM scratch
COPY --from=build /home/builder/bin/targets/*/*/packages/dropbear-*.apk /
