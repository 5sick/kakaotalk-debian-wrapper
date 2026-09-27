#!/bin/sh
# 배포용 Wine을 Ubuntu 22.04 컨테이너에서 빌드한다. 결과: runners/wine-<버전>-release
# SPDX-License-Identifier: MIT
set -eu

VERSION="${1:-11.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE=kakaotalk-debian-wrapper-build:22.04

docker build -t "$IMAGE" "$ROOT/docker"
# 컨테이너 안과 밖의 경로를 같게 두어 configure가 기록한 절대 경로가 그대로 유효하게 한다
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$ROOT:$ROOT" -w "$ROOT" \
    -e FLAVOR=release -e JOBS="${JOBS:-$(nproc)}" \
    "$IMAGE" scripts/build-wine.sh "$VERSION"
