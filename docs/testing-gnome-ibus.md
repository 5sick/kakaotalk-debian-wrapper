# GNOME + ibus-hangul 테스트 방법

우분투 기본 환경(GNOME Wayland + ibus-hangul)에서 동작을 확인하는 절차입니다.
KDE PC에서도 가상 머신으로 30분 정도면 할 수 있습니다.

## 1. 가상 머신 준비

GNOME Boxes가 가장 간단합니다 (KDE에서도 설치해서 쓸 수 있습니다).

```sh
sudo apt install gnome-boxes
```

1. [Ubuntu Desktop 26.04 ISO](https://ubuntu.com/download/desktop)를 받습니다.
2. Boxes에서 **+ → 새 가상 머신 만들기 → ISO 파일 선택**. 메모리 4GB 이상, 디스크 25GB 이상.
3. 설치 과정에서 언어를 **한국어**로 고르면 ibus-hangul이 함께 설치됩니다.
   영어로 설치했다면 설치 후 `설정 → 키보드 → 입력 소스 → + → 한국어(Hangul)`를 추가합니다.

설치 없이 빨리 보려면 ISO로 부팅한 **"Try Ubuntu"(라이브 세션)**에서도 됩니다. 다만 재부팅하면 다 사라져서
자동 실행 확인은 할 수 없습니다.

가상 머신에서는 카메라와 소리가 제대로 안 될 수 있으니 페이스톡/음성 통화는 확인 대상에서 뺍니다.

## 2. 설치

가상 머신 안의 터미널에서:

```sh
wget https://github.com/5sick/kakaotalk-debian-wrapper/releases/latest/download/kakaotalk-debian-wrapper_$(curl -fsSL https://raw.githubusercontent.com/5sick/kakaotalk-debian-wrapper/main/VERSION)_amd64.deb
sudo apt install ./kakaotalk-debian-wrapper_*_amd64.deb
kakaotalk
```

GNOME은 트레이가 없어서 AppIndicator 확장이 필요합니다. 우분투에는 기본으로 들어 있어서 따로 할 일은 없습니다.

## 3. 확인 목록

문제가 있으면 `KAKAOTALK_DEBUG=1 kakaotalk`으로 다시 실행해서 `~/.cache/kakaotalk-debian-wrapper/`의 로그를 함께 남깁니다.

| # | 항목 | 확인 방법 | 결과 |
|---|---|---|---|
| 1 | 한글 입력 | 채팅 입력창에서 `Super+Space`(또는 한/영)로 전환 후 입력. 조합 중인 글자가 입력창 안에 보이는지 | |
| 2 | 마지막 글자 | "안녕하세요" 입력 후 바로 Enter. 마지막 "요"가 빠지거나 다음 줄로 넘어가지 않는지 | |
| 3 | 알림 | 카카오톡 창을 최소화하고 메시지 받기. 오른쪽 아래 팝업, 둘레가 검지 않은지 | |
| 4 | 트레이 | 창을 닫으면 상단 바 오른쪽에 아이콘이 남는지 | |
| 5 | 배율 | `설정 → 디스플레이`에서 125%로 바꾸고 글씨가 흐릿한지 (GNOME은 흐릿할 수 있음) | |
| 6 | 파일 첨부 / 저장 | GNOME 파일 선택 창이 뜨는지 | |
| 7 | 폴더 열기 | 받은 파일의 "폴더 열기"로 Nautilus가 파일을 선택한 채 열리는지 | |
| 8 | 끌어다 놓기 | Nautilus에서 채팅창으로 파일 끌어다 놓기 | |
| 9 | 자동 실행 | 카카오톡 설정에서 자동 실행을 켜고 로그아웃 → 로그인 | |

## 4. 결과 기록

README의 "한글 입력" 표와 `docs/ROADMAP.md`의 해당 항목을 결과에 맞게 고칩니다.
문제가 있는 항목은 이슈로 남깁니다.
