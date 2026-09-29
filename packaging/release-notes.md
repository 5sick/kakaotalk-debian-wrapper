
## 설치

```sh
sudo apt install ./kakaotalk-debian-wrapper_*_amd64.deb
```

앱 메뉴에서 **카카오톡**을 실행하세요. 처음 실행하면 카카오 공식 서버에서 설치 파일을 받아 설치 화면을 띄웁니다.
자세한 사용법과 알려진 문제는 [README](https://github.com/5sick/kakaotalk-debian-wrapper#readme)를 보세요.

**지원**: amd64 / Debian 12, 13 / Ubuntu 22.04, 24.04, 26.04 (깨끗한 컨테이너에서 설치 테스트함). i386 패키지 필요 없음.

## 라이선스 / 소스

동봉한 Wine은 LGPL-2.1 이상입니다. 빌드에 쓴 WineHQ 원본 소스(`wine-*.tar.xz`)를 이 릴리스에 함께 올렸고,
적용한 패치와 빌드 스크립트는 저장소의 `patches/`, `scripts/`에 있습니다.
카카오톡은 포함하지 않으며, 이 프로젝트는 카카오와 관련이 없습니다.
