// DatabaseManager.h
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QString>
#include <QSqlDatabase>

class DatabaseManager {
public:
    explicit DatabaseManager(const QString& path);
    bool verifyCredentials(const QString& username, const QString& password, const QString& role);
    bool insertUser(const QString& username, const QString& password, const QString& role);
    void initializeDatabase();
    bool userExists(const QString& username);

private:
    QSqlDatabase db;
};

#endif // DATABASEMANAGER_H