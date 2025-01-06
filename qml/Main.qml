import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

pragma ComponentBehavior: Bound

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: i18n ? i18n.appTitle : ""

    // 主题设置
    Material.theme: settingsManager.isDarkMode ? Material.Dark : Material.Light
    
    // 定义主题相关的颜色
    readonly property color primaryColor: settingsManager.isDarkMode ? "#ffb499" : "#ffb499"
    readonly property color accentColor: settingsManager.isDarkMode ? "#4fc3f7" : "#4fc3f7"
    
    // 语言资源加载器
    property var i18n: null
    
    // 设置菜单
    header: ToolBar {
        Material.background: "transparent"  // 设置透明背景
        
        RowLayout {
            anchors.fill: parent
            
            // 左侧空白占位
            Item {
                Layout.fillWidth: true
            }
            
            // 右侧设置菜单
            ToolButton {
                text: "⚙" // 使用齿轮图标
                font.pixelSize: 20
                
                onClicked: settingsMenu.open()
                
                Menu {
                    id: settingsMenu
                    y: parent.height
                    
                    MenuItem {
                        text: i18n ? (settingsManager.isDarkMode ? i18n.switchToLight : i18n.switchToDark) 
                                  : (settingsManager.isDarkMode ? "切换到浅色主题" : "切换到深色主题")
                        onTriggered: settingsManager.isDarkMode = !settingsManager.isDarkMode
                    }
                    MenuItem {
                        text: i18n ? (settingsManager.language === "zh_CN" ? i18n.switchToEnglish : i18n.switchToChinese)
                                  : (settingsManager.language === "zh_CN" ? "Switch to English" : "切换到中文")
                        onTriggered: {
                            settingsManager.language = settingsManager.language === "zh_CN" ? "en_US" : "zh_CN"
                            loadTranslations()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        loadTranslations()
    }

    function loadTranslations() {
        console.log("Loading translations for language:", settingsManager.language)
        var component = Qt.createComponent("qrc:/translations/" + settingsManager.language + ".qml")
        if (component.status === Component.Ready) {
            i18n = component.createObject(window)
            console.log("Translations loaded successfully")
        } else if (component.status === Component.Error) {
            console.error("Error loading translations:", component.errorString())
        }
    }

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
                        text: i18n ? i18n.courierHome : "快递员首页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: i18n ? i18n.logout : "退出"
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
                            text: i18n ? i18n.enterPackageInfo : "录入快递信息"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: receiverPhone
                            Layout.fillWidth: true
                            placeholderText: i18n ? i18n.receiverPhone : "收件人手机号"
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
                            displayText: currentIndex === -1 ? 
                                (i18n ? i18n.selectLocker : "请选择储物柜") : 
                                (i18n ? i18n.lockerNumberPrefix : "柜号: ") + currentText
                            
                            onCurrentIndexChanged: {
                                console.log("当前选中索引:", currentIndex)
                                console.log("当前选中文本:", currentText)
                            }
                        }

                        Button {
                            text: i18n ? i18n.depositPackage : "存放快递"
                            Layout.fillWidth: true
                            enabled: receiverPhone.acceptableInput && lockerSelector.currentText
                            highlighted: true
                            Material.background: primaryColor

                            onClicked: {
                                var result = packageManager.depositPackage(
                                    receiverPhone.text,
                                    parseInt(lockerSelector.currentText),
                                    loginManager.currentUser
                                )
                                if (result.success) {
                                    depositDialog.message = (i18n ? i18n.depositSuccess : "快递存放成功！") + 
                                        "\n" + (i18n ? i18n.pickupCode : "取件码：") + result.pickupCode
                                    depositDialog.open()
                                    // 清空输入
                                    receiverPhone.text = ""
                                    lockerSelector.currentIndex = -1
                                } else {
                                    errorDialog.message = (i18n ? i18n.depositFailed : "存放失败：") + result.message
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
                            text: i18n ? i18n.packageQuery : "快递查询"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: queryPhone
                            Layout.fillWidth: true
                            placeholderText: i18n ? i18n.enterPhoneToQuery : "输入手机号查询快递"
                            validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                        }

                        Button {
                            text: i18n ? i18n.query : "查询"
                            Layout.fillWidth: true
                            enabled: queryPhone.acceptableInput
                            highlighted: true
                            Material.background: accentColor

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
                title: i18n ? i18n.depositResult : "存放结果"
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
                        text: i18n ? i18n.adminHome : "管理员首页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: i18n ? i18n.logout : "退出"
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
                        text: i18n ? i18n.modifyLockerStatus : "修改快递柜状态"
                        Layout.fillWidth: true
                        Material.background: primaryColor
                        highlighted: true
                        onClicked: statusDialog.open()
                    }

                    Button {
                        text: i18n ? i18n.refreshOverdue : "刷新超时快递"
                        Layout.fillWidth: true
                        Material.background: accentColor
                        highlighted: true
                        onClicked: {
                            console.log("点击刷新超时快递按钮")
                            var packages = packageManager.getOverduePackages()
                            console.log("刷新获取到的超时快递:", JSON.stringify(packages))
                            if (packages && packages.length > 0) {
                                overdueList.text = packages.join("\n\n")
                                console.log("刷新完成")
                            } else {
                                overdueList.text = i18n ? i18n.noOverduePackages : "无超时快递"
                                console.log("刷新后没有超时快递")
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
                            text: i18n ? i18n.overdueList : "超时快递列表"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                id: overdueList
                                readOnly: true
                                wrapMode: Text.WordWrap
                                font.pixelSize: 14
                                
                                // 初始化时加载数据
                                Component.onCompleted: {
                                    console.log("开始加载超时快递列表...")
                                    var packages = packageManager.getOverduePackages()
                                    console.log("获取到的超时快递:", JSON.stringify(packages))
                                    if (packages && packages.length > 0) {
                                        text = packages.join("\n\n")  // 使用两个换行符分隔每条记录
                                        console.log("超时快递列表加载完成")
                                    } else {
                                        text = i18n ? i18n.noOverduePackages : "无超时快递"
                                        console.log("没有超时快递")
                                    }
                                }
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
                                text: i18n ? i18n.userRatings : "用户评价"
                                font.pixelSize: 18
                                font.bold: true
                                Layout.fillWidth: true  // 让标签填充剩余空间
                                horizontalAlignment: Qt.AlignLeft
                            }

                            Button {
                                text: i18n ? i18n.refresh : "刷新"
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
                title: i18n ? i18n.modifyLockerStatus : "修改快递柜状态"
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
                        model: [
                            i18n ? i18n.statusEmpty : "空闲",
                            i18n ? i18n.statusOccupied : "使用中",
                            i18n ? i18n.statusMaintenance : "维修中"
                        ]
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
                    overdueList.clear()
                    var packages = packageManager.getOverduePackages()
                    for (var i = 0; i < packages.length; i++) {
                        overdueList.append({"text": packages[i]})
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
                        text: i18n ? i18n.userHome : "用户首页"
                        font.pixelSize: 20
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    ToolButton {
                        text: i18n ? i18n.logout : "退出"
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
                    placeholderText: i18n ? i18n.enterPickupCode : "请输入取件码"
                    validator: RegularExpressionValidator { regularExpression: /^\d{6}$/ }
                }

                Button {
                    text: i18n ? i18n.pickup : "取件"
                    Layout.fillWidth: true
                    enabled: pickupCodeInput.acceptableInput
                    onClicked: {
                        var result = packageManager.pickupPackage(pickupCodeInput.text)
                        resultDialog.message = result.success ? 
                            (i18n ? i18n.pickupSuccess : "取件成功！") + "\n" + 
                            (i18n ? i18n.lockerNumberPrefix : "柜号：") + result.lockerNumber : 
                            (i18n ? i18n.pickupFailed : "取件失败：") + result.message
                        resultDialog.open()
                    }
                }

                TextField {
                    id: phoneQueryInput
                    Layout.fillWidth: true
                    placeholderText: i18n ? i18n.queryPickupCode : "请输入手机号查询取件码"
                    validator: RegularExpressionValidator { regularExpression: /^1[3-9]\d{9}$/ }
                }

                Button {
                    text: i18n ? i18n.queryCode : "查询取件码"
                    Layout.fillWidth: true
                    enabled: phoneQueryInput.acceptableInput
                    onClicked: {
                        var codes = packageManager.getPickupCodes(phoneQueryInput.text)
                        queryDialog.message = codes.length > 0 ? codes.join("\n") : 
                            (i18n ? i18n.noPackagesFound : "未找到相关快递")
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
                    text: i18n ? i18n.rateService : "评价服务"
                    Layout.fillWidth: true
                    Material.background: accentColor
                    highlighted: true
                    onClicked: ratingDialog.open()
                }

                // 添加评价对话框
                Dialog {
                    id: ratingDialog
                    title: i18n ? i18n.rateService : "评价服务"
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
                            model: [
                                i18n ? i18n.rating5 : "5分 非常满意",
                                i18n ? i18n.rating4 : "4分 满意",
                                i18n ? i18n.rating3 : "3分 一般",
                                i18n ? i18n.rating2 : "2分 不满意",
                                i18n ? i18n.rating1 : "1分 非常不满意"
                            ]
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

                // 只保留一个超时提醒对话框
                Dialog {
                    id: overdueDialog
                    title: i18n ? i18n.overduePackagesTitle : "超时快递提醒"
                    modal: true
                    standardButtons: Dialog.Ok
                    x: (parent.width - width) / 2
                    y: (parent.height - height) / 2
                    width: 400
                    height: 300

                    ScrollView {
                        anchors.fill: parent
                        clip: true

                        TextArea {
                            id: overduePackagesText
                            readOnly: true
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14
                        }
                    }

                    // 添加对话框状态调试
                    onOpened: console.log("超时快递对话框已打开")
                    onClosed: console.log("超时快递对话框已关闭")
                }

                // 在页面加载完成时检查超时快递
                Component.onCompleted: {
                    console.log("用户页面加载完成")
                    console.log("当前用户:", loginManager.currentUser)
                    console.log("检查用户超时快递...")
                    
                    // 检查 packageManager 是否可用
                    if (!packageManager) {
                        console.error("packageManager 未定义!")
                        return
                    }

                    try {
                        var packages = packageManager.getOverduePackagesByPhone(loginManager.currentUser)
                        console.log("获取到的超时快递:", JSON.stringify(packages))
                        
                        if (packages && packages.length > 0) {
                            console.log("发现超时快递，准备显示对话框")
                            var noticeText = (i18n ? i18n.overduePackagesNotice : "您有以下超时快递，请尽快取出：\n\n") +
                                packages.join("\n\n")
                            console.log("对话框内容:", noticeText)
                            
                            overduePackagesText.text = noticeText
                            overdueDialog.open()
                            console.log("已触发对话框打开")
                        } else {
                            console.log("没有发现超时快递")
                        }
                    } catch (e) {
                        console.error("检查超时快递时发生错误:", e)
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
