import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: {
                stackView.pop() // Remove login page
                stackView.push(mainPage) // Navigate to main page
            }
        }
    }

    Component {
        id: mainPage

        Item {
            // Main page content
            Text {
                text: "欢迎进入 Smart Locker System！"
                anchors.centerIn: parent
            }
        }
    }
}