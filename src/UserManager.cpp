#include "UserManager.h"

UserManager::UserManager(const QString &dbPath, QObject *parent)
    : QObject(parent), databaseManager(dbPath) {}

// 验证用户登录信息
bool UserManager::validateUser(const QString& username, const QString& password, const QString& role) {
    return databaseManager.verifyCredentials(username, password, role);
}

// 注册新用户
bool UserManager::registerUser(const QString &username, const QString &password, const QString &role) {
    bool success = databaseManager.insertUser(username, password, role);
    return success;  // 返回插入操作的结果
}