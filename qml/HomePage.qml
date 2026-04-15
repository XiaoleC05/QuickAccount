import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: page
    readonly property int horizontalMargin: 16
    property var recentRows: []
    property real totalIncome: 0
    property real totalExpense: 0
    property real balance: 0

    function reload() {
        const s = TxService.getSummary()
        totalIncome = Number(s.totalIncome || 0)
        totalExpense = Number(s.totalExpense || 0)
        balance = Number(s.balance || 0)

        const rows = TxService.getTransactions()
        const sorted = rows.slice().sort((a, b) => {
                                       if (a.date === b.date)
                                           return Number(b.id) - Number(a.id)
                                       return a.date > b.date ? -1 : 1
                                   })
        recentRows = sorted.slice(0, 5)
    }

    function expenseRatio() {
        const total = totalIncome + totalExpense
        if (total <= 0)
            return 0
        return totalExpense / total
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
                Layout.leftMargin: page.horizontalMargin
            }

            GridLayout {
                columns: width >= 700 ? 3 : 1
                rowSpacing: 10
                columnSpacing: 12
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin

                SummaryCard {
                    title: qsTr("总收入")
                    amountValue: page.totalIncome
                    amountColor: "#2E7D32"
                }
                SummaryCard {
                    title: qsTr("总支出")
                    amountValue: page.totalExpense
                    amountColor: "#C62828"
                }
                SummaryCard {
                    title: qsTr("结余")
                    amountValue: page.balance
                    amountColor: page.balance >= 0 ? "#1D2433" : "#C62828"
                }
            }

            Frame {
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
                background: Rectangle {
                    radius: 10
                    color: "white"
                    border.color: "#E6EAF2"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Label {
                        text: qsTr("收支占比（支出占 %1%）").arg(Math.round(page.expenseRatio() * 100))
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        radius: 5
                        color: "#E9EEF8"
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * page.expenseRatio()
                            radius: 5
                            color: "#2D7DFA"
                        }
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
                Layout.bottomMargin: 8
                background: Rectangle {
                    radius: 10
                    color: "white"
                    border.color: "#E6EAF2"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: qsTr("最近记录")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Repeater {
                        model: page.recentRows
                        delegate: RowLayout {
                            width: parent.width
                            spacing: 8
                            Label {
                                text: `${modelData.date} · ${modelData.category}`
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Label {
                                text: modelData.type === "income" ? qsTr("收入") : qsTr("支出")
                                color: modelData.type === "income" ? "#2E7D32" : "#C62828"
                            }
                            Label {
                                text: `${modelData.type === "income" ? "+" : "-"}${Number(modelData.amount).toFixed(2)}`
                                font.bold: true
                            }
                        }
                    }

                    Label {
                        visible: page.recentRows.length === 0
                        text: qsTr("还没有记录，去“记账”页添加第一笔吧。")
                        opacity: 0.7
                    }
                }
            }

            Label {
                text: qsTr("提示：在「记账」页快速录入，在「记录」页可按条件搜索。")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.leftMargin: page.horizontalMargin
                Layout.rightMargin: page.horizontalMargin
                opacity: 0.75
            }
        }
    }

    component SummaryCard: Frame {
        property string title: ""
        property real amountValue: 0
        property color amountColor: "#1D2433"
        Layout.fillWidth: true
        background: Rectangle {
            radius: 10
            color: "white"
            border.color: "#E6EAF2"
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: 4
            Label {
                text: title
                opacity: 0.75
            }
            Label {
                text: Number(amountValue).toFixed(2)
                color: amountColor
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}
