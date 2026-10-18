import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QTimer
app = QGuiApplication(sys.argv)
e = QQmlApplicationEngine()
e.loadData(b'''
import QtQuick
import QtQuick.Controls
Window {
    id: root
    signal triggered(string name)
    x: 100; y: 100; width: 400; height: 300; visible: true; title: "qml"
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.RightButton
        onClicked: (m) => { menu.x = m.x; menu.y = m.y; menu.open() } }
    Menu { id: menu; popupType: Popup.Window
        MenuItem { text: "Mute"; onTriggered: root.triggered("mute") }
        MenuItem { text: "Leave"; onTriggered: root.triggered("leave") } }
}''')
e.rootObjects()[0].triggered.connect(lambda n: print("TRIGGERED", n, flush=True))
QTimer.singleShot(20000, app.quit)
app.exec()
