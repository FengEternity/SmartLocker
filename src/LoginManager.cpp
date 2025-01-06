// LoginManager.cpp
#include "LoginManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include "LogManager.h"

LoginManager::LoginManager(const QString& dbPath, QObject *parent)
    : QObject(parent), m_db(new DatabaseManager(dbPath))
{
}

bool LoginManager::verifyCredentials(const QString& username, const QString& password, const QString& role)
{
    LogManager::getInstance().info("Verifying credentials:" + username + ":" + password + ":" + role);
    if (m_db->verifyCredentials(username, password, role)) {
        m_currentUser = username;
        m_currentRole = role;
        emit currentUserChanged();
        emit currentRoleChanged();
        LogManager::getInstance().info("Credentials verified successfully");
        return true;
    }
    LogManager::getInstance().error("Credentials verification failed");
    return false;
}

void LoginManager::logout()
{
    m_currentUser.clear();
    m_currentRole.clear();
    emit currentUserChanged();
    emit currentRoleChanged();
}