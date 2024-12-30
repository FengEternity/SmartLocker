#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/LoginManager.h"
#include "src/DatabaseManager.h"
#include "src/UserManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;



    QString dbPath = "./database.sqlite";
    LoginManager loginManager(dbPath);
    UserManager userManager(dbPath);

    engine.rootContext()->setContextProperty("userManager", &userManager);


    // Register LoginManager with QML
    engine.rootContext()->setContextProperty("loginManager", &loginManager);

    // Load Main.qml
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}