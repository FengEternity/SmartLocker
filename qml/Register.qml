import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal backToLogin()

    Column {
        spacing: 10
        anchors.centerIn: parent

        TextField {
            id: newUsernameInput
            width: 210
            placeholderText: "新账号"
        }

        TextField {
            id: newPasswordInput
            width: 210
            placeholderText: "新密码"
            echoMode: TextInput.Password
        }

        Row {
            spacing: 10

            Button {
                text: "注册"
                width: 100
                onClicked: {
                    // 在这里处理注册逻辑
                    console.log("注册新用户:", newUsernameInput.text)
                }
            }

            Button {
                text: "返回"
                width: 100
                onClicked: {
                    // 发出信号返回登录界面
                    backToLogin()
                }
            }
        }
    }
}