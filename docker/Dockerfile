# Wine 빌드 환경. 지원 대상 중 glibc가 가장 오래된 Ubuntu 22.04(2.35)에서 빌드해야
# Debian 12(2.36), Ubuntu 24.04(2.39) 등 이후 배포판에서도 그대로 실행된다.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential flex bison curl ca-certificates xz-utils patch file \
        mingw-w64 gcc-multilib \
        libx11-dev libxext-dev libxrandr-dev libxi-dev libxcursor-dev \
        libxcomposite-dev libxinerama-dev libxfixes-dev libxrender-dev libxxf86vm-dev \
        libfreetype-dev libfontconfig-dev \
        libgl-dev libegl-dev libvulkan-dev \
        libasound2-dev libpulse-dev \
        libdbus-1-dev libgnutls28-dev \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libwayland-dev wayland-protocols libxkbcommon-dev \
        libunwind-dev libudev-dev libusb-1.0-0-dev libsdl2-dev \
    && rm -rf /var/lib/apt/lists/*
