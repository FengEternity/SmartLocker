import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System - Guest"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "欢迎取件人"
            font.pixelSize: 24
        }

        // 这里可以添加取件人相关的功能，例如输入取件码取快递等
        TextField {
            id: codeInput
            placeholderText: "请输入取件码"
        }

        Button {
            text: "取出快递"
            onClicked: {
                // 实现取出快递的逻辑
            }
        }
    }
}