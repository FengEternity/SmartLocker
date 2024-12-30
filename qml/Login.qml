import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccessful(string role)

    Column {
        spacing: 10
        anchors.centerIn: parent

        ComboBox {
            id: statusComboBox
            width: 210
            model: ["快递员", "管理员", "取件人"]

            property var roleMap: {
                "快递员": "user",
                "管理员": "admin",
                "取件人": "guest"
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
                text: "登陆"
                width: 100
                onClicked: {
                    loginManager.attemptLogin(
                        usernameInput.text,
                        passwordInput.text,
                        statusComboBox.getSelectedRole()
                    );
                }
            }

            Button {
                text: "注册"
                width: 100
                onClicked: {
                    // 注册页面逻辑
                }
            }
        }
    }

    Connections {
        target: loginManager
        function onLoginSuccessful(role) {
            loginSuccessful(role);
        }
        function onLoginFailed() {
            usernameInput.text = "";
            passwordInput.text = "";
            loginFailedDialog.open();
        }
    }

    Dialog {
        id: loginFailedDialog
        title: "登录失败"
        width: 256
        height: 128
        anchors.centerIn: parent
        contentItem: Text {
            text: "登陆失败，请重试！"
            color: "white"
        }
        standardButtons: Dialog.Ok
        onAccepted: loginFailedDialog.close();
    }
}