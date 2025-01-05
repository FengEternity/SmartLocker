// LoginManager.cpp
#include "LoginManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

LoginManager::LoginManager(const QString& dbPath, QObject *parent)
    : QObject(parent), m_db(new DatabaseManager(dbPath))
{
}

bool LoginManager::verifyCredentials(const QString& username, const QString& password, const QString& role)
{
    if (m_db->verifyCredentials(username, password, role)) {
        m_currentUser = username;
        m_currentRole = role;
        emit currentUserChanged();
        emit currentRoleChanged();
        return true;
    }
    return false;
}

void LoginManager::logout()
{
    m_currentUser.clear();
    m_currentRole.clear();
    emit currentUserChanged();
    emit currentRoleChanged();
}