#include "LoginManager.h"

LoginManager::LoginManager(QObject *parent) : QObject(parent) {}

void LoginManager::attemptLogin(const QString &username, const QString &password) {
    if (username == "user" && password == "pass") {
        emit loginSuccessful();
    } else {
        emit loginFailed();
    }
}