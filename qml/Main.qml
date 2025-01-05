import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "智能快递柜系统"

    Material.theme: Material.Light
    Material.primary: "#6200EE"
    Material.accent: "#03DAC5"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: function(role) {
                if (role === "deliveryWorker") {
                    stackView.push(deliveryWorkerPage)
                } else if (role === "admin") {
                    stackView.push(adminPage)
                } else if (role === "user") {
                    stackView.push(userPage)
                }
            }
        }
    }

    Component {
        id: deliveryWorkerPage
        Item {
            Column {
                spacing: 10
                anchors.centerIn: parent

                Text {
                    text: "快递员主页"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "录入快递信息"
                    onClicked: console.log("录入快递信息功能")
                }

                Button {
                    text: "存放快递"
                    onClicked: console.log("存放快递功能")
                }

                Button {
                    text: "查询快递使用状态"
                    onClicked: console.log("查询快递状态功能")
                }
            }
        }
    }

    Component {
        id: adminPage
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "管理员主页"
                        font.pixelSize: 20
                        elide: Label.ElideRight
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        text: qsTr("退出")
                        onClicked: stackView.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // 储物柜状态卡片
                Pane {
                    Layout.fillWidth: true
                    Material.elevation: 2
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Label {
                            text: "储物柜状态"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        GridView {
                            Layout.fillWidth: true
                            height: 300
                            cellWidth: 150
                            cellHeight: 80
                            model: packageManager.getAvailableLockers()
                            
                            delegate: ItemDelegate {
                                width: 140
                                height: 70
                                
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    radius: 5
                                    color: packageManager.isLockerAvailable(modelData) ? "#E8F5E9" : "#FFEBEE"
                                    border.color: packageManager.isLockerAvailable(modelData) ? "#81C784" : "#EF9A9A"

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 5

                                        Label {
                                            text: "柜号: " + modelData
                                            font.pixelSize: 16
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label {
                                            text: packageManager.isLockerAvailable(modelData) ? "空闲" : "使用中"
                                            color: packageManager.isLockerAvailable(modelData) ? "#2E7D32" : "#C62828"
                                            font.pixelSize: 14
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 操作按钮区域
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Button {
                        text: "修改快递柜状态"
                        Layout.fillWidth: true
                        Material.background: Material.primary
                        highlighted: true
                        onClicked: statusDialog.open()
                    }

                    Button {
                        text: "查看超时快递"
                        Layout.fillWidth: true
                        Material.background: Material.accent
                        highlighted: true
                        onClicked: {
                            var overduePackages = packageManager.getOverduePackages()
                            overdueDialog.text = overduePackages.length > 0 
                                ? "超时快递列表:\n" + overduePackages.join("\n")
                                : "没有超时快递"
                            overdueDialog.open()
                        }
                    }
                }
            }

            Dialog {
                id: statusDialog
                title: "修改快递柜状态"
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 300
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel

                ColumnLayout {
                    spacing: 20
                    width: parent.width

                    ComboBox {
                        id: lockerSelector
                        model: packageManager.getAvailableLockers()
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                    }

                    ComboBox {
                        id: statusSelector
                        model: ["空闲", "使用中", "维修中"]
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                    }
                }

                onAccepted: {
                    packageManager.updateLockerStatus(
                        lockerSelector.currentText,
                        statusSelector.currentText
                    )
                }
            }

            Dialog {
                id: overdueDialog
                title: "超时快递"
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 400
                modal: true
                standardButtons: Dialog.Ok

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Text {
                        id: overdueText
                        text: ""
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }
    }

    Component {
        id: userPage
        Item {
            Column {
                spacing: 10
                anchors.centerIn: parent

                Text {
                    text: "取件人主页"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                }

                TextField {
                    id: pickupCodeInput
                    width: 200
                    placeholderText: "请输入取件码"
                }

                Button {
                    text: "取件"
                    onClicked: {
                        if (pickupCodeInput.text !== "") {
                            console.log("验证取件码，执行取件操作")
                        } else {
                            console.log("取件码不能为空")
                        }
                    }
                }
            }
        }
    }
}
