#ifndef LOGINMANAGER_H
#define LOGINMANAGER_H

#include <QObject>

class LoginManager : public QObject {
    Q_OBJECT
public:
    explicit LoginManager(QObject *parent = nullptr);

    signals:
        void loginSuccessful();
        void loginFailed();

    public slots:
        void attemptLogin(const QString &username, const QString &password);
};

#endif // LOGINMANAGER_H