# 로드맵

앞으로 할 일과 확인이 필요한 항목입니다. 끝난 항목은 changelog(`packaging/changelog`)로 옮기고 여기서 지웁니다.

## 현재 상태 (2026-10-18)

- **릴리스**: v0.3.3 (main). `kakaotalk --report`, 이슈 템플릿, README 스크린샷과 짧아진 설치 안내.
  v0.3.2: APT 저장소로 자동 업데이트, 받은 실행 파일 차단, push/PR 검사와 매주 점검(watch) 워크플로.
  0001~0007 패치: 창 끌기, 투명도, 최소 크기, 폴더 열기, 파일 선택 창(portal), 폴더 선택 창, 끌어다 놓기/붙여넣기.
  KDE Plasma 5 X11(Kubuntu 24.04)과 Plasma 6 Wayland(Kubuntu 26.04)에서 사용자가 전체 기능을 확인함
- 저장소 토픽, Discussions, 이슈 템플릿까지 공개 준비 끝. 다음은 블로그(Tistory)와 GeekNews 소개
- 작업 규칙과 주의점은 저장소 루트의 `CLAUDE.md`를 먼저 읽을 것

## 진행 중: 우클릭 메뉴 클릭이 안 됨 (2026-10-18 보고)

- **증상**: 새 Qt 버전(KakaoTalkUI, 베타)에서 우클릭 메뉴가 뜨지만 **메뉴 안의 어떤 항목을 눌러도 반응이 없음**.
  채팅방 알림 켜기/끄기도 우클릭 메뉴라 안 됨. 환경: KDE Plasma(사용자 PC). 예전 UI(KakaoTalk.exe)에서 같은지는 아직 확인 안 함
- **로그** (`KAKAOTALK_DEBUG=1`, 기본 채널): 클릭 시점에 err/예외 없음. 시작 때 나오는 무해한 오류만 있음
  (winemenubuilder 꺼 둠, Kerberos 없음, icuuc 포워드, 앱이 잡는 wil::ResultException)
- **가설 1 (유력)**: 패치 0002. Qt는 반투명 GL 창에 `DwmEnableBlurBehindWindow`를 부르고, 0002는 그 창의 GL 표면을 만들 때
  `x11drv_client_surface_create_alpha` → `set_window_visual(argb)`로 **whole_window를 지우고 다시 만든다**(`window.c` `set_window_visual`).
  팝업 메뉴는 이미 화면에 떠서 마우스를 잡은(capture) 상태에서 첫 프레임 때 이 일이 일어나므로, 새 X 창에 클릭이 안 가거나
  Wine의 창 상태(매핑, 입력 마스크, capture)가 어긋날 수 있음. 알림 팝업은 클릭할 일이 없어서 지금까지 안 드러났을 수 있음
- **가설 2**: 반투명(layered) 창의 입력 처리. 투명한 픽셀은 클릭이 통과하도록 Wine이 모양(shape)을 잡는데,
  ARGB로 바뀐 창에서 이게 잘못 계산되어 메뉴 전체가 클릭 통과일 수 있음
- **다음 할 일 (로컬에서)**
  1. 예전 UI 카카오톡에서도 같은지 확인 (Wine 문제인지 베타 문제인지)
  2. `tests/qt-popup/`의 Qt6 테스트 앱으로 카카오톡 없이 재현 (위젯 `QMenu` windows11 스타일, QML `Popup.Window`)
  3. 재현되면 0002를 뺀 빌드로 비교: `patches/0002-*.patch`를 잠시 옮기고 `DEST=runners/wine-no0002 scripts/build-wine.sh`
     (작업 폴더가 `build/wine-11.0-release`로 같으므로 `build/`의 해당 폴더를 지우거나 FLAVOR를 바꿔서)
  4. 0002가 원인이면: 이미 매핑된 창은 whole_window를 다시 만들지 말고 처음부터 ARGB로 만들기(창 생성/표시 전에 blur-behind 속성 확인),
     또는 다시 만든 뒤 capture/매핑 상태를 복원. 확인용 로그 채널: `KAKAOTALK_WINEDEBUG="err+all,+win,+event,+x11drv,+opengl"`

## 0.4.0: 환경 지원 넓히기

- [ ] **한글 입력 테스트** (README "한글 입력" 표)
  - [ ] GNOME (Wayland) + ibus-hangul: 우분투 기본 환경이라 가장 먼저. 절차와 확인 목록은 `docs/testing-gnome-ibus.md`
  - [x] KDE Plasma 6.6 (Wayland) + fcitx5: Kubuntu 26.04에서 전체 기능 확인
  - [ ] kime
  - [ ] nimf
- [ ] **Wayland 세션 동작 범위 정리**: 카카오톡은 XWayland로 실행됨
  - KDE Plasma 6 Wayland: 알림, 자동 실행, 트레이, 파일 창, 끌어다 놓기까지 모두 동작 확인 (Kubuntu 26.04).
    XWayland 배율을 앱이 직접 처리하는 KDE 기본 설정에서 125%도 선명함
  - GNOME Wayland는 XWayland 배율 방식이 달라 분수 배율에서 흐릿할 수 있음. DPI 감지는 지금 X11(`Xft.dpi`)과 GNOME 설정만 봄
  - 카카오톡의 화면 캡처 기능, 페이스톡 화면 공유는 Wayland에서 동작하지 않을 가능성이 높음
  - 확인한 결과를 README에 기록
- [ ] **파일 경로 처리 통합**: 0005(파일 선택 창)의 경로 매핑(`map_to_shared_dir`, `link_folder`)을
  0007에서 ntdll에 넣은 공용 처리(`unix_to_nt_file_name`의 링크 역추적)로 합쳐서 한 곳에서 관리

## 이후

- [ ] **페이스톡 영상 깜빡임** 원인 조사 (README 알려진 문제)
- [ ] **Wine 업스트림 제출**: 0001, 0003을 Wine 11.18 기준으로 맞춘 패치와 제출 방법은 저장소 밖(사용자 개인 메모)에 있음.
  제출은 실명 작성자로 GitLab 머지 리퀘스트를 열어야 해서 사용자가 직접 할 것
- [ ] **Wine 버전업 절차**: 11.x 안정판이 나오면 패치 적용, 빌드, 기본 동작을 확인하는 체크리스트나 스크립트

## Wine 패치 분류

카카오톡에서만 동작하는 코드는 없습니다. 모두 카카오톡에서 발견한 문제이지만 수정은 일반적이고,
카카오톡에 맞춘 설정은 런처(`src/kakaotalk`)의 레지스트리 설정에만 있습니다.

| 패치 | 종류 | 켜는 조건 | 업스트림 제출 |
|---|---|---|---|
| 0001 끌기 후 창이 마우스를 따라다님 | 범용 버그 수정 | 항상 | 적합 (작고 독립적) |
| 0002 DWM blur-behind 창의 GL 투명도 | 범용 기능 구현 | 앱이 `DwmEnableBlurBehindWindow`를 부를 때 | 가능 (크기가 커서 다듬어야 함) |
| 0003 최소 창 크기 힌트 | 범용 버그 수정 | 항상 | 적합 |
| 0004 "폴더 열기"를 리눅스 파일 관리자로 | 호스트 연동 | 레지스트리 `HostFileManager` | 형태를 바꿔야 함 |
| 0005 리눅스 파일 선택 창(portal) | 호스트 연동 | 레지스트리 `HostFileChooser` | 논의 필요 (큰 기능) |
| 0006 폴더 선택도 리눅스 창으로 | 호스트 연동 | `HostFileChooser` | 0005와 함께 |
| 0007 끌어다 놓기/붙여넣기 경로 | 범용 수정 + 정책 | 드라이브로 닿지 않는 경로일 때만 (Z:가 있으면 변화 없음) | 링크 역추적 부분은 가능 |
