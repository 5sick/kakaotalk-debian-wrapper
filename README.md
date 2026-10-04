# kakaotalk-debian-wrapper

> **English summary** — An unofficial `.deb` that runs the Windows version of KakaoTalk on Debian/Ubuntu (amd64)
> with a bundled, patched Wine 11. It sets up Korean fonts, DPI and the input method, adds desktop integration,
> and uses the Linux file chooser and file manager. KakaoTalk itself is downloaded from Kakao's official server on
> first run. The Wine patches are general fixes and opt-in host integration, documented in [patches/](patches/);
> plans are in [docs/ROADMAP.md](docs/ROADMAP.md). Not affiliated with Kakao Corp.

Debian/Ubuntu에서 Windows용 카카오톡을 **설치 한 번으로 자연스럽게** 쓰기 위한 비공식 래퍼입니다.
패치한 Wine을 함께 넣은 `.deb` 하나로 설치, 한글 폰트와 입력기 설정, 메뉴와 아이콘, `kakaotalk://` 링크까지 처리합니다.

> **비공식 프로젝트입니다.** 카카오(Kakao Corp.)와 관련이 없고, 카카오톡 프로그램은 포함하지 않습니다.
> 카카오톡은 처음 실행할 때 **카카오 공식 서버**에서 받아 설치하며, 설치 화면에서 카카오 이용약관을 직접 확인합니다.

## 설치

1. [Releases](../../releases/latest)에서 `kakaotalk-debian-wrapper_*_amd64.deb`를 받습니다.
2. 받은 폴더에서 설치합니다.
   ```sh
   sudo apt install ./kakaotalk-debian-wrapper_*_amd64.deb
   ```
3. 앱 메뉴에서 **카카오톡**을 실행합니다. 처음 실행하면 카카오 공식 서버에서 설치 파일을 받아 설치 화면을 띄웁니다.

**업데이트는 자동**입니다. 설치할 때 이 프로젝트의 APT 저장소가 함께 등록되어(Chrome과 같은 방식),
새 버전은 `sudo apt update && sudo apt upgrade`로 받습니다. 0.3.1 이하를 쓰고 있다면 새 .deb를 한 번만 직접 설치하세요.

문제가 생기면 `kakaotalk --report` 출력을 붙여서 [이슈](../../issues/new/choose)로 알려주세요.

<details>
<summary>.deb를 받지 않고 APT 저장소로 바로 설치하기</summary>

```sh
sudo curl -fsSLo /usr/share/keyrings/kakaotalk-debian-wrapper.gpg \
    https://5sick.github.io/kakaotalk-debian-wrapper/kakaotalk-debian-wrapper.gpg
printf 'Types: deb\nURIs: https://5sick.github.io/kakaotalk-debian-wrapper\nSuites: stable\nComponents: main\nArchitectures: amd64\nSigned-By: /usr/share/keyrings/kakaotalk-debian-wrapper.gpg\n' |
    sudo tee /etc/apt/sources.list.d/kakaotalk-debian-wrapper.sources >/dev/null
sudo apt update && sudo apt install kakaotalk-debian-wrapper
```

저장소 서명 키 지문: `5C29 AB15 7AE5 9DEF 118E  F830 A6E2 7F09 9E82 C5F8`

</details>

**지원 환경**: amd64, Debian 12 이상 / Ubuntu 22.04 이상 (및 파생 배포판). 32비트(i386) 패키지는 필요 없습니다.
Debian 12, 13과 Ubuntu 22.04, 24.04, 26.04에서 설치 테스트를 하고, X11과 Wayland 세션 모두 실제로 사용해 확인했습니다.

**카카오톡 버전**: 기본으로 받는 공식 64비트 카카오톡(26.8)과 새 Qt 기반 카카오톡(베타) 모두 동작을 확인했습니다.
베타 설치 파일은 `kakaotalk --install 설치파일.exe`로 설치할 수 있습니다.

## 사용법

```sh
kakaotalk                        # 실행 (처음이면 설치부터)
kakaotalk --install [설치파일]   # 설치/재설치. 새 Qt 버전(베타) 설치 파일을 직접 줄 수도 있음
kakaotalk --autostart on|off     # 로그인 시 트레이로 자동 실행 (카카오톡 설정의 "자동 실행"과 같은 설정)
kakaotalk --kill                 # 강제 종료
kakaotalk --reset                # 카카오톡 데이터 전체 삭제 후 초기화
kakaotalk --report               # 문제 보고용 환경 정보 (이슈에 붙여넣기)
kakaotalk --help
```

설정은 `kakaotalk --config`(또는 앱 메뉴의 카카오톡 아이콘 우클릭 → **설정 열기**)로 엽니다.
`~/.config/kakaotalk-debian-wrapper/env` 파일이 옵션 설명과 함께 열리고, 줄 앞의 `#`을 지우고 값을 바꿔 저장하면
**카카오톡을 다시 실행할 때** 적용됩니다.

| 변수 | 설명 |
|---|---|
| `KAKAOTALK_FONTENGINE=freetype` | 글꼴 렌더링 엔진 (`directwrite` 기본, `freetype`, `gdi`) |
| `KAKAOTALK_SETUP_URL=...` | 설치 파일 주소 (기본: 공식 64비트 설치 파일) |
| `KAKAOTALK_SHARED_DIRS="Downloads Documents Pictures"` | 카카오톡에서 보이는 폴더 (아래 참고) |
| `KAKAOTALK_FULL_ACCESS=1` | Wine 기본값처럼 모든 폴더와 `Z:`(/) 드라이브를 엽니다 |
| `KAKAOTALK_DEBUG=1` | `~/.cache/kakaotalk-debian-wrapper/`에 Wine 로그 저장 |

데이터 위치: `~/.local/share/kakaotalk-debian-wrapper/prefix` (Wine prefix).
패키지를 삭제해도(`apt remove`든 `apt purge`든) 홈 폴더의 데이터는 남습니다. 완전히 지우려면 패키지를 지우기 전에
`kakaotalk --reset`을 실행하세요. 설정(`~/.config/kakaotalk-debian-wrapper/`), 캐시(`~/.cache/kakaotalk-debian-wrapper/`),
메뉴 항목(`~/.local/share/applications/kakaotalk-debian-wrapper.desktop`)도 필요하면 직접 지우면 됩니다.

### 파일 접근 범위

Wine은 기본적으로 `Z:` 드라이브로 리눅스 파일 시스템 전체를 Windows 프로그램에 보여줍니다.
이 패키지는 기본값으로 **다운로드, 문서, 사진 폴더만** 카카오톡에 연결하고 `Z:` 드라이브는 없앱니다.
보낼 파일은 이 폴더들에 두면 되고, 받은 파일은 `문서/KakaoTalk Downloads`에 저장됩니다.

바꾸려면 `kakaotalk --config`로 설정 파일을 열고:

- 폴더 추가: `KAKAOTALK_SHARED_DIRS="Downloads Documents Pictures Desktop"` (Desktop, Music, Videos 가능)
- 예전처럼 전부 열기: `KAKAOTALK_FULL_ACCESS=1`

저장한 뒤 `kakaotalk --kill`로 완전히 종료하고 다시 실행하면 적용됩니다.

보안 샌드박스는 아닙니다. 카카오톡이 불필요하게 넓은 범위를 보지 않게 하는 정도입니다.

카카오톡에서 받은 파일(사진, 동영상, 문서, 한글 파일 등)을 열면 Wine 프로그램 대신 **리눅스 기본 앱**으로 열립니다.
"폴더 열기"는 Wine 탐색기 대신 **리눅스 파일 관리자**(Dolphin, Nautilus 등)에서 해당 파일을 선택한 채로 열립니다.

파일 첨부/저장 창과 폴더 선택 창은 **리눅스 파일 선택 창**(xdg-desktop-portal)으로 뜹니다.
포털이 없는 환경에서만 예전처럼 Wine 창이 뜹니다.
위 공유 폴더 밖의 폴더를 고르면, **고른 그 폴더만** 카카오톡 안의 `C:\Linux\<폴더 이름>`에 연결해서 씁니다.
연결은 유지되므로(설정해 둔 다운로드 폴더 등이 계속 동작하도록) 필요 없어지면
`~/.local/share/kakaotalk-debian-wrapper/prefix/drive_c/Linux/` 안의 링크를 지우면 됩니다.

파일 관리자에서 **끌어다 놓거나 복사해서 붙여넣은 파일**도 그대로 보낼 수 있습니다.
공유 폴더 밖의 파일이면 폴더 전체가 아니라 **그 파일만** 임시로 연결하고, 이 연결은 카카오톡을 다음에 실행할 때 지워집니다.

### 한글 입력

Wine은 입력기의 X 입력 방식(XIM)을 사용합니다. 런처가 실행 중인 fcitx/ibus/kime/nimf를 감지해
`XMODIFIERS`를 설정하고, 세션에 이미 `XMODIFIERS`가 있으면 그대로 따릅니다.

| 환경 | 상태 |
|---|---|
| KDE Plasma 5.27 (X11) + fcitx5 — Kubuntu 24.04 | ✅ 확인됨 |
| KDE Plasma 6.6 (Wayland) + fcitx5 — Kubuntu 26.04 | ✅ 확인됨 |
| GNOME (Wayland) + ibus-hangul (우분투 기본) | 테스트 예정 ([테스트 방법](docs/testing-gnome-ibus.md)) |
| kime, nimf | 테스트 예정 |

위 두 KDE 환경에서는 한글 입력뿐 아니라 알림, 자동 실행, 트레이, 창 끌기와 크기 조절, 파일 첨부/저장 창,
폴더 열기, 끌어다 놓기와 붙여넣기까지 모두 확인했습니다. Wayland 세션에서 카카오톡은 XWayland로 실행되며,
KDE의 기본 설정(레거시 앱 배율을 앱이 직접 처리)에서는 125% 배율에서도 흐릿하지 않습니다.

다른 환경에서 써 보셨다면 이슈로 결과를 알려주세요. 로그인 자동 실행 때는 입력기가 뜰 때까지 최대 15초
기다립니다. 그래도 한글 입력이 안 되면 카카오톡을 다시 실행하세요.

### 자동 실행

카카오톡 설정의 **자동 실행**을 켜면 로그인할 때 트레이로 시작합니다. `kakaotalk --autostart on|off`도 같은 설정을 바꿉니다.
(Wine은 Windows처럼 로그인 때 자동 실행 항목을 실행해 주지 않아서, 패키지의 `/etc/xdg/autostart` 항목이 대신 확인합니다.
데스크톱 설정의 "자동 시작" 목록에서 이 항목을 끄면 카카오톡 설정과 상관없이 자동 실행되지 않습니다.)

### 트레이 아이콘

카카오톡을 닫으면 트레이로 들어갑니다. KDE, Xfce, Cinnamon 등은 바로 보이고,
**GNOME은 트레이가 없어서** [AppIndicator 확장](https://extensions.gnome.org/extension/615/appindicator-support/)이
필요합니다 (우분투는 기본 설치됨).

## 기존 Wine/Bottles와 무엇이 다른가

- **Wine 동봉**: 배포판의 Wine 버전에 상관없이 검증한 Wine 11(wow64)을 씁니다. 시스템 Wine과 충돌하지 않습니다.
- **카카오톡용 패치**: 창을 드래그한 뒤 마우스를 따라다니는 문제, 알림 팝업과 툴팁 둘레가 검게 나오는 문제, 창이 실처럼 줄어드는 문제를 Wine 쪽에서 고쳤고, 파일 선택 창과 "폴더 열기"가 리눅스 쪽 창으로 뜨게 했고, `Z:` 없이도 끌어다 놓기와 붙여넣기가 되게 했습니다 ([patches/](patches/)).
- **한국어 환경 자동 설정**: 맑은 고딕 → Noto Sans CJK KR 대체, 화면 배율(DPI), fcitx/ibus 입력기.
- **데스크톱 통합**: 앱 메뉴, 설치된 카카오톡에서 추출한 아이콘, `kakaotalk://` 링크, 자동 실행.

## 알려진 문제

- 음성 통화와 페이스톡(카메라)은 동작하지만, 페이스톡 영상이 간헐적으로 깜빡입니다 (조사 중).
- 창의 투명도는 컴포지터(KWin, Mutter 등)가 켜져 있어야 적용됩니다.

앞으로 할 일은 [docs/ROADMAP.md](docs/ROADMAP.md)에 정리해 두었습니다.

## 직접 빌드하기

```sh
scripts/build-wine-docker.sh 11.0   # Ubuntu 22.04 컨테이너에서 Wine 빌드 (Docker 필요)
packaging/build-deb.sh              # dist/에 .deb 생성
```

개발 중에는 `FLAVOR=debug scripts/build-wine.sh`로 디버그 정보가 있는 Wine을 빌드하고
`KAKAOTALK_WINE=runners/wine-11.0-debug src/kakaotalk`로 실행할 수 있습니다.

## 라이선스

- 런처와 스크립트: [MIT](LICENSE)
- Wine 패치(`patches/`): LGPL-2.1 이상 (Wine과 동일)
- 동봉한 Wine: LGPL-2.1 이상. 사용한 소스 tarball과 패치를 각 릴리스에 함께 올립니다.
- 카카오톡과 카카오톡 아이콘은 카카오의 저작물이자 상표이며, 이 저장소에 포함하지 않습니다.
