import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    width: Qt.platform.os === "android" ? Screen.width : 980
    height: Qt.platform.os === "android" ? Screen.height : 640
    visible: true
    title: qsTr("快账 QuickAccount")
    color: "#F5F7FB"

    palette.window: "#F5F7FB"
    palette.base: "white"
    palette.button: "white"
    palette.highlight: "#2D7DFA"
    palette.buttonText: "#1D2433"
    palette.windowText: "#1D2433"
    palette.text: "#1D2433"

    header: ToolBar {
        background: Rectangle {
            color: "white"
            border.color: "#E6EAF2"
        }
        RowLayout {
            anchors.fill: parent
            spacing: 12
            Label {
                text: qsTr("快账")
                font.pixelSize: 18
                font.bold: true
                Layout.leftMargin: 12
            }
            Label {
                text: qsTr("本地离线记账")
                opacity: 0.6
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
        }
    }

    footer: TabBar {
        id: tabs
        spacing: 4
        TabButton {
            text: qsTr("首页")
        }
        TabButton {
            text: qsTr("记账")
        }
        TabButton {
            text: qsTr("记录")
        }
        TabButton {
            text: qsTr("设置")
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: tabs.currentIndex

        Loader {
            asynchronous: true
            active: stack.currentIndex === 0
            source: active ? Qt.resolvedUrl("HomePage.qml") : ""
        }
        Loader {
            asynchronous: true
            active: stack.currentIndex === 1
            source: active ? Qt.resolvedUrl("BookPage.qml") : ""
        }
        Loader {
            asynchronous: true
            active: stack.currentIndex === 2
            source: active ? Qt.resolvedUrl("RecordsPage.qml") : ""
        }
        Loader {
            asynchronous: true
            active: stack.currentIndex === 3
            source: active ? Qt.resolvedUrl("SettingsPage.qml") : ""
        }
    }
}
