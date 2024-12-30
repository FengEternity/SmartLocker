import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccessful()

    Column {
        spacing: 10
        anchors.centerIn: parent

        ComboBox {
            id: statusComboBox
            width: 210
            model: ["快递员", "管理员", "取件人"]
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
            spacing: 10 // 按钮之间的间距

            Button {
                text: "登陆"
                width: 100 // 设置按钮宽度
                onClicked: {
                    loginManager.attemptLogin(usernameInput.text, passwordInput.text)
                }
            }

            Button {
                text: "注册"
                width: 100 // 设置按钮宽度
            }
        }
    }

    Connections {
        target: loginManager
        onLoginSuccessful: loginSuccessful()
        onLoginFailed: {
            usernameInput.text = ""
            passwordInput.text = ""
            loginFailedDialog.open()
        }
    }

    Dialog {
        id: loginFailedDialog
        title: "登录失败"
        width: 256
        height: 128
        contentItem: Text {
            text: "登陆失败，请重试！"
            color: "white"
        }
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
    }
}
