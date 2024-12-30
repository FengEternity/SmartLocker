import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Smart Locker System - Admin"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: "欢迎管理员"
            font.pixelSize: 24
        }

        // 这里可以添加管理员相关的功能，例如查询滞留快递等
        Button {
            text: "查询滞留快递"
            onClicked: {
                // 实现查询滞留快递的逻辑
            }
        }
    }
}