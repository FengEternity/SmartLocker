// UserManager.h
#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QString>
#include "DatabaseManager.h"

class UserManager {
public:
    UserManager(const QString& dbPath);
    bool validateUser(const QString& username, const QString& password, const QString& role);

private:
    DatabaseManager databaseManager;
};

#endif // USERMANAGER_H