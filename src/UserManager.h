// UserManager.h
#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QObject>
#include <QString>

#include "DatabaseManager.h"

class UserManager : public QObject {
    Q_OBJECT
public:
    UserManager(const QString &dbPath, QObject *parent = nullptr);

    Q_INVOKABLE bool registerUser(const QString &username, const QString &password, const QString &role);

    // 验证用户登录信息
    bool validateUser(const QString& username, const QString& password, const QString& role);

signals:
    void registerTrue();
    void registerFalse();

private:
    DatabaseManager databaseManager;
};

#endif // USERMANAGER_H