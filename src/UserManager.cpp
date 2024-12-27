// UserManager.cpp
#include "UserManager.h"

bool UserManager::validateUser(const QString& username, const QString& password) {
    // 模拟用户验证
    return (username == "admin" && password == "password");
}