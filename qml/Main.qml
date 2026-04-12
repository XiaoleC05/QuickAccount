import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 980
    height: 640
    visible: true
    title: qsTr("快账 QuickAccount")

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 12
            Label {
                text: qsTr("快账")
                font.pixelSize: 18
                font.bold: true
                Layout.leftMargin: 12
            }
            Item { Layout.fillWidth: true }
        }
    }

    footer: TabBar {
        id: tabs
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
