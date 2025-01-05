import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

pragma ComponentBehavior: Bound

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "智能快递柜系统"

    Material.theme: Material.Light
    Material.primary: "#C6E092"
    Material.accent: "#F7F7D2"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: function(role) {
                if (role === "deliver") {
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
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "快递员主页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
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

                // 快递信息输入区域
                Pane {
                    Layout.fillWidth: true
                    Material.elevation: 2

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        Label {
                            text: "录入快递信息"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: receiverPhone
                            Layout.fillWidth: true
                            placeholderText: "收件人手机号"
                            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                        }

                        ComboBox {
                            id: lockerSelector
                            Layout.fillWidth: true
                            model: packageManager.getAvailableLockers()
                            textRole: "display"
                            valueRole: "lockerId"
                            displayText: currentText ? "选择柜号: " + currentText : "请选择储物柜"
                        }

                        Button {
                            text: "存放快递"
                            Layout.fillWidth: true
                            enabled: receiverPhone.acceptableInput && lockerSelector.currentText
                            highlighted: true
                            Material.background: Material.primary

                            onClicked: {
                                var result = packageManager.depositPackage(
                                    receiverPhone.text,
                                    parseInt(lockerSelector.currentText),
                                    loginManager.currentUser
                                )
                                if (result.success) {
                                    depositDialog.message = "快递存放成功！\n取件码：" + result.pickupCode
                                    depositDialog.open()
                                    // 清空输入
                                    receiverPhone.text = ""
                                    lockerSelector.currentIndex = -1
                                } else {
                                    errorDialog.message = "存放失败：" + result.message
                                    errorDialog.open()
                                }
                            }
                        }
                    }
                }

                // 快递查询区域
                Pane {
                    Layout.fillWidth: true
                    Material.elevation: 2

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        Label {
                            text: "快递查询"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: queryPhone
                            Layout.fillWidth: true
                            placeholderText: "输入手机号查询快递"
                            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                        }

                        Button {
                            text: "查询"
                            Layout.fillWidth: true
                            enabled: queryPhone.acceptableInput
                            highlighted: true
                            Material.background: Material.accent

                            onClicked: {
                                var packages = packageManager.queryPackagesByPhone(queryPhone.text)
                                queryDialog.message = packages || "未找到相关快递"
                                queryDialog.open()
                            }
                        }
                    }
                }
            }

            // 对话框
            Dialog {
                id: depositDialog
                property string message: ""
                title: "存放结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    text: depositDialog.message
                    wrapMode: Text.WordWrap
                }
            }

            Dialog {
                id: queryDialog
                property string message: ""
                title: "查询结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 400

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Label {
                        text: queryDialog.message
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Dialog {
                id: errorDialog
                property string message: ""
                title: "错误"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    text: errorDialog.message
                    wrapMode: Text.WordWrap
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
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "取件人主页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
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

                TextField {
                    id: pickupCodeInput
                    Layout.fillWidth: true
                    placeholderText: "请输入取件码"
                    validator: RegularExpressionValidator { regularExpression: /^\d{6}$/ }
                }

                Button {
                    text: "取件"
                    Layout.fillWidth: true
                    enabled: pickupCodeInput.acceptableInput
                    onClicked: {
                        var result = packageManager.pickupPackage(pickupCodeInput.text)
                        resultDialog.message = result.success ? 
                            "取件成功！\n柜号：" + result.lockerNumber : 
                            "取件失败：" + result.message
                        resultDialog.open()
                    }
                }

                TextField {
                    id: phoneQueryInput
                    Layout.fillWidth: true
                    placeholderText: "请输入手机号查询取件码"
                    validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                }

                Button {
                    text: "查询取件码"
                    Layout.fillWidth: true
                    enabled: phoneQueryInput.acceptableInput
                    onClicked: {
                        var codes = packageManager.getPickupCodes(phoneQueryInput.text)
                        queryDialog.message = codes.length > 0 ?
                            "您的取件码：\n" + codes.join("\n") :
                            "没有找到相关取件码"
                        queryDialog.open()
                    }
                }
            }

            Dialog {
                id: resultDialog
                property string message: ""
                title: "取件结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    text: resultDialog.message
                    wrapMode: Text.WordWrap
                }
            }

            Dialog {
                id: queryDialog
                property string message: ""
                title: "取件码查询"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Label {
                    text: queryDialog.message
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
