import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page

    property var records: []
    readonly property int horizontalMargin: 12
    property string sortMode: "date_desc"

    function todayString() {
        const d = new Date()
        return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`
    }

    function refresh() {
        const kw = keywordField.text
        const type = typeFilter.currentIndex === 0 ? "" : typeFilter.currentValue
        const cat = categoryFilter.currentIndex === 0 ? "" : categoryFilter.currentText
        const pay = paymentFilter.currentIndex === 0 ? "" : paymentFilter.currentText
        const sd = startDateField.text.trim()
        const ed = endDateField.text.trim()

        function amountOrSentinel(fieldText) {
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

        const minA = amountOrSentinel(minAmountField.text)
        const maxA = amountOrSentinel(maxAmountField.text)
        let nextRows = TxService.searchTransactions(kw, cat, pay, sd, ed, minA, maxA)
        if (type !== "")
            nextRows = nextRows.filter(r => r.type === type)
        if (sortMode === "amount_desc") {
            nextRows = nextRows.slice().sort((a, b) => Number(b.amount) - Number(a.amount))
        } else if (sortMode === "amount_asc") {
            nextRows = nextRows.slice().sort((a, b) => Number(a.amount) - Number(b.amount))
        } else if (sortMode === "date_asc") {
            nextRows = nextRows.slice().sort((a, b) => a.date === b.date ? Number(a.id) - Number(b.id) : (a.date < b.date ? -1 : 1))
        } else {
            nextRows = nextRows.slice().sort((a, b) => a.date === b.date ? Number(b.id) - Number(a.id) : (a.date > b.date ? -1 : 1))
        }
        records = nextRows
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
            Layout.leftMargin: page.horizontalMargin
            Layout.rightMargin: page.horizontalMargin
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
            Layout.leftMargin: page.horizontalMargin
            Layout.rightMargin: page.horizontalMargin
            Layout.preferredHeight: 150
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            GridLayout {
                width: filterScroll.availableWidth
                columns: 2
                rowSpacing: 8
                columnSpacing: 10

                Label {
                    text: qsTr("类型")
                }
                ComboBox {
                    id: typeFilter
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        {text: qsTr("全部"), value: ""},
                        {text: qsTr("支出"), value: "expense"},
                        {text: qsTr("收入"), value: "income"}
                    ]
                    onActivated: page.refresh()
                }

                Label {
                    text: qsTr("分类")
                }
                ComboBox {
                    id: categoryFilter
                    Layout.fillWidth: true
                    model: [qsTr("全部")].concat(TxService.categoryOptions())
                    onActivated: page.refresh()
                }

                Label {
                    text: qsTr("支付方式")
                }
                ComboBox {
                    id: paymentFilter
                    Layout.fillWidth: true
                    model: [qsTr("全部")].concat(TxService.paymentMethodOptions())
                    onActivated: page.refresh()
                }

                Label {
                    text: qsTr("开始日期")
                }
                TextField {
                    id: startDateField
                    Layout.fillWidth: true
                    placeholderText: "2026-01-01"
                    selectByMouse: true
                    inputMask: "0000-00-00"
                    onAccepted: page.refresh()
                }

                Label {
                    text: qsTr("结束日期")
                }
                TextField {
                    id: endDateField
                    Layout.fillWidth: true
                    placeholderText: "2026-12-31"
                    selectByMouse: true
                    inputMask: "0000-00-00"
                    onAccepted: page.refresh()
                }

                Label {
                    text: qsTr("最小金额")
                }
                TextField {
                    id: minAmountField
                    Layout.fillWidth: true
                    placeholderText: qsTr("留空表示不限制")
                    selectByMouse: true
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: DoubleValidator {
                        bottom: 0
                        top: 100000000
                        notation: DoubleValidator.StandardNotation
                        decimals: 2
                    }
                    onAccepted: page.refresh()
                }

                Label {
                    text: qsTr("最大金额")
                }
                TextField {
                    id: maxAmountField
                    Layout.fillWidth: true
                    placeholderText: qsTr("留空表示不限制")
                    selectByMouse: true
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: DoubleValidator {
                        bottom: 0
                        top: 100000000
                        notation: DoubleValidator.StandardNotation
                        decimals: 2
                    }
                    onAccepted: page.refresh()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: page.horizontalMargin
            Layout.rightMargin: page.horizontalMargin
            spacing: 8
            Button {
                text: qsTr("今天")
                onClicked: {
                    startDateField.text = page.todayString()
                    endDateField.text = page.todayString()
                    page.refresh()
                }
            }
            Button {
                text: qsTr("近7天")
                onClicked: {
                    const now = new Date()
                    const start = new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000)
                    startDateField.text = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, "0")}-${String(start.getDate()).padStart(2, "0")}`
                    endDateField.text = page.todayString()
                    page.refresh()
                }
            }
            Button {
                text: qsTr("本月")
                onClicked: {
                    const now = new Date()
                    startDateField.text = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`
                    endDateField.text = page.todayString()
                    page.refresh()
                }
            }
            Item { Layout.fillWidth: true }
            ComboBox {
                id: sortBox
                Layout.preferredWidth: 170
                textRole: "text"
                valueRole: "value"
                model: [
                    {text: qsTr("日期：新到旧"), value: "date_desc"},
                    {text: qsTr("日期：旧到新"), value: "date_asc"},
                    {text: qsTr("金额：大到小"), value: "amount_desc"},
                    {text: qsTr("金额：小到大"), value: "amount_asc"}
                ]
                onActivated: {
                    page.sortMode = currentValue
                    page.refresh()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: page.horizontalMargin
            Layout.rightMargin: page.horizontalMargin
            Button {
                text: qsTr("重置条件")
                onClicked: {
                    keywordField.text = ""
                    typeFilter.currentIndex = 0
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
            visible: page.records.length > 0

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

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: page.horizontalMargin
            Layout.rightMargin: page.horizontalMargin
            Layout.alignment: Qt.AlignHCenter
            visible: page.records.length === 0
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("暂无匹配记录，试试放宽筛选条件。")
            opacity: 0.7
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
