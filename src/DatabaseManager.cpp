#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>
#include <QRegularExpression>
#include <QRandomGenerator>
#include "LogManager.h"

DatabaseManager::DatabaseManager(const QString& path) {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    if (!db.open()) {
        qDebug() << "Failed to open the database:" << db.lastError().text();
        LogManager::getInstance().error("Failed to open the database:" + db.lastError().text());
        return;
    }

    if (!QFile::exists(path)) {
        initializeDatabase();
        LogManager::getInstance().info("Database initialized successfully");
    }

    // initializeDatabase();
}

void DatabaseManager::initializeDatabase() {
    LogManager::getInstance().info("Initializing database");
    QSqlQuery query;

    // 创建用户表
    LogManager::getInstance().info("Creating users table");
    query.exec("CREATE TABLE IF NOT EXISTS users ("
              "id INTEGER PRIMARY KEY, "
              "username TEXT, "
              "password TEXT, "
              "role TEXT)");

    // 创建快递表
    LogManager::getInstance().info("Creating packages table");
    query.exec("CREATE TABLE IF NOT EXISTS packages ("
              "id INTEGER PRIMARY KEY, "
              "phone_number TEXT, "
              "pickup_code TEXT, "
              "locker_id INTEGER, "
              "courier_account TEXT, "
              "status TEXT, "
              "created_time DATETIME, "
              "pickup_time DATETIME)");

    // 创建储物柜表
    LogManager::getInstance().info("Creating lockers table");
    query.exec("CREATE TABLE IF NOT EXISTS lockers ("
              "id INTEGER PRIMARY KEY, "
              "status TEXT DEFAULT 'empty', "
              "package_id INTEGER)");

    // 插入默认用户数据
    LogManager::getInstance().info("Inserting default users");
    insertUser("11111111111", "admin", "admin");
    insertUser("12222222222", "user", "deliver");
    insertUser("13333333333", "guest", "user");

    // 初始化储物柜
    LogManager::getInstance().info("Initializing lockers");
    query.exec("CREATE TABLE IF NOT EXISTS lockers ("
              "id INTEGER PRIMARY KEY, "
              "status TEXT DEFAULT 'empty', "
              "package_id INTEGER)");

    // 插入初始储物柜数据
    LogManager::getInstance().info("Inserting initial lockers");
    for(int i = 1; i <= 10; i++) {
        query.prepare("INSERT OR IGNORE INTO lockers (id, status) VALUES (?, '空闲')");
        query.addBindValue(i);
        if (!query.exec()) {
            LogManager::getInstance().error("Failed to initialize locker" + QString::number(i) + ":" + query.lastError().text());
            qDebug() << "Failed to initialize locker" << i << ":" << query.lastError().text();
        }
    }

    // 创建评价表
    LogManager::getInstance().info("Creating ratings table");
    query.exec("CREATE TABLE IF NOT EXISTS ratings ("
              "id INTEGER PRIMARY KEY, "
              "score INTEGER, "
              "comment TEXT, "
              "date DATETIME DEFAULT CURRENT_TIMESTAMP)");
}


bool DatabaseManager::insertUser(const QString& username, const QString& password, const QString& role) {
    // Check if the username is an 11-digit phone number
    LogManager::getInstance().info("Inserting user:" + username + ":" + password + ":" + role);
    QRegularExpression phoneRegex("^\\d{11}$");
    if (!phoneRegex.match(username).hasMatch()) {
        LogManager::getInstance().error("Username must be an 11-digit phone number.");
        qDebug() << "Username must be an 11-digit phone number.";
        return false;
    }

    if (userExists(username)) return false;

    QSqlQuery query;
    query.prepare("INSERT INTO users (username, password, role) VALUES (?, ?, ?)");
    query.addBindValue(username);
    query.addBindValue(password);
    query.addBindValue(role);
    if (!query.exec()) {
        LogManager::getInstance().error("Failed to insert user:" + query.lastError().text());
        qDebug() << "Failed to insert user:" << query.lastError().text();
        return false;
    }
    LogManager::getInstance().info("Inserting user:" + username + ":" + password);
    return true;
}

bool DatabaseManager::verifyCredentials(const QString& username, const QString& password, const QString& role) {
    QSqlQuery query;
    query.prepare("SELECT * FROM users WHERE username = ? AND password = ? AND role = ?");
    query.addBindValue(username);
    query.addBindValue(password);
    query.addBindValue(role);
    if (query.exec() && query.next()) {
        LogManager::getInstance().info("Verifying credentials:" + username + ":" + password + ":" + role);
        return true;
    }
    LogManager::getInstance().error("Failed to verify credentials:" + username + ":" + password + ":" + role);
    return false;
}

// 检查用户是否存在
bool DatabaseManager::userExists(const QString& username) {
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM users WHERE username = :username");
    query.bindValue(":username", username);

    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
        LogManager::getInstance().info("User exists:" + username);
    }
    LogManager::getInstance().error("User does not exist:" + username);
    return false;
}

bool DatabaseManager::createPackage(const QString& phoneNumber, const QString& courierAccount, int lockerId) {
    QSqlQuery query;
    QString pickupCode = generatePickupCode(phoneNumber);
    
    query.prepare("INSERT INTO packages (phone_number, pickup_code, locker_id, "
                 "courier_account, status, created_time) "
                 "VALUES (?, ?, ?, ?, 'pending', CURRENT_TIMESTAMP)");
    query.addBindValue(phoneNumber);
    query.addBindValue(pickupCode);
    query.addBindValue(lockerId);
    query.addBindValue(courierAccount);
    
    bool success = query.exec();
    if (success) {
        LogManager::getInstance().info("Package created successfully");
    } else {
        LogManager::getInstance().error("Failed to create package:" + query.lastError().text());
    }
    return success;
}

QString DatabaseManager::generatePickupCode(const QString& phoneNumber) {
    // 使用手机号后6位作为取件码
    return phoneNumber.right(6);
}

bool DatabaseManager::verifyPickupCode(const QString& pickupCode) {
    QSqlQuery query;
    query.prepare("SELECT * FROM packages WHERE pickup_code = ? AND status = 'pending'");
    query.addBindValue(pickupCode);
    
    if (query.exec() && query.next()) {
        // 更新包裹状态为已取出
        int packageId = query.value("id").toInt();
        int lockerId = query.value("locker_id").toInt();
        
        // 更新包裹状态
        QSqlQuery updateQuery;
        updateQuery.prepare("UPDATE packages SET status = 'picked_up', pickup_time = CURRENT_TIMESTAMP "
                          "WHERE id = ?");
        updateQuery.addBindValue(packageId);
        
        // 更新储物柜状态
        QSqlQuery lockerQuery;
        lockerQuery.prepare("UPDATE lockers SET status = 'empty', package_id = NULL "
                          "WHERE id = ?");
        lockerQuery.addBindValue(lockerId);
        
        return updateQuery.exec() && lockerQuery.exec();
    }
    return false;
}

QString DatabaseManager::getPackagesByPhone(const QString& phoneNumber) {
    QSqlQuery query;

    LogManager::getInstance().info("Getting packages by phone number:" + phoneNumber);
    query.prepare("SELECT p.*, l.id as locker_number "
                 "FROM packages p "
                 "LEFT JOIN lockers l ON p.locker_id = l.id "
                 "WHERE p.phone_number = ? "
                 "ORDER BY p.created_time DESC");
    query.addBindValue(phoneNumber);
    
    QStringList results;
    if (query.exec()) {
        LogManager::getInstance().info("Packages fetched successfully");
        while (query.next()) {
            QString status = query.value("status").toString();
            QString pickupCode = query.value("pickup_code").toString();
            QString lockerNumber = query.value("locker_number").toString();
            QString createdTime = query.value("created_time").toString();
            
            results.append(QString("取件码: %1, 柜号: %2, 状态: %3, 存入时间: %4")
                         .arg(pickupCode)
                         .arg(lockerNumber)
                         .arg(status)
                         .arg(createdTime));
        }
    } else {
        LogManager::getInstance().error("Failed to fetch packages:" + query.lastError().text());
    }
    return results.join("\n");
}

bool DatabaseManager::updatePackageStatus(const QString& packageId, const QString& status) {
    QSqlQuery query;
    query.prepare("UPDATE packages SET status = ? WHERE id = ?");
    query.addBindValue(status);
    query.addBindValue(packageId);
    bool success = query.exec();
    if (success) {
        LogManager::getInstance().info("Package status updated successfully");
    } else {
        LogManager::getInstance().error("Failed to update package status:" + query.lastError().text());
    }
    return success;
}

// 新增：查询超时包裹
QStringList DatabaseManager::getOverduePackages() {
    QSqlQuery query;
    LogManager::getInstance().info("Getting overdue packages");
    query.exec("SELECT p.*, l.id as locker_number "
              "FROM packages p "
              "LEFT JOIN lockers l ON p.locker_id = l.id "
              "WHERE p.status = 'pending' "
              "AND datetime(p.created_time, '+24 hours') < datetime('now')");
    
    QStringList results;
    while (query.next()) {
        LogManager::getInstance().info("Overdue package found");
        QString phoneNumber = query.value("phone_number").toString();
        QString lockerNumber = query.value("locker_number").toString();
        QString createdTime = query.value("created_time").toString();
        
        results.append(QString("手机号: %1, 柜号: %2, 存入时间: %3")
                     .arg(phoneNumber)
                     .arg(lockerNumber)
                     .arg(createdTime));
    }
    LogManager::getInstance().info("Overdue packages fetched successfully");
    return results;
}

bool DatabaseManager::submitRating(int score, const QString& comment) {
    QSqlQuery query(db);
    query.prepare("INSERT INTO ratings (score, comment) VALUES (?, ?)");
    query.addBindValue(score);
    query.addBindValue(comment);
    
    if (!query.exec()) {
        LogManager::getInstance().error("Failed to submit rating:" + query.lastError().text());
        return false;
    }
    LogManager::getInstance().info("Rating submitted successfully");
    return true;
}

QVariantList DatabaseManager::getRatings() {
    QVariantList ratings;
    QSqlQuery query(db);
    
    if (!query.exec("SELECT score, comment, datetime(date, 'localtime') as local_date "
                   "FROM ratings ORDER BY date DESC")) {
        LogManager::getInstance().error("Failed to get ratings:" + query.lastError().text());
        return ratings;
    }
    
    while (query.next()) {
        QVariantMap rating;
        rating["score"] = query.value("score").toInt();
        rating["comment"] = query.value("comment").toString();
        rating["date"] = query.value("local_date").toString();
        ratings.append(rating);
    }
    
    LogManager::getInstance().info("Ratings fetched successfully");
    return ratings;
}