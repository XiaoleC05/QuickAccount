import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    property var records: []

    function refresh() {
        const kw = keywordField.text
        const cat = categoryFilter.currentIndex === 0 ? "" : categoryFilter.currentText
        const pay = paymentFilter.currentIndex === 0 ? "" : paymentFilter.currentText
        const sd = startDateField.text.trim()
        const ed = endDateField.text.trim()

        function amountOrSentinel(fieldText, isMax) {
            const t = fieldText.trim()
            if (t === "")
                return -1
            const v = Number(String(t).replace(",", "."))
            if (!isFinite(v))
                return -1
            if (v < 0)
                return -1
            return v
        }

        const minA = amountOrSentinel(minAmountField.text, false)
        const maxA = amountOrSentinel(maxAmountField.text, true)
        records = TxService.searchTransactions(kw, cat, pay, sd, ed, minA, maxA)
    }

    Component.onCompleted: Qt.callLater(function () {
        refresh()
    })

    Connections {
        target: TxService
        function onDataChanged() {
            page.refresh()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.topMargin: 8
            spacing: 8

            TextField {
                id: keywordField
                Layout.fillWidth: true
                placeholderText: qsTr("搜索备注…")
                selectByMouse: true
                onAccepted: page.refresh()
            }
            Button {
                text: qsTr("搜索")
                highlighted: true
                onClicked: page.refresh()
            }
        }

        ScrollView {
            id: filterScroll
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.preferredHeight: 150
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            GridLayout {
                width: filterScroll.availableWidth
                columns: 2
                rowSpacing: 8
                columnSpacing: 10

                Label {
                    text: qsTr("分类")
                }
                ComboBox {
                    id: categoryFilter
                    Layout.fillWidth: true
                    model: [qsTr("全部")].concat(TxService.categoryOptions())
                }

                Label {
                    text: qsTr("支付方式")
                }
                ComboBox {
                    id: paymentFilter
                    Layout.fillWidth: true
                    model: [qsTr("全部")].concat(TxService.paymentMethodOptions())
                }

                Label {
                    text: qsTr("开始日期")
                }
                TextField {
                    id: startDateField
                    Layout.fillWidth: true
                    placeholderText: "2026-01-01"
                    selectByMouse: true
                }

                Label {
                    text: qsTr("结束日期")
                }
                TextField {
                    id: endDateField
                    Layout.fillWidth: true
                    placeholderText: "2026-12-31"
                    selectByMouse: true
                }

                Label {
                    text: qsTr("最小金额")
                }
                TextField {
                    id: minAmountField
                    Layout.fillWidth: true
                    placeholderText: qsTr("留空表示不限制")
                    selectByMouse: true
                }

                Label {
                    text: qsTr("最大金额")
                }
                TextField {
                    id: maxAmountField
                    Layout.fillWidth: true
                    placeholderText: qsTr("留空表示不限制")
                    selectByMouse: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Button {
                text: qsTr("重置条件")
                onClicked: {
                    keywordField.text = ""
                    categoryFilter.currentIndex = 0
                    paymentFilter.currentIndex = 0
                    startDateField.text = ""
                    endDateField.text = ""
                    minAmountField.text = ""
                    maxAmountField.text = ""
                    page.refresh()
                }
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("共 %1 条").arg(page.records.length)
                opacity: 0.75
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            opacity: 0.12
            color: "black"
        }

        ListView {
            id: lv
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: page.records.length
            spacing: 8

            delegate: Frame {
                id: rowFrame
                width: lv.width

                property var row: page.records[index]

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Label {
                            text: row.description && row.description.length > 0 ? row.description : qsTr("(无备注)")
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            font.pixelSize: 14
                        }
                        Label {
                            text: `${row.date} · ${row.category} · ${row.paymentMethod}`
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            opacity: 0.75
                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        spacing: 6
                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: row.type === "income" ? (`+` + Number(row.amount).toFixed(2)) : (`-` + Number(row.amount).toFixed(2))
                            color: row.type === "income" ? "#2E7D32" : "#C62828"
                            font.bold: true
                        }
                        Button {
                            text: qsTr("删除")
                            flat: true
                            onClicked: {
                                delDialog.delId = row.id
                                delDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: delDialog
        parent: Overlay.overlay
        property int delId: -1
        title: qsTr("删除这条记录？")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: {
            if (delId > 0)
                TxService.deleteTransaction(delId)
        }
    }
}
