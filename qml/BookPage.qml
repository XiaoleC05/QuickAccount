import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    property string txType: "expense"
    readonly property int horizontalMargin: 16
    readonly property bool amountValid: {
        const amt = Number(String(amountField.text).replace(",", "."))
        return isFinite(amt) && amt > 0
    }
    readonly property bool dateValid: {
        const t = dateField.text.trim()
        if (!/^\d{4}-\d{2}-\d{2}$/.test(t))
            return false
        const d = new Date(`${t}T00:00:00`)
        return !isNaN(d.getTime()) && (d.toISOString().slice(0, 10) === t)
    }
    readonly property bool formValid: amountValid && dateValid

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
                Layout.leftMargin: page.horizontalMargin
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
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
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin

                Label {
                    text: qsTr("金额")
                }
                TextField {
                    id: amountField
                    Layout.fillWidth: true
                    text: "1.00"
                    placeholderText: "12.34"
                    selectByMouse: true
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
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
                    inputMask: "0000-00-00"
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
                    onAccepted: saveButton.clicked()
                }
            }

            Label {
                visible: !page.dateValid && dateField.text.trim().length > 0
                text: qsTr("日期格式应为 yyyy-MM-dd，且必须是有效日期")
                color: "#C62828"
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
                wrapMode: Text.Wrap
            }

            Button {
                id: saveButton
                text: qsTr("保存")
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
                highlighted: true
                enabled: page.formValid
                onClicked: {
                    const amt = Number(String(amountField.text).replace(",", "."))
                    if (!isFinite(amt) || amt <= 0) {
                        tip.text = qsTr("金额无效，请输入大于 0 的数字")
                        tipTimer.restart()
                        return
                    }
                    const ok = TxService.addTransaction(
                                page.txType,
                                amt,
                                categoryBox.currentText,
                                dateField.text.trim(),
                                descField.text,
                                paymentBox.currentText)
                    if (ok) {
                        tip.text = qsTr("已保存")
                        amountField.text = "1.00"
                        descField.text = ""
                        dateField.text = todayString()
                        amountField.forceActiveFocus()
                        amountField.selectAll()
                    } else {
                        tip.text = qsTr("保存失败，请检查输入后重试")
                    }
                    tipTimer.restart()
                }
            }

            Label {
                id: tip
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
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
