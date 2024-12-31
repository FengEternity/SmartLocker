import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal backToLogin()

    Column {
        spacing: 10
        anchors.centerIn: parent

        ComboBox {
            id: statusComboBox
            width: 210
            model: ["快递员", "管理员", "取件人"]

            // 角色映射
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
            id: newUsernameInput
            width: 210
            placeholderText: "新账号"
            onTextChanged: {
                if (!/^\d{11}$/.test(newUsernameInput.text)) {
                    newUsernameInput.color = "red"
                } else {
                    newUsernameInput.color = "black"
                }
            }
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
                    var username = newUsernameInput.text;
                    var password = newPasswordInput.text;
                    var role = statusComboBox.getSelectedRole();

                    // 检查输入是否合法
                    if (!/^\d{11}$/.test(username)) {
                        console.log("Invalid username");
                        registerFailedDialog.open();
                        return;
                    }

                    // 调用注册方法
                    var registerSuccess = userManager.registerUser(username, password, role);

                    if (registerSuccess) {
                        console.log("Registration successful");
                        registerSucessDialog.open()
                        newPasswordInput.text = ""
                        newUsernameInput.text = ""
                        // backToLogin();
                    } else {
                        console.log("Registration failed");
                        registerFailedDialog.open()
                    }
                }
            }

            Button {
                text: "返回"
                width: 100
                onClicked: {
                    backToLogin()
                }
            }
        }
    }

    Connections {
        target: userManager
        onRegisterTrue: {
            console.log("Registration successful")
            registerSucessDialog.open()
            // backToLogin()
        }
        onRegisterFalse: {
            console.log("Registration failed")
        }
    }

    Dialog {
        id: registerFailedDialog
        title: "注册失败"
        width: 256
        height: 128
        anchors.centerIn: parent
        contentItem: Text {
            text: "注册失败，请重试！"
            color: "white"
        }
        standardButtons: Dialog.Ok
        onAccepted: registerFailedDialog.close()
    }

    Dialog {
        id: registerSucessDialog
        title: "注册成功！"
        width: 256
        height: 128
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        onAccepted: registerSucessDialog.close()
    }
}