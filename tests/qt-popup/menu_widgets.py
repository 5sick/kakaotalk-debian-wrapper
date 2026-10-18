import sys
from PySide6.QtWidgets import QApplication, QWidget, QMenu
from PySide6.QtGui import QAction
from PySide6.QtCore import Qt, QTimer

app = QApplication(sys.argv)
if len(sys.argv) > 1: app.setStyle(sys.argv[1])
print("style", app.style().name(), flush=True)
w = QWidget(); w.setWindowTitle("widgets"); w.setGeometry(100, 100, 400, 300)
def ctx(pos):
    m = QMenu(w)
    for name in ("알림 끄기", "나가기"):
        a = QAction(name, m); a.triggered.connect(lambda c=False, n=name: print("TRIGGERED", n, flush=True)); m.addAction(a)
    m.exec(w.mapToGlobal(pos))
w.setContextMenuPolicy(Qt.CustomContextMenu); w.customContextMenuRequested.connect(ctx)
w.show()
QTimer.singleShot(20000, app.quit)
app.exec()
