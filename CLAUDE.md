# kakaotalk-debian-wrapper — 작업 안내

Windows 카카오톡을 패치한 Wine 11.0(wow64, X11 드라이버)으로 실행하는 비공식 .deb입니다.
목표는 사용자 PC 하나가 아니라 **데비안 계열 전반**(Debian 12/13, Ubuntu 22.04/24.04)에서 편하게 동작하는 것입니다.
할 일은 [docs/ROADMAP.md](docs/ROADMAP.md), 변경 이력은 `packaging/changelog`에 있습니다.

## 구조

| 경로 | 내용 |
|---|---|
| `src/kakaotalk` | 런처 (POSIX sh). prefix 생성, 레지스트리 설정, 파일 접근 제한, 폰트/입력기/DPI |
| `src/open-helper` | `/usr/lib/kakaotalk-debian-wrapper/open`. winebrowser와 패치된 explorer/shell32가 호출 |
| `patches/` | Wine 패치 (LGPL-2.1+). `scripts/build-wine.sh`가 번호 순서로 원본 wine-11.0에 적용. 설명은 `patches/README.md` |
| `scripts/build-wine-docker.sh` | Ubuntu 22.04 컨테이너(glibc 2.35)에서 배포용 Wine 빌드. 결과는 `runners/wine-11.0-release` |
| `packaging/` | `build-deb.sh`, `test-install.sh`(debian:12/13, ubuntu:22.04/24.04 설치 테스트), `control.in`, `changelog` |
| `.github/workflows/build.yml` | `v*` 태그 → 빌드, 설치 테스트, 릴리스. `workflow_dispatch`는 릴리스 없이 빌드만 |

## 규칙

- **커밋 작성자**: 저장소 로컬 설정 `5sick <213179368+5sick@users.noreply.github.com>`. 실제 이메일은 공개하지 않습니다.
- **릴리스**: `VERSION`과 `packaging/changelog` 최신 항목을 올리고 `vX.Y.Z` 태그를 push하면 CI가 릴리스합니다. 태그와 `VERSION`이 다르면 CI가 실패합니다.
- **main 병합, 태그, 릴리스는 사용자 확인 후에만** 합니다.
- 태그 릴리스 때 CI가 `packaging/publish-apt.sh`로 서명된 APT 저장소를 `gh-pages`(GitHub Pages)에 다시 만듭니다 (최근 3개 버전).
  서명 키는 저장소 비밀값 `APT_SIGNING_KEY`, 공개 키는 `packaging/apt/`에 있습니다. 개인 키 백업은 사용자 PC의
  `~/kakaotalk-debian-wrapper-apt-signing-key.asc`에만 있으니 저장소에 넣지 않습니다.
- `watch.yml`이 매주 공식 설치 파일 주소와 Wine 새 안정판을 확인하고 이슈를 엽니다. 그 이슈가 오면 처리합니다.
- **라이선스**: 런처/스크립트는 MIT, `patches/`는 LGPL-2.1+. 카카오톡 바이너리와 아이콘은 저장소에 넣지 않습니다.
- 런처의 레지스트리 설정을 바꾸면 `TWEAKS_VERSION`을 올립니다 (기존 prefix에 다시 적용됨).
- 스타일: 런처/도우미는 한국어 주석과 메시지, POSIX sh. Wine 패치는 Wine 코딩 스타일.
- 범위는 "적당히": 과하게 다듬지 말고, 동작 확인이 되면 넘어갑니다. 배포 형식은 .deb만 (Flatpak 하지 않음).

## 알아두면 시간 절약되는 것

- 한글이 들어간 `.reg`는 **UTF-16(버전 5 형식)**으로 만들고 `wine reg import FILE /reg:64`로 넣습니다. REGEDIT4는 CP949로 읽혀 깨집니다.
- Wine의 Unix 쪽 코드(`*.so`, winex11.drv 등)는 `wchar_t`가 4바이트라 `L"..."`를 쓸 수 없습니다. PE 쪽(shell32, comdlg32, explorer)은 됩니다.
- PE 쪽(msvcrt)에는 `strndup`이 없습니다.
- 카카오톡 설치 폴더 파일은 서명된 해시 목록(`version.info`)으로 검사되므로 **절대 수정하지 않습니다.** 고칠 것은 Wine 쪽에서 고칩니다.
- 기본값으로 `Z:` 드라이브를 없앴습니다. 리눅스 경로를 Windows 경로로 못 바꾸는 상황은 링크(`C:\Linux\`, 0005; `C:\windows\temp\host-files\`, 0007)로 해결합니다.
- 공식 설치 파일: `talk/win32/x64/KakaoTalk_Setup.exe`(예전 UI, 런처 기본값). 새 Qt6 버전(KakaoTalkUI)은 공식 베타 배포본으로 `kakaotalk --install 파일`로 설치합니다. 두 버전 모두 확인해야 합니다.
- GUI 동작은 화면이 있어야 확인됩니다. 설치 화면 같은 것은 Xvfb + `xwd`로 스크린샷을 찍어 확인할 수 있지만, 카카오톡 로그인 이후 기능은 사용자가 실제 데스크톱에서 확인합니다.
- **클라우드 세션**: 네트워크 정책상 `dl.winehq.org`, `gitlab.winehq.org`, Launchpad, Debian/Ubuntu 소스 서버가 막혀 있습니다.
  Wine 소스는 `git clone --depth 1 --branch wine-11.0 https://github.com/wine-mirror/wine`로 받아 `git archive`로 `build/wine-11.0.tar.xz`를 만듭니다.
  릴리스용 tarball은 CI가 WineHQ 원본으로 받습니다 (LGPL 소스 제공).
- 빠른 반복: 전체 빌드 후에는 `make -C build/wine-11.0-release/obj -j$(nproc) dlls/<모듈>/all`로 바뀐 모듈만 다시 빌드하고,
  `KAKAOTALK_WINE=runners/wine-11.0-release src/kakaotalk`로 시스템 패키지 없이 실행해 봅니다.
  패치 파일을 고친 뒤에는 새 tarball에 0001부터 전부 `patch -p1`로 적용되는지 확인합니다.
