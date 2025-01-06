import QtQml 2.15

QtObject {
    // 通用
    property string appTitle: "智能快递柜系统"
    property string settings: "设置"
    property string confirm: "确定"
    property string cancel: "取消"
    property string error: "错误"
    property string success: "成功"
    property string warning: "警告"
    
    // 主题切换
    property string switchToLight: "切换到浅色主题"
    property string switchToDark: "切换到深色主题"
    property string switchToEnglish: "Switch to English"
    property string switchToChinese: "切换到中文"
    
    // 登录相关
    property string login: "登录"
    property string logout: "退出"
    property string register: "注册"
    property string username: "用户名"
    property string password: "密码"
    property string phoneNumber: "手机号"
    property string usernamePlaceholder: "请输入手机号"
    property string passwordPlaceholder: "请输入密码"
    
    // 页面标题
    property string courierHome: "快递员主页"
    property string adminHome: "管理员主页"
    property string userHome: "取件人主页"
    
    // 快递员页面
    property string enterPackageInfo: "录入快递信息"
    property string receiverPhone: "收件人手机号"
    property string selectLocker: "请选择储物柜"
    property string lockerNumber: "柜号"
    property string depositPackage: "存放快递"
    property string depositSuccess: "快递存放成功！"
    property string pickupCode: "取件码"
    property string depositFailed: "存放失败"
    
    // 管理员页面
    property string modifyLockerStatus: "修改快递柜状态"
    property string refreshOverdue: "刷新超时快递"
    property string overdueList: "超时快递列表"
    property string noOverduePackages: "无超时快递"
    property string userRatings: "用户评价"
    property string refresh: "刷新"
    property string noRatings: "暂无评价"
    
    // 取件人页面
    property string enterPickupCode: "请输入取件码"
    property string pickup: "取件"
    property string pickupSuccess: "取件成功！"
    property string pickupFailed: "取件失败"
    property string queryPickupCode: "请输入手机号查询取件码"
    property string queryCode: "查询取件码"
    property string rateService: "评价服务"
    property string submitRating: "提交评价"
    property string ratingScore: "请为我们的服务打分"
    property string ratingComment: "请输入评价内容（选填）"
    
    // 储物柜状态
    property string statusEmpty: "空闲"
    property string statusOccupied: "使用中"
    property string statusMaintenance: "维修中"
    
    // 角色选择
    property string roleCourier: "快递员"
    property string roleAdmin: "管理员"
    property string roleUser: "取件人"
    
    // 登录页面
    property string loginTitle: "登录"
    property string loginFailed: "登录失败"
    property string loginSuccess: "登录成功"
    
    // 注册页面
    property string registerTitle: "注册"
    property string registerSuccess: "注册成功"
    property string registerFailed: "注册失败"
    property string passwordConfirm: "确认密码"
    property string passwordMismatch: "两次输入的密码不一致"
    property string phoneInvalid: "请输入有效的手机号"
    property string userExists: "该手机号已注册"
    
    // 快递员页面补充
    property string packageQuery: "快递查询"
    property string enterPhoneToQuery: "输入手机号查询快递"
    property string query: "查询"
    property string noPackagesFound: "未找到相关快递"
    property string lockerNumberPrefix: "柜号: "
    
    // 对话框
    property string depositResult: "存放结果"
    property string queryResult: "查询结果"
    property string ok: "确定"
    property string close: "关闭"
    
    // 评分选项
    property string rating5: "5分 非常满意"
    property string rating4: "4分 满意"
    property string rating3: "3分 一般"
    property string rating2: "2分 不满意"
    property string rating1: "1分 非常不满意"
    property string thankForRating: "感谢您的评价！"
    property string ratingFailed: "评价提交失败，请稍后重试"
    
    // 添加以下属性
    property string overduePackagesTitle: "超时快递提醒"
    property string overduePackagesNotice: "您有以下超时快递，请尽快取出："
} 