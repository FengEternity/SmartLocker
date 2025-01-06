import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    signal backToLogin()

    Column {
        spacing: 20
        anchors.centerIn: parent

        ComboBox {
            spacing: 20
            id: statusComboBox
            width: 210
            model: [
                { text: i18n ? i18n.roleCourier : "快递员", value: "deliver" },
                { text: i18n ? i18n.roleAdmin : "管理员", value: "user" },
                { text: i18n ? i18n.roleUser : "取件人", value: "admin" }
            ]
            textRole: "text"
            valueRole: "value"

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
            placeholderText: i18n ? i18n.usernamePlaceholder : "新账号"
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
            placeholderText: i18n ? i18n.passwordPlaceholder : "新密码"
            echoMode: TextInput.Password
        }

        Row {
            spacing: 10

            Button {
                text: i18n ? i18n.register : "注册"
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
                    } else {
                        console.log("Registration failed");
                        registerFailedDialog.open()
                    }
                }
            }

            Button {
                text: i18n ? i18n.cancel : "返回"
                width: 100
                onClicked: {
                    backToLogin()
                }
            }
        }
    }

    Connections {
        target: userManager
        
        function onRegisterTrue() {
            console.log("Registration successful")
            registerSucessDialog.open()
        }
        
        function onRegisterFalse() {
            console.log("Registration failed")
        }
    }

    Dialog {
        id: registerFailedDialog
        title: i18n ? i18n.registerFailed : "注册失败"
        width: 256
        height: 128
        anchors.centerIn: parent
        contentItem: Text {
            text: i18n ? i18n.registerFailed : "注册失败，请重试！"
            color: "white"
        }
        standardButtons: Dialog.Ok
        onAccepted: registerFailedDialog.close()
    }

    Dialog {
        id: registerSucessDialog
        title: i18n ? i18n.registerSuccess : "注册成功！"
        width: 256
        height: 128
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        onAccepted: registerSucessDialog.close()
    }
}