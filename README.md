# kakaotalk-debian-wrapper

Debian/Ubuntu에서 Windows용 카카오톡을 **설치 한 번으로 자연스럽게** 쓰기 위한 비공식 래퍼입니다.
패치한 Wine을 함께 넣은 `.deb` 하나로 설치, 한글 폰트와 입력기 설정, 메뉴와 아이콘, `kakaotalk://` 링크까지 처리합니다.

> **비공식 프로젝트입니다.** 카카오(Kakao Corp.)와 관련이 없고, 카카오톡 프로그램은 포함하지 않습니다.
> 카카오톡은 처음 실행할 때 **카카오 공식 서버**에서 받아 설치하며, 설치 화면에서 카카오 이용약관을 직접 확인합니다.

## 설치

[Releases](../../releases)에서 `.deb`를 받아서:

```sh
sudo apt install ./kakaotalk-debian-wrapper_*_amd64.deb
```

앱 메뉴에서 **카카오톡**을 실행하거나 터미널에서 `kakaotalk`을 실행하면 됩니다.
처음 실행하면 Wine 환경을 준비하고 설치 파일을 받아 설치 화면을 띄웁니다.

**지원 환경**: amd64, Debian 12 이상 / Ubuntu 22.04 이상 (및 파생 배포판). 32비트(i386) 패키지는 필요 없습니다.

## 사용법

```sh
kakaotalk                        # 실행 (처음이면 설치부터)
kakaotalk --install [설치파일]   # 설치/재설치. 새 Qt 버전(베타) 설치 파일을 직접 줄 수도 있음
kakaotalk --autostart on|off     # 로그인 시 트레이로 자동 실행
kakaotalk --kill                 # 강제 종료
kakaotalk --help
```

설정은 `~/.config/kakaotalk-debian-wrapper/env`에 쉘 변수로 적습니다.

| 변수 | 설명 |
|---|---|
| `KAKAOTALK_FONTENGINE=freetype` | 글꼴 렌더링 엔진 (`directwrite` 기본, `freetype`, `gdi`) |
| `KAKAOTALK_SETUP_URL=...` | 설치 파일 주소 (기본: 공식 64비트 설치 파일) |
| `KAKAOTALK_DEBUG=1` | `~/.cache/kakaotalk-debian-wrapper/`에 Wine 로그 저장 |

데이터 위치: `~/.local/share/kakaotalk-debian-wrapper/prefix` (Wine prefix). 이 폴더를 지우면 카카오톡이 초기화됩니다.

## 기존 Wine/Bottles와 무엇이 다른가

- **Wine 동봉**: 배포판의 Wine 버전에 상관없이 검증한 Wine 11(wow64)을 씁니다. 시스템 Wine과 충돌하지 않습니다.
- **카카오톡용 패치**: 창을 드래그한 뒤 마우스를 따라다니는 문제 등을 Wine 쪽에서 고쳤습니다 ([patches/](patches/)).
- **한국어 환경 자동 설정**: 맑은 고딕 → Noto Sans CJK KR 대체, 화면 배율(DPI), fcitx/ibus 입력기.
- **데스크톱 통합**: 앱 메뉴, 설치된 카카오톡에서 추출한 아이콘, `kakaotalk://` 링크, 자동 실행.

## 알려진 문제

- 새 Qt 버전의 알림 팝업 둘레가 검게 보입니다 (Wine이 OpenGL 창의 투명도를 지원하지 않음). 수정 작업 중입니다.
- 음성/영상 통화는 아직 검증하지 않았습니다.

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
