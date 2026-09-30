# Wine 업스트림 제출용 패치

이 프로젝트의 패치 중 카카오톡과 무관한 일반 버그 수정 두 개를, 최신 Wine 개발 버전 기준으로 다시 맞춘 것입니다.
빌드 스크립트는 이 폴더를 쓰지 않습니다 (빌드용 패치는 `patches/`).

| 파일 | 원래 패치 | 내용 |
|---|---|---|
| `0001-winex11-Ignore-mouse-driven-move-resize-requests-whe.patch` | `patches/0001` | 버튼을 놓은 뒤 온 이동 요청 때문에 창이 마우스를 계속 따라다니는 문제 |
| `0002-winex11-Set-the-minimum-size-hint-of-resizable-windo.patch` | `patches/0003` | 창 관리자가 창을 실처럼 가늘게 줄일 수 있는 문제 (0002 투명도 패치와 무관하게 다시 만듦) |

- 기준: Wine 11.18 개발 버전 (wine-mirror `master`, 2026-09-26 커밋 `6880117`)
- 확인: 두 패치를 적용한 상태에서 `winex11.drv`가 경고 없이 컴파일됨. 동작은 이 프로젝트의 Wine 11.0 빌드에서
  KDE Plasma 5 (X11)와 Plasma 6 (Wayland/XWayland)로 확인함
- 여전히 필요한지: 2026-09 기준 Wine master에는 두 문제 모두 고쳐져 있지 않음

## 제출 방법

Wine은 GitLab 머지 리퀘스트로 기여를 받습니다.

1. <https://gitlab.winehq.org>에 가입합니다. **Wine은 커밋 작성자에 실명을 요구합니다.**
   지금 패치의 작성자는 `5sick`이라, 제출 전에 실명과 공개해도 되는 이메일로 바꿔야 합니다.
2. `wine/wine` 저장소를 fork하고, 최신 master에서 브랜치를 만든 뒤 패치를 적용합니다.
   ```sh
   git clone https://gitlab.winehq.org/<계정>/wine.git && cd wine
   git checkout -b winex11-move-resize origin/master
   git am --committer-date-is-author-date ../docs/upstream/000*.patch
   git commit --amend --reset-author --no-edit   # 두 커밋 모두 작성자를 실명으로 (rebase -i로 각각)
   git push -u origin winex11-move-resize
   ```
3. GitLab에서 `wine/wine`의 `master`로 머지 리퀘스트를 엽니다. 두 수정은 서로 독립이라 **머지 리퀘스트를 따로** 여는 편이
   리뷰가 빠릅니다. 설명에는 재현 방법(Qt 6 앱의 테두리 없는 창을 끌었다 놓기 / KWin에서 창 가장자리를 끌어 줄이기)을 적습니다.
4. 리뷰어가 테스트(`dlls/user32/tests` 등)나 다른 구현 방식을 요청할 수 있습니다. 반영되면 다음 Wine 버전부터
   이 프로젝트의 `patches/0001`, `patches/0003`을 지울 수 있습니다.

범위가 크거나 이 프로젝트의 정책(`Z:` 드라이브 제거)에 맞춘 나머지 패치(0002, 0004~0007)는 제출 대상이 아닙니다.
이유는 `docs/ROADMAP.md`의 "Wine 패치 분류" 표를 보세요.
