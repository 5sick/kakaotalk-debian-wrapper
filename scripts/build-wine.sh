#!/bin/sh
# Wine을 소스에서 wow64 모드(i386 패키지 불필요)로 빌드하고 patches/*.patch를 적용한다.
# SPDX-License-Identifier: MIT
#
# 사용법: scripts/build-wine.sh [버전]        (기본: 11.0)
#   FLAVOR=release  디버그 정보 없이 빌드 (패키지용, 기본)
#   FLAVOR=debug    디버그 정보 포함 (크래시 분석용)
#
# 배포용 바이너리는 여러 배포판에서 돌아가도록 scripts/build-wine-docker.sh로
# 오래된 glibc 환경(Ubuntu 22.04)에서 빌드해야 한다.
set -eu

VERSION="${1:-11.0}"
FLAVOR="${FLAVOR:-release}"
case "$VERSION" in
    *.0) SERIES="$VERSION" ;;          # 안정판: 11.0 → source/11.0/
    *)   SERIES="${VERSION%%.*}.x" ;;  # 개발판: 11.18 → source/11.x/
esac

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/build/wine-$VERSION-$FLAVOR"
DEST="${DEST:-$ROOT/runners/wine-$VERSION-$FLAVOR}"
TARBALL="wine-$VERSION.tar.xz"
URL="https://dl.winehq.org/wine/source/$SERIES/$TARBALL"
JOBS="${JOBS:-$(nproc)}"

case "$FLAVOR" in
    release) OPTFLAGS="-O2" ;;
    debug)   OPTFLAGS="-O2 -g" ;;
    *) echo "FLAVOR는 release 또는 debug" >&2; exit 1 ;;
esac

mkdir -p "$ROOT/build" "$WORK/obj"
cd "$ROOT/build"

if [ ! -f "$TARBALL" ]; then
    echo ">> 다운로드: $URL"
    curl -fL -o "$TARBALL.part" "$URL"
    mv "$TARBALL.part" "$TARBALL"
fi
echo ">> sha256: $(sha256sum "$TARBALL" | cut -d' ' -f1)"

if [ ! -f "$WORK/src/configure" ]; then
    mkdir -p "$WORK/src"
    tar -xf "$TARBALL" -C "$WORK/src" --strip-components=1
    for p in "$ROOT"/patches/*.patch; do
        [ -e "$p" ] || continue
        echo ">> 패치: ${p##*/}"
        patch -d "$WORK/src" -p1 <"$p"
    done
fi

cd "$WORK/obj"
if [ ! -f Makefile ]; then
    echo ">> configure ($FLAVOR)"
    ../src/configure \
        --prefix="$DEST" \
        --enable-archs=i386,x86_64 \
        --disable-tests \
        --without-oss \
        --without-capi \
        --without-sane \
        --without-cups \
        CFLAGS="$OPTFLAGS" CROSSCFLAGS="$OPTFLAGS" \
        >configure.log 2>&1 || { tail -30 configure.log; exit 1; }
    grep -E '^configure: (WARNING|.* not found)' configure.log || true
fi

echo ">> make -j$JOBS"
make -j"$JOBS" >make.log 2>&1 || { tail -40 make.log; exit 1; }

echo ">> install → $DEST"
rm -rf "$DEST"
make install-lib >install.log 2>&1 || { tail -20 install.log; exit 1; }
if [ "$FLAVOR" = release ]; then
    find "$DEST" -name '*.so' -exec strip --strip-unneeded {} +
    strip --strip-unneeded "$DEST"/bin/wine "$DEST"/bin/wineserver 2>/dev/null || true
fi
"$DEST/bin/wine" --version
du -sh "$DEST"
