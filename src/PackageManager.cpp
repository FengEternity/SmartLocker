// PackageManager.cpp
#include "PackageManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>

PackageManager::PackageManager(DatabaseManager* db, QObject *parent)
    : QObject(parent), m_db(db)
{
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
        }
    } else {
        result["success"] = false;
        result["message"] = "存放失败，请重试";
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
    
    if (query.exec() && query.next()) {
        int packageId = query.value("id").toInt();
        int lockerId = query.value("locker_id").toInt();
        
        // 更新包裹状态
        QSqlQuery updateQuery(m_db->getDatabase());
        updateQuery.prepare("UPDATE packages SET status = 'picked_up', "
                          "pickup_time = CURRENT_TIMESTAMP WHERE id = ?");
        updateQuery.addBindValue(packageId);
        
        if (updateQuery.exec()) {
            // 更新储物柜状态
            updateLockerStatus(lockerId, "empty");
            
            result["success"] = true;
            result["lockerNumber"] = lockerId;
            result["message"] = "取件成功";
        } else {
            result["success"] = false;
            result["message"] = "取件失败，请重试";
        }
    } else {
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
    
    if (query.exec()) {
        while (query.next()) {
            QString code = query.value("pickup_code").toString();
            int lockerId = query.value("locker_id").toInt();
            codes.append(QString("取件码: %1 (柜号: %2)").arg(code).arg(lockerId));
        }
    }
    
    return codes;
}

QString PackageManager::getLockerStatus(int lockerId)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT status FROM lockers WHERE id = ?");
    query.addBindValue(lockerId);
    
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
    return query.exec();
}

QString PackageManager::queryPackagesByPhone(const QString& phoneNumber)
{
    return m_db->getPackagesByPhone(phoneNumber);
}

QStringList PackageManager::getOverduePackages()
{
    return m_db->getOverduePackages();
}

bool PackageManager::isLockerAvailable(int lockerId)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("SELECT status FROM lockers WHERE id = ?");
    query.addBindValue(lockerId);
    
    if (query.exec() && query.next()) {
        return query.value("status").toString() == "empty";
    }
    return false;
}

QStringList PackageManager::getAvailableLockers()
{
    QSqlQuery query(m_db->getDatabase());
    // 修改查询，获取所有空闲的储物柜
    query.prepare("SELECT id FROM lockers WHERE status = 'empty' ORDER BY id");
    
    QStringList lockers;
    if (query.exec()) {
        while (query.next()) {
            lockers.append(QString::number(query.value("id").toInt()));
        }
    } else {
        qDebug() << "Failed to get available lockers:" << query.lastError().text();
    }
    
    return lockers;
}

bool PackageManager::updateLockerStatus(int lockerId, const QString& status)
{
    QSqlQuery query(m_db->getDatabase());
    query.prepare("UPDATE lockers SET status = ? WHERE id = ?");
    query.addBindValue(status);
    query.addBindValue(lockerId);
    return query.exec();
}