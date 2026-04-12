import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    property string txType: "expense"

    function todayString() {
        const d = new Date()
        const y = d.getFullYear()
        const m = String(d.getMonth() + 1).padStart(2, "0")
        const day = String(d.getDate()).padStart(2, "0")
        return `${y}-${m}-${day}`
    }

    Component.onCompleted: {
        dateField.text = todayString()
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 14

            Label {
                text: qsTr("快速记账")
                font.pixelSize: 20
                font.bold: true
                Layout.topMargin: 8
                Layout.leftMargin: 16
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 10

                Button {
                    text: qsTr("支出")
                    checkable: true
                    checked: page.txType === "expense"
                    onClicked: page.txType = "expense"
                }
                Button {
                    text: qsTr("收入")
                    checkable: true
                    checked: page.txType === "income"
                    onClicked: page.txType = "income"
                }
                Item { Layout.fillWidth: true }
            }

            GridLayout {
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                Label {
                    text: qsTr("金额")
                }
                TextField {
                    id: amountField
                    Layout.fillWidth: true
                    text: "1.00"
                    placeholderText: "12.34"
                    selectByMouse: true
                    validator: DoubleValidator {
                        bottom: 0.01
                        top: 100000000
                        notation: DoubleValidator.StandardNotation
                        decimals: 2
                    }
                }

                Label {
                    text: qsTr("日期 yyyy-MM-dd")
                }
                TextField {
                    id: dateField
                    Layout.fillWidth: true
                    placeholderText: "2026-04-13"
                    selectByMouse: true
                }

                Label {
                    text: qsTr("分类")
                }
                ComboBox {
                    id: categoryBox
                    Layout.fillWidth: true
                    model: TxService.categoryOptions()
                }

                Label {
                    text: qsTr("支付方式")
                }
                ComboBox {
                    id: paymentBox
                    Layout.fillWidth: true
                    model: TxService.paymentMethodOptions()
                }

                Label {
                    text: qsTr("备注")
                }
                TextField {
                    id: descField
                    Layout.fillWidth: true
                    placeholderText: qsTr("可填写商家、用途等")
                    selectByMouse: true
                }
            }

            Button {
                text: qsTr("保存")
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                highlighted: true
                onClicked: {
                    const amt = Number(String(amountField.text).replace(",", "."))
                    if (!isFinite(amt) || amt <= 0) {
                        tip.text = qsTr("金额无效，请输入大于 0 的数字")
                        tipTimer.restart()
                        return
                    }
                    TxService.addTransaction(
                                page.txType,
                                amt,
                                categoryBox.currentText,
                                dateField.text.trim(),
                                descField.text,
                                paymentBox.currentText)
                    tip.text = qsTr("已保存")
                    tipTimer.restart()
                }
            }

            Label {
                id: tip
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                wrapMode: Text.Wrap
                opacity: 0.85
            }

            Timer {
                id: tipTimer
                interval: 1600
                onTriggered: tip.text = ""
            }
        }
    }
}
