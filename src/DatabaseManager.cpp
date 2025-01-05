#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QFile>
#include <QDebug>
#include <QRegularExpression>
#include <QRandomGenerator>

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
    query.exec("CREATE TABLE IF NOT EXISTS users ("
              "id INTEGER PRIMARY KEY, "
              "username TEXT, "
              "password TEXT, "
              "role TEXT)");

    // 创建快递表
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
    query.exec("CREATE TABLE IF NOT EXISTS lockers ("
              "id INTEGER PRIMARY KEY, "
              "status TEXT, "
              "package_id INTEGER)");

    // 插入默认用户数据
    insertUser("11111111111", "admin", "admin");
    insertUser("12222222222", "user", "deliver");
    insertUser("13333333333", "guest", "user");

    // 初始化一些测试储物柜
    for(int i = 1; i <= 10; i++) {
        query.prepare("INSERT OR IGNORE INTO lockers (id, status) VALUES (?, 'empty')");
        query.addBindValue(i);
        query.exec();
    }
}


bool DatabaseManager::insertUser(const QString& username, const QString& password, const QString& role) {
    // Check if the username is an 11-digit phone number
    QRegularExpression phoneRegex("^\\d{11}$");
    if (!phoneRegex.match(username).hasMatch()) {
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

bool DatabaseManager::createPackage(const QString& phoneNumber, const QString& courierAccount, int lockerId) {
    QSqlQuery query;
    QString pickupCode = generatePickupCode();
    
    query.prepare("INSERT INTO packages (phone_number, pickup_code, locker_id, "
                 "courier_account, status, created_time) "
                 "VALUES (?, ?, ?, ?, 'pending', CURRENT_TIMESTAMP)");
    query.addBindValue(phoneNumber);
    query.addBindValue(pickupCode);
    query.addBindValue(lockerId);
    query.addBindValue(courierAccount);
    
    return query.exec();
}

QString DatabaseManager::generatePickupCode() {
    // 使用 QRandomGenerator 替代 qrand
    QRandomGenerator& generator = *QRandomGenerator::system();
    QString code;
    for(int i = 0; i < 6; i++) {
        code.append(QString::number(generator.bounded(10))); // 生成 0-9 的随机数
    }
    return code;
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
    query.prepare("SELECT p.*, l.id as locker_number "
                 "FROM packages p "
                 "LEFT JOIN lockers l ON p.locker_id = l.id "
                 "WHERE p.phone_number = ? "
                 "ORDER BY p.created_time DESC");
    query.addBindValue(phoneNumber);
    
    QStringList results;
    if (query.exec()) {
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
    }
    return results.join("\n");
}

bool DatabaseManager::updatePackageStatus(const QString& packageId, const QString& status) {
    QSqlQuery query;
    query.prepare("UPDATE packages SET status = ? WHERE id = ?");
    query.addBindValue(status);
    query.addBindValue(packageId);
    return query.exec();
}

// 新增：查询超时包裹
QStringList DatabaseManager::getOverduePackages() {
    QSqlQuery query;
    query.exec("SELECT p.*, l.id as locker_number "
              "FROM packages p "
              "LEFT JOIN lockers l ON p.locker_id = l.id "
              "WHERE p.status = 'pending' "
              "AND datetime(p.created_time, '+24 hours') < datetime('now')");
    
    QStringList results;
    while (query.next()) {
        QString phoneNumber = query.value("phone_number").toString();
        QString lockerNumber = query.value("locker_number").toString();
        QString createdTime = query.value("created_time").toString();
        
        results.append(QString("手机号: %1, 柜号: %2, 存入时间: %3")
                     .arg(phoneNumber)
                     .arg(lockerNumber)
                     .arg(createdTime));
    }
    return results;
}