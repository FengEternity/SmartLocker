import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System"

    Material.theme: Material.Dark
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
        Item {
            Column {
                spacing: 10
                anchors.centerIn: parent

                Text {
                    text: "管理员主页"
                    font.pixelSize: 24
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "修改快递柜状态"
                    onClicked: console.log("修改快递柜状态功能")
                }

                Button {
                    text: "查看滞留快递"
                    onClicked: console.log("查看滞留快递功能")
                }

                Button {
                    text: "分配柜口"
                    onClicked: console.log("分配柜口功能")
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
