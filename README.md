# OpenWrt Dropbear with ECDSA/P-256

This Dockerfile builds a Dropbear APK with `ecdsa-sha2-nistp256` client authentication.
Default target: OpenWrt 25.12.6, `lantiq/xrx200` (FRITZ!Box 7430).

Set `OPENWRT_SDK_URL` to the matching Linux x86_64 SDK and pin `OPENWRT_SDK_SHA256` in the
[workflow](.github/workflows/dropbear-25.12.6-lantiq-xrx200.yml). Run it manually and download the `dropbear-apk` artifact.

## Example

```sh
docker build \
  --build-arg OPENWRT_SDK_URL=https://downloads.openwrt.org/releases/25.12.6/targets/lantiq/xrx200/openwrt-sdk-25.12.6-lantiq-xrx200_gcc-14.3.0_musl.Linux-x86_64.tar.zst \
  --build-arg OPENWRT_SDK_SHA256=871781bcaa1ea2fe1d3c47d80628a29983121d8682556e9aa7c8e5874b793f21 \
  --output type=local,dest=artifacts .
```

The APK is unsigned, so installation requires `--allow-untrusted`, which stock LuCI's package uploader does not support. After transfer to the router, installation is possible over SSH with `apk add --allow-untrusted ./dropbear-2025.89-r3.apk`, using the actual artifact filename.
