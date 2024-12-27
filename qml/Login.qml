import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccessful()

    Column {
        spacing: 10
        anchors.centerIn: parent

        TextField {
            id: usernameInput
            placeholderText: "账号"
        }

        TextField {
            id: passwordInput
            placeholderText: "密码"
            echoMode: TextInput.Password
        }

        Button {
            text: "登陆"
            onClicked: {
                loginManager.attemptLogin(usernameInput.text, passwordInput.text)
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