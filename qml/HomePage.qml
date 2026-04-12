import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    function reload() {
        const s = TxService.getSummary()
        incomeLabel.amountValue = s.totalIncome
        expenseLabel.amountValue = s.totalExpense
        balanceLabel.amountValue = s.balance
    }

    Component.onCompleted: Qt.callLater(function () {
        reload()
    })

    Connections {
        target: TxService
        function onDataChanged() {
            page.reload()
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            Label {
                text: qsTr("财务概览")
                font.pixelSize: 22
                font.bold: true
                Layout.topMargin: 8
                Layout.leftMargin: 16
            }

            GridLayout {
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                Label {
                    text: qsTr("总收入")
                    color: "#2E7D32"
                }
                MoneyLabel {
                    id: incomeLabel
                    Layout.fillWidth: true
                    color: "#2E7D32"
                }

                Label {
                    text: qsTr("总支出")
                    color: "#C62828"
                }
                MoneyLabel {
                    id: expenseLabel
                    Layout.fillWidth: true
                    color: "#C62828"
                }

                Label {
                    text: qsTr("结余")
                    font.bold: true
                }
                MoneyLabel {
                    id: balanceLabel
                    Layout.fillWidth: true
                    font.bold: true
                }
            }

            Label {
                text: qsTr("提示：在「记账」页快速录入，在「记录」页可按条件搜索。")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                opacity: 0.75
            }
        }
    }

    component MoneyLabel: Label {
        property real amountValue: 0
        horizontalAlignment: Text.AlignRight
        text: Number(amountValue).toFixed(2)
        font.pixelSize: 16
    }
}
