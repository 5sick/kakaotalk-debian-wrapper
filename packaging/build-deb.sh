#!/bin/sh
# .deb 패키지를 만든다. 결과: dist/kakaotalk-debian-wrapper_<버전>_amd64.deb
# SPDX-License-Identifier: MIT
#
# 사용법: packaging/build-deb.sh [Wine 빌드 경로]
#   기본 Wine 경로: runners/wine-<WINE_VERSION>-release (scripts/build-wine-docker.sh 결과)
set -eu
umask 022

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG=kakaotalk-debian-wrapper
VERSION="$(cat "$ROOT/VERSION")"
WINE_VERSION="${WINE_VERSION:-11.0}"
WINE_DIR="${1:-$ROOT/runners/wine-$WINE_VERSION-release}"
MAINTAINER="${MAINTAINER:-$(git -C "$ROOT" config user.name) <$(git -C "$ROOT" config user.email)>}"
# git@github.com:user/repo.git 또는 https://github.com/user/repo(.git) → https://github.com/user/repo
HOMEPAGE="${HOMEPAGE:-$(git -C "$ROOT" remote get-url origin 2>/dev/null \
    | sed -e 's#^git@github.com:#https://github.com/#' -e 's#\.git$##')}"
HOMEPAGE="${HOMEPAGE:-https://github.com}"

[ -x "$WINE_DIR/bin/wine" ] || { echo "Wine 빌드가 없습니다: $WINE_DIR" >&2; exit 1; }

STAGE="$ROOT/dist/stage"
DOC="$STAGE/usr/share/doc/$PKG"
rm -rf "$STAGE"
mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/bin" "$STAGE/opt/$PKG" "$DOC/wine-patches" \
         "$STAGE/usr/share/applications" "$STAGE/usr/share/icons/hicolor/scalable/apps"

install -m755 "$ROOT/src/kakaotalk" "$STAGE/usr/bin/kakaotalk"
install -D -m755 "$ROOT/src/open-helper" "$STAGE/usr/lib/$PKG/open"
install -m644 "$ROOT/src/$PKG.desktop" "$STAGE/usr/share/applications/$PKG.desktop"
install -m644 "$ROOT/src/$PKG.svg" "$STAGE/usr/share/icons/hicolor/scalable/apps/$PKG.svg"
cp -a "$WINE_DIR" "$STAGE/opt/$PKG/wine"

# 라이선스 문서: Wine(LGPL)은 소스 위치와 적용한 패치를 함께 제공한다
install -m644 "$ROOT/packaging/copyright" "$DOC/copyright"
install -m644 "$ROOT/README.md" "$DOC/README.md"
install -m644 "$ROOT"/patches/*.patch "$DOC/wine-patches/"
sed -e "s/@WINE_VERSION@/$WINE_VERSION/g" -e "s/@VERSION@/$VERSION/g" -e "s#@HOMEPAGE@#$HOMEPAGE#g" \
    "$ROOT/packaging/SOURCE.in" >"$DOC/SOURCE"
gzip -9n -c "$ROOT/packaging/changelog" >"$DOC/changelog.gz"

INSTALLED_SIZE=$(du -sk --exclude=DEBIAN "$STAGE" | cut -f1)
sed -e "s/@VERSION@/$VERSION/" \
    -e "s/@MAINTAINER@/$MAINTAINER/" \
    -e "s/@INSTALLED_SIZE@/$INSTALLED_SIZE/" \
    -e "s#@HOMEPAGE@#$HOMEPAGE#" \
    "$ROOT/packaging/control.in" >"$STAGE/DEBIAN/control"

mkdir -p "$ROOT/dist"
OUT="$ROOT/dist/${PKG}_${VERSION}_amd64.deb"
dpkg-deb --root-owner-group -Zxz --build "$STAGE" "$OUT"
rm -rf "$STAGE"
ls -lh "$OUT"
