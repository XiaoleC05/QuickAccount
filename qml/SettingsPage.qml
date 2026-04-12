import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 12

            Label {
                text: qsTr("设置")
                font.pixelSize: 20
                font.bold: true
                Layout.topMargin: 8
                Layout.leftMargin: 16
            }

            Label {
                text: qsTr("版本：第一版（本地 SQLite）")
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("数据库文件路径：")
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                font.bold: true
            }

            TextArea {
                id: pathArea
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                readOnly: true
                wrapMode: Text.Wrap
                text: TxService.databaseFilePath()
            }

            Button {
                text: qsTr("刷新路径")
                Layout.leftMargin: 16
                onClicked: pathArea.text = TxService.databaseFilePath()
            }
        }
    }
}
