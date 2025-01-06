// PackageManager.cpp
#include "PackageManager.h"
#include "LogManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>

const QString PackageManager::STATUS_EMPTY = "空闲";
const QString PackageManager::STATUS_OCCUPIED = "使用中";
const QString PackageManager::STATUS_MAINTENANCE = "维修中";

PackageManager::PackageManager(DatabaseManager* db, QObject *parent)
    : QObject(parent), m_db(db)
{
    LogManager::getInstance().info("PackageManager initialized");
}

QVariantMap PackageManager::depositPackage(const QString& phoneNumber, int lockerId, 
                                         const QString& courierAccount)
{
    QVariantMap result;
    
    // 检查储物柜是否可用
    if (!isLockerAvailable(lockerId)) {
        result["success"] = false;
        result["message"] = "储物柜不可用";
        return result;
    }

    // 创建包裹记录
    if (m_db->createPackage(phoneNumber, courierAccount, lockerId)) {
        // 更新储物柜状态
        updateLockerStatus(lockerId, "occupied");
        
        // 获取取件码
        QSqlQuery query(m_db->getDatabase());
        query.prepare("SELECT pickup_code FROM packages WHERE phone_number = ? "
                     "AND locker_id = ? ORDER BY created_time DESC LIMIT 1");
        query.addBindValue(phoneNumber);
        query.addBindValue(lockerId);
        
        if (query.exec() && query.next()) {
            result["success"] = true;
            result["pickupCode"] = query.value("pickup_code").toString();
            result["message"] = "快递存放成功";
            LogManager::getInstance().info("Package deposited successfully");
        }
    } else {
        result["success"] = false;
        result["message"] = "存放失败，请重试";
        LogManager::getInstance().error("Package deposit failed");
    }
    
    return result;
}

QVariantMap PackageManager::pickupPackage(const QString& pickupCode)
{
    QVariantMap result;
    
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT id, locker_id FROM packages WHERE pickup_code = ? "
                 "AND status = 'pending'");
    query.addBindValue(pickupCode);
    LogManager::getInstance().info("Querying package by pickup code:" + pickupCode);
    if (query.exec() && query.next()) {
        LogManager::getInstance().info("Package found");
        int packageId = query.value("id").toInt();
        int lockerId = query.value("locker_id").toInt();
        
        // 更新包裹状态
        QSqlQuery updateQuery(m_db->getDatabase());
        updateQuery.prepare("UPDATE packages SET status = 'picked_up', "
                          "pickup_time = CURRENT_TIMESTAMP WHERE id = ?");
        updateQuery.addBindValue(packageId);
        
        if (updateQuery.exec()) {
            LogManager::getInstance().info("Package status updated to picked_up");
            // 更新储物柜状态
            updateLockerStatus(lockerId, "empty");
            
            result["success"] = true;
            result["lockerNumber"] = lockerId;
            result["message"] = "取件成功";
        } else {
            LogManager::getInstance().error("Failed to update package status to picked_up");
            result["success"] = false;
            result["message"] = "取件失败，请重试";
        }
    } else {
        LogManager::getInstance().error("Package not found or already picked up");
        result["success"] = false;
        result["message"] = "取件码无效或已使用";
    }
    
    return result;
}

QStringList PackageManager::getPickupCodes(const QString& phoneNumber)
{
    QStringList codes;
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT pickup_code, locker_id FROM packages "
                 "WHERE phone_number = ? AND status = 'pending'");
    query.addBindValue(phoneNumber);
    LogManager::getInstance().info("Querying pickup codes for phone number:" + phoneNumber);
    if (query.exec()) {
        while (query.next()) {
            QString code = query.value("pickup_code").toString();
            int lockerId = query.value("locker_id").toInt();
            codes.append(QString("取件码: %1 (柜号: %2)").arg(code).arg(lockerId));
            LogManager::getInstance().info("Pickup code found:" + code + " (Locker ID: " + QString::number(lockerId) + ")");
        }
    } else {
        LogManager::getInstance().error("Failed to query pickup codes:" + query.lastError().text());
    }
    
    return codes;
}

QString PackageManager::getLockerStatus(int lockerId)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT status FROM lockers WHERE id = ?");
    query.addBindValue(lockerId);
    LogManager::getInstance().info("Querying locker status for locker ID:" + QString::number(lockerId));
    if (query.exec() && query.next()) {
        return query.value("status").toString();
    }
    return "unknown";
}

bool PackageManager::updateLockerPackage(int lockerId, int packageId)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("UPDATE lockers SET package_id = ? WHERE id = ?");
    query.addBindValue(packageId);
    query.addBindValue(lockerId);
    LogManager::getInstance().info("Updating locker package for locker ID:" + QString::number(lockerId) + " with package ID:" + QString::number(packageId));
    return query.exec();
}

QString PackageManager::queryPackagesByPhone(const QString& phoneNumber)
{
    LogManager::getInstance().info("Querying packages by phone number:" + phoneNumber);
    return m_db->getPackagesByPhone(phoneNumber);
}

QStringList PackageManager::getOverduePackages()
{
    LogManager::getInstance().info("Querying overdue packages");
    return m_db->getOverduePackages();
}

bool PackageManager::isLockerAvailable(int lockerId)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT status FROM lockers WHERE id = ?");
    query.addBindValue(lockerId);
    LogManager::getInstance().info("Checking locker availability for locker ID:" + QString::number(lockerId));
    if (query.exec() && query.next()) {
        return query.value("status").toString() == "empty";
    }
    return false;
}

QStringList PackageManager::getAvailableLockers()
{
    QSqlQuery query(m_db->getDatabase());
    
    // 首先检查所有储物柜
    qDebug() << "检查所有储物柜状态...";
    QSqlQuery checkQuery(m_db->getDatabase());
    checkQuery.exec("SELECT id, status FROM lockers");
    while (checkQuery.next()) {
        qDebug() << "储物柜" << checkQuery.value("id").toInt() 
                << "状态:" << checkQuery.value("status").toString();
    }
    
    query.prepare("SELECT id FROM lockers WHERE status = '空闲' ORDER BY id");
    qDebug() << "正在查询可用储物柜...";
    LogManager::getInstance().info("Querying available lockers");
    
    QStringList lockers;
    if (query.exec()) {
        while (query.next()) {
            QString lockerId = QString::number(query.value("id").toInt());
            lockers.append(lockerId);
            qDebug() << "找到可用储物柜:" << lockerId;
        }
        qDebug() << "可用储物柜总数:" << lockers.size();
    } else {
        qDebug() << "查询储物柜失败:" << query.lastError().text();
        LogManager::getInstance().error("Failed to get available lockers:" + query.lastError().text());
    }
    
    return lockers;
}

bool PackageManager::updateLockerStatus(int lockerId, const QString& status)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("UPDATE lockers SET status = ? WHERE id = ?");
    query.addBindValue(status);
    query.addBindValue(lockerId);
    LogManager::getInstance().info("Updating locker status for locker ID:" + QString::number(lockerId) + " to:" + status);
    return query.exec();
}

bool PackageManager::submitRating(int score, const QString& comment) {
    LogManager::getInstance().info("Submitting rating with score:" + QString::number(score) + " and comment:" + comment);
    return m_db->submitRating(score, comment);
}

QVariantList PackageManager::getRatings() {
    LogManager::getInstance().info("Getting ratings");
    return m_db->getRatings();
}

QStringList PackageManager::getOverduePackagesByPhone(const QString& phone)
{
    QStringList result;
    QSqlQuery query(m_db->getDatabase());
    
    // 修改查询语句以匹配实际的数据库表结构
    query.prepare(
        "SELECT phone_number, locker_id, created_time "  // 修改列名以匹配表结构
        "FROM packages "  // 不需要别名 p
        "WHERE phone_number = ? "  // 修改列名
        "AND status = 'pending' "
        "AND DATETIME(created_time, '+24 hours') < DATETIME('now')"  // 使用 created_time
    );
    
    query.addBindValue(phone);
    
    if (query.exec()) {
        while (query.next()) {
            QString packageInfo = QString("手机号: %1, 柜号: %2, 存入时间: %3")
                .arg(query.value(0).toString())
                .arg(query.value(1).toString())
                .arg(query.value(2).toString());
            result.append(packageInfo);
            qDebug() << "Found overdue package:" << packageInfo;
        }
    } else {
        qWarning() << "Failed to query overdue packages for phone:" << phone;
        qWarning() << "Error:" << query.lastError().text();
        qWarning() << "Query:" << query.lastQuery();
    }
    
    qDebug() << "Total overdue packages found:" << result.size();
    return result;
}
