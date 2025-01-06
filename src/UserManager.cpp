#include "UserManager.h"
#include "LogManager.h"

UserManager::UserManager(const QString &dbPath, QObject *parent)
    : QObject(parent), databaseManager(dbPath)
{
    LogManager::getInstance().info(QString("UserManager initialized with database path: %1").arg(dbPath));
}

// 验证用户登录信息
bool UserManager::validateUser(const QString& username, const QString& password, const QString& role) {
    LogManager::getInstance().info(QString("Validating user credentials for: %1 with role: %2").arg(username).arg(role));
    
    bool isValid = databaseManager.verifyCredentials(username, password, role);
    if (isValid) {
        LogManager::getInstance().info(QString("User validation successful: %1").arg(username));
    } else {
        LogManager::getInstance().warning(QString("User validation failed: %1").arg(username));
    }
    
    return isValid;
}

// 注册新用户
bool UserManager::registerUser(const QString &username, const QString &password, const QString &role) {
    LogManager::getInstance().info(QString("Attempting to register new user: %1 with role: %2").arg(username).arg(role));
    
    if (username.isEmpty() || password.isEmpty() || role.isEmpty()) {
        LogManager::getInstance().warning("Registration failed: Empty username, password, or role");
        emit registerFalse();
        return false;
    }

    if (databaseManager.userExists(username)) {
        LogManager::getInstance().warning(QString("Registration failed: User already exists: %1").arg(username));
        emit registerFalse();
        return false;
    }

    bool success = databaseManager.insertUser(username, password, role);
    if (success) {
        LogManager::getInstance().info(QString("User registered successfully: %1").arg(username));
        emit registerTrue();
    } else {
        LogManager::getInstance().error(QString("Failed to register user: %1").arg(username));
        emit registerFalse();
    }
    
    return success;
}