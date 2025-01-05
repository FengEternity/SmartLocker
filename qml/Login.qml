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
            placeholderText: "手机号"
            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
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
                enabled: usernameInput.acceptableInput && passwordInput.text.length > 0
                onClicked: {
                    if (loginManager.verifyCredentials(usernameInput.text, passwordInput.text, roleComboBox.getSelectedRole())) {
                        loginSuccessful(roleComboBox.getSelectedRole())
                    } else {
                        errorDialog.message = "用户名或密码错误，或角色选择不匹配"
                        errorDialog.open()
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
        id: errorDialog
        title: "登录失败"
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

        property string message: "账号或密码错误，请重试！"
    }
}