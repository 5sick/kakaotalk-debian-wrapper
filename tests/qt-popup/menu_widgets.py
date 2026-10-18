import sys
from PySide6.QtWidgets import QApplication, QWidget, QMenu
from PySide6.QtGui import QAction
from PySide6.QtCore import Qt, QTimer

app = QApplication(sys.argv)
# "kakao": 카카오톡 메뉴 창처럼 WS_CAPTION + WS_EX_NOACTIVATE 스타일을 준다 (창 관리자가 관리하는 창이 됨)
kakao = "kakao" in sys.argv[1:]
style = [a for a in sys.argv[1:] if a != "kakao"]
if style: app.setStyle(style[0])
print("style", app.style().name(), flush=True)
w = QWidget(); w.setWindowTitle("widgets"); w.setGeometry(100, 100, 400, 300)
def ctx(pos):
    m = QMenu(w)
    for name in ("알림 끄기", "나가기"):
        a = QAction(name, m); a.triggered.connect(lambda c=False, n=name: print("TRIGGERED", n, flush=True)); m.addAction(a)
    if kakao:
        def restyle():   # Qt가 표시할 때 스타일을 다시 정하므로 표시 뒤에 준다
            import ctypes
            u = ctypes.windll.user32
            u.GetWindowLongW.restype = u.SetWindowLongW.restype = ctypes.c_long
            h = int(m.winId())
            u.SetWindowLongW(h, -16, u.GetWindowLongW(h, -16) | 0x00C00000)   # GWL_STYLE |= WS_CAPTION
            u.SetWindowLongW(h, -20, u.GetWindowLongW(h, -20) | 0x08000000)   # GWL_EXSTYLE |= WS_EX_NOACTIVATE
            u.SetWindowPos(h, 0, 0, 0, 0, 0, 0x37)   # SWP_FRAMECHANGED|NOACTIVATE|NOZORDER|NOMOVE|NOSIZE
        QTimer.singleShot(100, restyle)
    m.exec(w.mapToGlobal(pos))
w.setContextMenuPolicy(Qt.CustomContextMenu); w.customContextMenuRequested.connect(ctx)
w.show()
QTimer.singleShot(20000, app.quit)
app.exec()
