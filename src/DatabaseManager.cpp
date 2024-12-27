// DatabaseManager.cpp
#include "DatabaseManager.h"
#include <QSqlDatabase>
#include <QDebug>

DatabaseManager::DatabaseManager(const QString& path) {
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);
}

bool DatabaseManager::open() {
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.open()) {
        qDebug() << "Error: connection with database failed";
        return false;
    }
    return true;
}

void DatabaseManager::close() {
    QSqlDatabase::database().close();
}