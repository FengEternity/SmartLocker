import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

pragma ComponentBehavior: Bound

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "智能快递柜系统"

    Material.theme: Material.Light
    Material.primary: "#f6772a"
    Material.accent: "#35afe1"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Login {
            onLoginSuccessful: function(role) {
                if (role === "deliver") {
                    stackView.push(deliveryWorkerPage)
                } else if (role === "admin") {
                    stackView.push(adminPage)
                } else if (role === "user") {
                    stackView.push(userPage)
                }
            }
        }
    }

    Component {
        id: deliveryWorkerPage
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "快递员主页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: qsTr("退出")
                        onClicked: stackView.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // 快递信息输入区域
                Pane {
                    Layout.fillWidth: true
                    Material.elevation: 2

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        Label {
                            text: "录入快递信息"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: receiverPhone
                            Layout.fillWidth: true
                            placeholderText: "收件人手机号"
                            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                        }

                        ComboBox {
                            id: lockerSelector
                            Layout.fillWidth: true
                            model: ListModel {
                                id: lockerModel
                                Component.onCompleted: {
                                    console.log("正在获取可用储物柜...")
                                    var lockers = packageManager.getAvailableLockers()
                                    console.log("获取到的储物柜列表:", JSON.stringify(lockers))
                                    for (var i = 0; i < lockers.length; i++) {
                                        console.log("添加储物柜:", lockers[i])
                                        append({"text": lockers[i]})
                                    }
                                    console.log("储物柜列表加载完成，数量:", lockerModel.count)
                                }
                            }
                            textRole: "text"
                            currentIndex: -1
                            displayText: currentIndex === -1 ? "请选择储物柜" : "柜号: " + currentText
                            
                            onCurrentIndexChanged: {
                                console.log("当前选中索引:", currentIndex)
                                console.log("当前选中文本:", currentText)
                            }
                        }

                        Button {
                            text: "存放快递"
                            Layout.fillWidth: true
                            enabled: receiverPhone.acceptableInput && lockerSelector.currentText
                            highlighted: true
                            Material.background: Material.primary

                            onClicked: {
                                var result = packageManager.depositPackage(
                                    receiverPhone.text,
                                    parseInt(lockerSelector.currentText),
                                    loginManager.currentUser
                                )
                                if (result.success) {
                                    depositDialog.message = "快递存放成功！\n取件码：" + result.pickupCode
                                    depositDialog.open()
                                    // 清空输入
                                    receiverPhone.text = ""
                                    lockerSelector.currentIndex = -1
                                } else {
                                    errorDialog.message = "存放失败：" + result.message
                                    errorDialog.open()
                                }
                            }
                        }
                    }
                }

                // 快递查询区域
                Pane {
                    Layout.fillWidth: true
                    Material.elevation: 2

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        Label {
                            text: "快递查询"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: queryPhone
                            Layout.fillWidth: true
                            placeholderText: "输入手机号查询快递"
                            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                        }

                        Button {
                            text: "查询"
                            Layout.fillWidth: true
                            enabled: queryPhone.acceptableInput
                            highlighted: true
                            Material.background: Material.accent

                            onClicked: {
                                var packages = packageManager.queryPackagesByPhone(queryPhone.text)
                                queryDialog.message = packages || "未找到相关快递"
                                queryDialog.open()
                            }
                        }
                    }
                }
            }

            // 对话框
            Dialog {
                id: depositDialog
                property string message: ""
                title: "存放结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 300
                height: 150

                contentItem: ColumnLayout {
                    spacing: 10

                    Label {
                        text: depositDialog.message
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                    }
                }
            }

            Dialog {
                id: queryDialog
                property string message: ""
                title: "查询结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 400
                height: 300

                contentItem: ScrollView {
                    clip: true

                    Label {
                        text: queryDialog.message
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 14
                        padding: 20
                    }
                }
            }

            Dialog {
                id: errorDialog
                property string message: ""
                title: "错误"
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
            }
        }
    }

    Component {
        id: adminPage
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "管理员主页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: qsTr("退出")
                        onClicked: stackView.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // 功能按钮区域
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    Button {
                        text: "修改快递柜状态"
                        Layout.fillWidth: true
                        Material.background: Material.primary
                        highlighted: true
                        onClicked: statusDialog.open()
                    }

                    Button {
                        text: "刷新超时快递"
                        Layout.fillWidth: true
                        Material.background: Material.accent
                        highlighted: true
                        onClicked: {
                            // 直接在这里更新列表，不使用 reload 函数
                            overdueListModel.clear()
                            var packages = packageManager.getOverduePackages()
                            for (var i = 0; i < packages.length; i++) {
                                overdueListModel.append({"text": packages[i]})
                            }
                        }
                    }
                }

                // 超时快递列表区域
                Pane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.elevation: 2

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        Label {
                            text: "超时快递列表"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: ListModel {
                                id: overdueListModel
                                // 初始化时加载数据
                                Component.onCompleted: {
                                    var packages = packageManager.getOverduePackages()
                                    for (var i = 0; i < packages.length; i++) {
                                        append({"text": packages[i]})
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                height: 60

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Label {
                                        text: model.text
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            // 当列表为空时显示的占位符
                            Label {
                                anchors.centerIn: parent
                                text: "无超时快递"
                                font.pixelSize: 16
                                color: "#666666"
                                visible: overdueListModel.count === 0
                            }
                        }
                    }
                }

                // 评价列表区域
                Pane {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height / 2
                    Material.elevation: 2
                    padding: 10

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Label {
                                text: "用户评价"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.fillWidth: true  // 让标签填充剩余空间
                                horizontalAlignment: Qt.AlignLeft
                            }

                            Button {
                                text: "刷新"
                                Layout.alignment: Qt.AlignRight  // 将按钮对齐到右侧
                                onClicked: {
                                    var ratings = packageManager.getRatings()
                                    ratingsList.text = formatRatings(ratings)
                                }
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                id: ratingsList
                                readOnly: true
                                wrapMode: Text.WordWrap
                                font.pixelSize: 14
                                Component.onCompleted: {
                                    var ratings = packageManager.getRatings()
                                    text = formatRatings(ratings)
                                }
                            }
                        }
                    }
                }
            }

            Dialog {
                id: statusDialog
                title: "修改快递柜状态"
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 300
                modal: true
                standardButtons: Dialog.Ok | Dialog.Cancel

                ColumnLayout {
                    spacing: 20
                    width: parent.width

                    ComboBox {
                        id: lockerSelector
                        Layout.fillWidth: true
                        model: ListModel {
                            id: adminLockerModel
                            Component.onCompleted: {
                                console.log("管理员页面：正在获取储物柜列表...")
                                var lockers = packageManager.getAvailableLockers()
                                console.log("管理员页面：获取到的储物柜列表:", JSON.stringify(lockers))
                                for (var i = 0; i < lockers.length; i++) {
                                    console.log("管理员页面：添加储物柜:", lockers[i])
                                    append({"text": lockers[i]})
                                }
                                console.log("管理员页面：储物柜列表加载完成，数量:", adminLockerModel.count)
                            }
                        }
                        textRole: "text"
                        currentIndex: -1
                        displayText: currentIndex === -1 ? "请选择储物柜" : "柜号: " + currentText
                        
                        onCurrentIndexChanged: {
                            console.log("管理员页面：当前选中索引:", currentIndex)
                            console.log("管理员页面：当前选中文本:", currentText)
                        }
                    }

                    ComboBox {
                        id: statusSelector
                        model: ["空闲", "使用中", "维修中"]
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                    }
                }

                onAccepted: {
                    packageManager.updateLockerStatus(
                        parseInt(lockerSelector.currentText),
                        statusSelector.currentText.toLowerCase()
                    )
                    // 更新列表
                    overdueListModel.clear()
                    var packages = packageManager.getOverduePackages()
                    for (var i = 0; i < packages.length; i++) {
                        overdueListModel.append({"text": packages[i]})
                    }
                }
            }
        }
    }

    Component {
        id: userPage
        Page {
            header: ToolBar {
                RowLayout {
                    anchors.fill: parent
                    Label {
                        text: "取件人主页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: qsTr("退出")
                        onClicked: stackView.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                TextField {
                    id: pickupCodeInput
                    Layout.fillWidth: true
                    placeholderText: "请输入取件码"
                    validator: RegularExpressionValidator { regularExpression: /^\d{6}$/ }
                }

                Button {
                    text: "取件"
                    Layout.fillWidth: true
                    enabled: pickupCodeInput.acceptableInput
                    onClicked: {
                        var result = packageManager.pickupPackage(pickupCodeInput.text)
                        resultDialog.message = result.success ? 
                            "取件成功！\n柜号：" + result.lockerNumber : 
                            "取件失败：" + result.message
                        resultDialog.open()
                    }
                }

                TextField {
                    id: phoneQueryInput
                    Layout.fillWidth: true
                    placeholderText: "请输入手机号查询取件码"
                    validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                }

                Button {
                    text: "查询取件码"
                    Layout.fillWidth: true
                    enabled: phoneQueryInput.acceptableInput
                    onClicked: {
                        var codes = packageManager.getPickupCodes(phoneQueryInput.text)
                        queryDialog.message = codes.length > 0 ?
                            "您的取件码：\n" + codes.join("\n") :
                            "没有找到相关取件码"
                        queryDialog.open()
                    }
                }

                // 添加一个分隔线
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e0e0"
                }

                // 添加评价按钮
                Button {
                    text: "评价服务"
                    Layout.fillWidth: true
                    Material.background: Material.accent
                    highlighted: true
                    onClicked: ratingDialog.open()
                }

                // 添加评价对话框
                Dialog {
                    id: ratingDialog
                    title: "服务评价"
                    modal: true
                    standardButtons: Dialog.Ok | Dialog.Cancel
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 300
                    height: 300

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        Label {
                            text: "请为我们的服务打分"
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }

                        ComboBox {
                            id: ratingScore
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            model: ["5分 非常满意", "4分 满意", "3分 一般", "2分 不满意", "1分 非常不满意"]
                        }

                        TextField {
                            id: ratingComment
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            placeholderText: "请输入评价内容（选填）"
                            wrapMode: TextInput.Wrap
                            // 允许多行输入
                            verticalAlignment: TextInput.AlignTop
                        }
                    }

                    onAccepted: {
                        var score = 5 - ratingScore.currentIndex
                        if (packageManager.submitRating(score, ratingComment.text)) {
                            // 评价成功
                            successDialog.message = "感谢您的评价！"
                            successDialog.open()
                            // 重置输入
                            ratingComment.text = ""
                            ratingScore.currentIndex = 0
                        } else {
                            // 评价失败
                            errorDialog.message = "评价提交失败，请稍后重试"
                            errorDialog.open()
                        }
                    }
                }

                // 添加成功提示对话框（如果还没有的话）
                Dialog {
                    id: successDialog
                    property string message: ""
                    title: "提示"
                    modal: true
                    standardButtons: Dialog.Ok
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 300
                    height: 150

                    contentItem: ColumnLayout {
                        spacing: 10

                        Label {
                            text: successDialog.message
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16
                        }
                    }
                }
            }

            Dialog {
                id: resultDialog
                property string message: ""
                title: "取件结果"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 300
                height: 150

                contentItem: ColumnLayout {
                    spacing: 10

                    Label {
                        text: resultDialog.message
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 16
                    }
                }
            }

            Dialog {
                id: queryDialog
                property string message: ""
                title: "取件码查询"
                modal: true
                standardButtons: Dialog.Ok
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                width: 300
                height: 200

                contentItem: ScrollView {
                    clip: true

                    Label {
                        text: queryDialog.message
                        wrapMode: Text.WordWrap
                        width: parent.width
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 14
                        padding: 20
                    }
                }
            }
        }
    }

    function formatRatings(ratings) {
        if (!ratings || ratings.length === 0) {
            return "暂无评价"
        }
        
        var result = ""
        for (var i = 0; i < ratings.length; i++) {
            var rating = ratings[i]
            result += "评分：" + rating.score + " 分\n"
            result += "时间：" + rating.date + "\n"
            result += "评价：" + (rating.comment || "无评价内容") + "\n"
            result += "----------------------------------------\n"
        }
        return result
    }
}
