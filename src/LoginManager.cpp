// LoginManager.cpp
#include "LoginManager.h"

LoginManager::LoginManager(const QString& dbPath, QObject *parent)
    : QObject(parent), userManager(dbPath) {}

void LoginManager::attemptLogin(const QString &username, const QString &password, const QString &role) {
    if (userManager.validateUser(username, password, role)) {
        emit loginSuccessful(role);
    } else {
        emit loginFailed();
    }
}