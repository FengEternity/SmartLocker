// PackageManager.cpp
#include "PackageManager.h"
#include <QSqlQuery>

PackageManager::PackageManager(DatabaseManager* db, QObject *parent)
    : QObject(parent), m_db(db)
{
}

bool PackageManager::depositPackage(const QString& phoneNumber, int lockerId, 
                                  const QString& courierAccount)
{
    return m_db->createPackage(phoneNumber, courierAccount, lockerId);
}

bool PackageManager::pickupPackage(const QString& pickupCode)
{
    return m_db->verifyPickupCode(pickupCode);
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
    query.exec("SELECT id FROM lockers WHERE status = 'empty'");
    
    QStringList lockers;
    while (query.next()) {
        lockers.append(QString::number(query.value("id").toInt()));
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