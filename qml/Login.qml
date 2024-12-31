import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccessful(string role) // 登录成功信号，传递用户角色

    Loader {
        id: pageLoader
        anchors.fill: parent
        onLoaded: {
            if (item) {
                item.backToLogin.connect(function() {
                    pageLoader.source = ""
                })
            }
        }
    }

    Column {
        spacing: 10
        anchors.centerIn: parent
        visible: pageLoader.status === Loader.Null

        ComboBox {
            id: roleComboBox
            width: 210
            model: ["快递员", "管理员", "取件人"]

            // 映射角色
            property var roleMap: {
                "快递员": "deliver",
                "管理员": "admin",
                "取件人": "user"
            }

            function getSelectedRole() {
                return roleMap[currentText];
            }
        }

        TextField {
            id: usernameInput
            width: 210
            placeholderText: "账号"
        }

        TextField {
            id: passwordInput
            width: 210
            placeholderText: "密码"
            echoMode: TextInput.Password
        }

        Row {
            spacing: 10

            Button {
                text: "登录"
                width: 100
                onClicked: {
                    // 模拟身份校验，登录成功后传递角色信息
                    if (usernameInput.text !== "" && passwordInput.text !== "") {
                        loginSuccessful(roleComboBox.getSelectedRole())
                    } else {
                        loginFailedDialog.open()
                    }
                }
            }

            Button {
                text: "注册"
                width: 100
                onClicked: {
                    pageLoader.source = "Register.qml"
                }
            }
        }
    }

    Dialog {
        id: loginFailedDialog
        title: "登录失败"
        width: 256
        height: 128
        anchors.centerIn: parent
        contentItem: Text {
            text: "账号或密码错误，请重试！"
            color: "white"
        }
        standardButtons: Dialog.Ok
        onAccepted: loginFailedDialog.close()
    }
}