#!/bin/sh
# dist/의 .deb로 서명된 APT 저장소를 만들어 gh-pages 브랜치에 올린다 (GitHub Pages로 배포).
# SPDX-License-Identifier: MIT
#
# 필요: APT_SIGNING_KEY (ASCII armor 개인 키), apt-ftparchive(apt-utils), gpg, 푸시 권한이 있는 git
# 최근 KEEP개 버전만 남기고, gh-pages는 매번 커밋 하나로 새로 만든다 (.deb가 저장소 기록에 쌓이지 않게).
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG=kakaotalk-debian-wrapper
KEEP="${KEEP:-3}"
: "${APT_SIGNING_KEY:?APT_SIGNING_KEY가 필요합니다}"

WORK=$(mktemp -d)
SITE="$WORK/site"
export GNUPGHOME="$WORK/gnupg"
mkdir -m700 "$GNUPGHOME"
trap 'rm -rf "$WORK"' EXIT
printf '%s\n' "$APT_SIGNING_KEY" | gpg --batch --quiet --import
KEY=$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/ {print $10; exit}')

# 기존 저장소의 .deb를 가져와서 새 .deb와 합친다
POOL="pool/main/k/$PKG"
mkdir -p "$SITE/$POOL"
if git -C "$ROOT" fetch --quiet --depth 1 origin gh-pages 2>/dev/null; then
    git -C "$ROOT" archive FETCH_HEAD "$POOL" 2>/dev/null | tar -x -C "$SITE" 2>/dev/null || true
fi
cp "$ROOT"/dist/"$PKG"_*_amd64.deb "$SITE/$POOL/"
ls "$SITE/$POOL"/*.deb | sort -V | head -n -"$KEEP" | xargs -r rm -f
echo ">> 저장소에 넣는 버전:"; ls "$SITE/$POOL"

cd "$SITE"
mkdir -p dists/stable/main/binary-amd64
apt-ftparchive packages pool >dists/stable/main/binary-amd64/Packages
gzip -9nk dists/stable/main/binary-amd64/Packages
apt-ftparchive \
    -o APT::FTPArchive::Release::Origin="$PKG" \
    -o APT::FTPArchive::Release::Label="$PKG" \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    -o APT::FTPArchive::Release::Components=main \
    release dists/stable >"$WORK/Release"
mv "$WORK/Release" dists/stable/Release
gpg --batch --yes --local-user "$KEY" --clearsign -o dists/stable/InRelease dists/stable/Release
gpg --batch --yes --local-user "$KEY" --armor --detach-sign -o dists/stable/Release.gpg dists/stable/Release

cp "$ROOT/packaging/apt/$PKG.asc" "$ROOT/packaging/apt/$PKG.gpg" .
touch .nojekyll
cat >index.html <<EOF
<!doctype html><meta charset="utf-8"><title>$PKG APT repository</title>
<h1>$PKG APT 저장소</h1>
<p>.deb를 설치하면 이 저장소가 자동으로 등록되어 <code>sudo apt upgrade</code>로 업데이트됩니다.
직접 등록하려면 <a href="https://github.com/5sick/$PKG#readme">README</a>를 보세요.</p>
EOF

# 시험용: APT_SITE_DIR을 주면 올리지 않고 그 폴더에 저장소를 만든다
if [ -n "${APT_SITE_DIR:-}" ]; then
    mkdir -p "$APT_SITE_DIR" && cp -a . "$APT_SITE_DIR/"
    echo ">> $APT_SITE_DIR 에 만들었습니다 (올리지 않음)"
    exit 0
fi

git init --quiet -b gh-pages
git add -A
git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    commit --quiet -m "APT repository"
# 원래 체크아웃을 거쳐 푸시한다 (CI의 actions/checkout 인증 정보가 거기에 있다)
git -C "$ROOT" fetch --quiet "$SITE" gh-pages
git -C "$ROOT" push --quiet --force origin FETCH_HEAD:refs/heads/gh-pages
echo ">> gh-pages에 올렸습니다"
