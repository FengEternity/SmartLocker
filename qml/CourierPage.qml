import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System - Courier"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "欢迎快递员"
            font.pixelSize: 24
        }

        // 这里可以添加快递员相关的功能，例如存放快递等
        Button {
            text: "存放快递"
            onClicked: {
                // 实现存放快递的逻辑
            }
        }
    }
}