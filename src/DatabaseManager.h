// DatabaseManager.h
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QString>

class DatabaseManager {
public:
    DatabaseManager(const QString& path);
    bool open();
    void close();
    // 其他数据库操作
};

#endif // DATABASEMANAGER_H