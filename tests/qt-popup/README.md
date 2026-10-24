# Qt6 팝업 메뉴 클릭 테스트

카카오톡(새 Qt 버전) 우클릭 메뉴에서 클릭이 먹지 않는 문제를 카카오톡 로그인 없이 재현하기 위한 작은 Qt6 앱입니다.
원인과 수정은 `patches/README.md`의 0008을 보세요 (창 관리자가 메뉴를 활성화해서 Qt가 버튼을 떼기 전에 메뉴를 닫음).

| 파일 | 내용 |
|---|---|
| `menu_widgets.py` | QWidget 창 + 우클릭 `QMenu`. 인자로 스타일 이름(`windows11`, `windowsvista`, `fusion`)을 줄 수 있음. windows11 스타일은 메뉴를 둥글고 반투명하게 그림. `kakao`를 더하면 카카오톡 메뉴처럼 `WS_CAPTION` + `WS_EX_NOACTIVATE` 창이 됨(창 관리자가 관리하는 창, 패치 0008 확인용: `xprop WM_PROTOCOLS`에 `WM_TAKE_FOCUS`가 없어야 함) |
| `menu_qml.py` | QML `Window` + 우클릭 `Menu { popupType: Popup.Window }` (별도 팝업 창) |

메뉴 항목을 누르면 표준 출력에 `TRIGGERED <항목>`이 찍힙니다. 찍히면 클릭이 전달된 것입니다. 20초 뒤 저절로 끝납니다.

## 준비 (Windows용 Python + PySide6, 한 번만)

```sh
mkdir -p build/qttest/dl && cd build/qttest/dl
curl -fsSL -o python.nupkg https://api.nuget.org/v3-flatcontainer/python/3.12.7/python.3.12.7.nupkg
pip download --no-deps --only-binary=:all: --platform win_amd64 --python-version 3.12 --implementation cp -d . 'PySide6_Essentials==6.10.*' 'shiboken6==6.10.*'
cd .. && mkdir -p py && cd py
python3 -I -c "import zipfile; zipfile.ZipFile('../dl/python.nupkg').extractall('nupkg')" && mv nupkg/tools python && rm -rf nupkg
for w in ../dl/*.whl; do python3 -I -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall('python/Lib/site-packages')" "$w"; done
```

- PySide6는 카카오톡과 같은 **6.10**을 씁니다. 6.12는 시작할 때 `mscms.WcsCreateIccProfile`(Wine 미구현) 때문에 죽습니다.
- Qt6Core가 Windows의 `icuuc.dll`(→ `icu.dll`)을 import하는데 Wine에는 없습니다. 카카오톡 설치 폴더의
  `bin/icuuc.dll`(icu.dll로 넘기는 작은 DLL)을 `python/` 폴더에 복사하면 import가 됩니다 (없는 함수는 쓰지 않음).

## 실행

카카오톡과 섞이지 않게 별도 prefix를 씁니다. 실제 데스크톱에서 직접 우클릭하고 항목을 눌러 봅니다.

```sh
W=runners/wine-11.0-release            # 또는 /opt/kakaotalk-debian-wrapper/wine
export WINEPREFIX=/tmp/qt-popup-prefix QSG_RHI_BACKEND=opengl   # 카카오톡 런처와 같은 GL 경로
export PYTHONIOENCODING=utf-8   # 한글 출력 (없으면 TRIGGERED 출력에서 예외가 나서 클릭이 안 된 것처럼 보임)
$W/bin/wineboot -i
cp -r build/qttest/py/python tests/qt-popup/*.py "$WINEPREFIX/drive_c/"
cd "$WINEPREFIX/drive_c"   # Z: 없이도 되도록 C:에서 실행 (드라이브 밖 exe는 Z: 없으면 원래 Wine에서도 크래시)
$W/bin/wine C:/python/python.exe C:/menu_widgets.py windows11
$W/bin/wine C:/python/python.exe C:/menu_qml.py
```

자동 확인: Xvfb에서 XTest로 우클릭/클릭을 보내고 출력을 보면 됩니다.

확인할 것: `menu_widgets.py windows11 kakao`(카카오톡 메뉴와 같은 창 속성)에서 항목을 누르면 `TRIGGERED`가 찍히는지. 0008이 없는 Wine에서는 KWin에서 찍히지 않습니다.
