// UserManager.cpp
#include "UserManager.h"

UserManager::UserManager(const QString& dbPath) : databaseManager(dbPath) {}

bool UserManager::validateUser(const QString& username, const QString& password, const QString& role) {
    return databaseManager.verifyCredentials(username, password, role);
}