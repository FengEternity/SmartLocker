#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/LoginManager.h"
#include "src/DatabaseManager.h"
#include "src/UserManager.h"
#include "src/PackageManager.h"
#include "src/LogManager.h"
#include "src/SettingsManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 初始化日志系统
    LogManager& logManager = LogManager::getInstance();
    logManager.setLogLevel(LogManager::INFO);
    
    // 记录应用程序启动信息
    logManager.info("SmartLocker Application Starting...");
    logManager.info(QString("Qt Version: %1").arg(qVersion()));
    logManager.info(QString("Application Directory: %1").arg(QCoreApplication::applicationDirPath()));

    // 初始化数据库
    QString dbPath = QCoreApplication::applicationDirPath() + "/lockers.db";
    qDebug() << "数据库路径:" << dbPath;
    DatabaseManager dbManager(dbPath);

    // 初始化各个管理器
    logManager.info("Initializing managers...");
    LoginManager loginManager(dbPath);
    UserManager userManager(dbPath);
    PackageManager packageManager(&dbManager);
    SettingsManager settingsManager;

    // 初始化QML引擎
    logManager.info("Initializing QML engine...");
    QQmlApplicationEngine engine;

    // 注册QML类型
    logManager.info("Registering QML types...");
    qmlRegisterType<PackageManager>("com.example.packagemanager", 1, 0, "PackageManager");

    // 设置QML上下文属性
    logManager.info("Setting up QML context properties...");
    engine.rootContext()->setContextProperty("logManager", &logManager);
    engine.rootContext()->setContextProperty("userManager", &userManager);
    engine.rootContext()->setContextProperty("loginManager", &loginManager);
    engine.rootContext()->setContextProperty("packageManager", &packageManager);
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);

    // 加载主QML文件
    logManager.info("Loading main QML file...");
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, &logManager](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            logManager.error("Failed to load Main.qml - application will exit");
            QCoreApplication::exit(-1);
        } else {
            logManager.info("Main QML file loaded successfully");
        }
    }, Qt::QueuedConnection);
    
    engine.load(url);

    logManager.info("SmartLocker Application initialized successfully");
    return app.exec();
}