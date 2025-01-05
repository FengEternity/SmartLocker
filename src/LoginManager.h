// LoginManager.h
#ifndef LOGINMANAGER_H
#define LOGINMANAGER_H

#include <QObject>
#include "DatabaseManager.h"

class LoginManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentRole READ currentRole NOTIFY currentRoleChanged)

public:
    explicit LoginManager(const QString& dbPath, QObject *parent = nullptr);

    Q_INVOKABLE bool verifyCredentials(const QString& username, const QString& password, const QString& role);
    Q_INVOKABLE void logout();
    
    QString currentUser() const { return m_currentUser; }
    QString currentRole() const { return m_currentRole; }

signals:
    void currentUserChanged();
    void currentRoleChanged();

private:
    DatabaseManager* m_db;
    QString m_currentUser;
    QString m_currentRole;
};

#endif // LOGINMANAGER_H