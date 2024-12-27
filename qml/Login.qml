import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccessful()

    Column {
        spacing: 10
        anchors.centerIn: parent

        TextField {
            id: usernameInput
            width: 215
            placeholderText: "账号"
        }

        TextField {
            id: passwordInput
            width: 215
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
            console.log("登陆失败，请重试！")
        }
    }
}
