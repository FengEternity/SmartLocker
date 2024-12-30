// LoginManager.h
#ifndef LOGINMANAGER_H
#define LOGINMANAGER_H

#include <QObject>
#include "UserManager.h"

class LoginManager : public QObject {
    Q_OBJECT
public:
    explicit LoginManager(const QString& dbPath, QObject *parent = nullptr);

    signals:
        void loginSuccessful();
        void loginFailed();

    public slots:
        void attemptLogin(const QString &username, const QString &password, const QString &role);

private:
    UserManager userManager;
};

#endif // LOGINMANAGER_H