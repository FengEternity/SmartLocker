import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    signal loginSuccessful(string role)

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
        spacing: 20
        anchors.centerIn: parent
        visible: pageLoader.status === Loader.Null

        ComboBox {
            id: roleSelector
            width: 210
            model: [
                { text: i18n ? i18n.roleCourier : "快递员", value: "deliver" },
                { text: i18n ? i18n.roleAdmin : "管理员", value: "admin" },
                { text: i18n ? i18n.roleUser : "取件人", value: "user" }
            ]
            textRole: "text"
            valueRole: "value"
            
            function getSelectedRole() {
                return model[currentIndex].value
            }
        }

        TextField {
            id: usernameInput
            width: 210
            placeholderText: i18n ? i18n.usernamePlaceholder : "请输入手机号"
            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
        }

        TextField {
            id: passwordInput
            width: 210
            placeholderText: i18n ? i18n.passwordPlaceholder : "请输入密码"
            echoMode: TextInput.Password
        }

        Row {
            spacing: 10

            Button {
                text: i18n ? i18n.login : "登录"
                width: 100
                enabled: usernameInput.acceptableInput && passwordInput.text.length > 0
                onClicked: {
                    if (loginManager.verifyCredentials(usernameInput.text, passwordInput.text, roleSelector.getSelectedRole())) {
                        loginSuccessful(roleSelector.getSelectedRole())
                    } else {
                        errorDialog.message = i18n ? i18n.loginFailed : "用户名或密码错误，或角色选择不匹配"
                        errorDialog.open()
                    }
                }
            }

            Button {
                text: i18n ? i18n.register : "注册"
                width: 100
                onClicked: {
                    pageLoader.source = "Register.qml"
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        title: i18n ? i18n.error : "错误"
        modal: true
        standardButtons: Dialog.Ok
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 300
        height: 150

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                text: errorDialog.message
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
                color: "#d32f2f"
            }
        }

        property string message: i18n ? i18n.loginFailed : "账号或密码错误，请重试！"
    }
}