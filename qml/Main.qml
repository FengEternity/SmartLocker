import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System"

    // 设置全局主题和调色板
    Material.theme: Material.Dark
    Material.primary: "#6200EE" // 主色
    Material.accent: "#03DAC5"  // 辅助色


    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: {
                stackView.pop()
                stackView.push(mainPage)
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