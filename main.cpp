#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/LoginManager.h"
#include "src/DatabaseManager.h"
#include "src/UserManager.h"
#include "src/PackageManager.h"
#include "src/LogManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 初始化日志系统
    LogManager &logManager = LogManager::getInstance();
    logManager.setLogLevel(LogManager::INFO);

    // 记录应用程序启动日志
    logManager.info("SmartLocker Application Started");

    QString dbPath = "./database.sqlite";
    LoginManager loginManager(dbPath);
    UserManager userManager(dbPath);

    engine.rootContext()->setContextProperty("userManager", &userManager);

    // Register LoginManager with QML
    engine.rootContext()->setContextProperty("loginManager", &loginManager);

    // 将日志管理器暴露给QML
    engine.rootContext()->setContextProperty("logManager", &logManager);
    engine.rootContext()->setContextProperty("userManager", &userManager);
    engine.rootContext()->setContextProperty("loginManager", &loginManager);

    // Load Main.qml
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
                     {
    if (!obj && url == objUrl){
        LogManager::getInstance().error("Failed to load Main.qml");
        QCoreApplication::exit(-1);} }, Qt::QueuedConnection);
    engine.load(url);

    qmlRegisterType<PackageManager>("com.example.packagemanager", 1, 0, "PackageManager");

    DatabaseManager dbManager("lockers.db");
    PackageManager packageManager(&dbManager);

    engine.rootContext()->setContextProperty("packageManager", &packageManager);

    logManager.info("SmartLocker Application initialized successfully");
    return app.exec();
}