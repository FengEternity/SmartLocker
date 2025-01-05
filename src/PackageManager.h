// PackageManager.h
#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QString>
#include <QObject>
#include <QVariantMap>
#include "DatabaseManager.h"

class PackageManager : public QObject {
    Q_OBJECT

public:
    explicit PackageManager(DatabaseManager* db, QObject *parent = nullptr);

    // 快递员操作
    Q_INVOKABLE QVariantMap depositPackage(const QString& phoneNumber, int lockerId, 
                                         const QString& courierAccount);
    
    // 取件人操作
    Q_INVOKABLE QVariantMap pickupPackage(const QString& pickupCode);
    Q_INVOKABLE QStringList getPickupCodes(const QString& phoneNumber);
    
    // 通用查询
    Q_INVOKABLE QString queryPackagesByPhone(const QString& phoneNumber);
    Q_INVOKABLE QStringList getOverduePackages();
    Q_INVOKABLE bool isLockerAvailable(int lockerId);
    Q_INVOKABLE QStringList getAvailableLockers();
    Q_INVOKABLE bool updateLockerStatus(int lockerId, const QString& status);

private:
    DatabaseManager* m_db;
    QString getLockerStatus(int lockerId);
    bool updateLockerPackage(int lockerId, int packageId);
};

#endif // PACKAGEMANAGER_H
