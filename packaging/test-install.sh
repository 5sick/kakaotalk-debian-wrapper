#!/bin/sh
# 깨끗한 배포판 컨테이너에 .deb를 설치하고 동봉 Wine이 실제로 동작하는지 확인한다.
# SPDX-License-Identifier: MIT
#
# 사용법: packaging/test-install.sh [이미지...]   (기본: debian:12 ubuntu:22.04 ubuntu:24.04)
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEB="$(ls -t "$ROOT"/dist/*.deb | head -1)"
[ $# -gt 0 ] || set -- debian:12 ubuntu:22.04 ubuntu:24.04

for image in "$@"; do
    echo "=== $image"
    docker run --rm -v "$DEB:/tmp/pkg.deb:ro" "$image" sh -ec '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y -qq /tmp/pkg.deb >/tmp/apt.log 2>&1 || { tail -20 /tmp/apt.log; exit 1; }
        W=/opt/kakaotalk-debian-wrapper/wine/bin
        $W/wine --version
        # 동봉 Wine이 dlopen하는 라이브러리가 모두 설치됐는지
        for so in libfreetype.so.6 libfontconfig.so.1 libGL.so.1 libEGL.so.1 libvulkan.so.1 \
                  libgnutls.so.30 libdbus-1.so.3 libXrandr.so.2 libXi.so.6 libXcursor.so.1 \
                  libXcomposite.so.1 libXinerama.so.1 libXrender.so.1 libXfixes.so.3 libXxf86vm.so.1; do
            ldconfig -p | grep -q "$so" || echo "MISSING: $so"
        done
        # prefix 생성과 64비트/32비트(wow64) 프로그램 실행
        export WINEPREFIX=/tmp/prefix WINEDEBUG=-all
        $W/wineboot -i >/dev/null 2>&1
        $W/wine cmd /c ver | tr -d "\r" | grep -v "^$"
        $W/wine C:/windows/syswow64/cmd.exe /c echo wow64-ok | tr -d "\r"
        kakaotalk --help | head -1
    '
done
