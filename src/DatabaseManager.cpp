#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>

DatabaseManager::DatabaseManager(const QString& path) {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    if (!db.open()) {
        qDebug() << "Failed to open the database:" << db.lastError().text();
        return;
    }

    // if (!QFile::exists(path)) {
    //     initializeDatabase();
    // }

    initializeDatabase();
}

void DatabaseManager::initializeDatabase() {
    QSqlQuery query;

    // 创建用户表
    if (!query.exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, role TEXT)")) {
        qDebug() << "Failed to create table:" << query.lastError().text();
        return;
    }

    // 插入默认用户数据
    insertUser("admin", "admin123", "admin");
    insertUser("user", "user123", "user");
    insertUser("guest", "guest123", "guest");
}

bool DatabaseManager::insertUser(const QString& username, const QString& password, const QString& role) {
    if (userExists(username)) return false;

    QSqlQuery query;
    query.prepare("INSERT INTO users (username, password, role) VALUES (?, ?, ?)");
    query.addBindValue(username);
    query.addBindValue(password);
    query.addBindValue(role);
    if (!query.exec()) {
        qDebug() << "Failed to insert user:" << query.lastError().text();
        return false;
    }
    qInfo() << "Inserting user:" << username << ":" << password;
    return true;
}

bool DatabaseManager::verifyCredentials(const QString& username, const QString& password, const QString& role) {
    QSqlQuery query;
    query.prepare("SELECT * FROM users WHERE username = ? AND password = ? AND role = ?");
    query.addBindValue(username);
    query.addBindValue(password);
    query.addBindValue(role);
    if (query.exec() && query.next()) {
        return true;
    }
    return false;
}

// 检查用户是否存在
bool DatabaseManager::userExists(const QString& username) {
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }

    return false;
}