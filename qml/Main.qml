import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System"

    Material.theme: Material.Dark
    Material.primary: "#6200EE"
    Material.accent: "#03DAC5"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: function(role) {
                console.log("登录成功，身份是：" + role);

                var pageComponent;
                switch (role) {
                    case "user":
                        pageComponent = courierPage;
                        break;
                    case "admin":
                        pageComponent = adminPage;
                        break;
                    case "guest":
                        pageComponent = guestPage;
                        break;
                    default:
                        pageComponent = mainPage;
                        break;
                }

                stackView.pop();
                stackView.push(pageComponent);
            }
        }
    }

    Component {
        id: courierPage
        CourierPage {} // 快递员页面的 QML 组件
    }

    Component {
        id: adminPage
        AdminPage {} // 管理员页面的 QML 组件
    }

    Component {
        id: guestPage
        GuestPage {} // 取件人页面的 QML 组件
    }

    Component {
        id: mainPage
        Item {
            Text {
                text: "欢迎进入 Smart Locker System！"
                anchors.centerIn: parent
            }
        }
    }
}