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
    // 储物柜状态常量
    static const QString STATUS_EMPTY;
    static const QString STATUS_OCCUPIED;
    static const QString STATUS_MAINTENANCE;
    
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
    Q_INVOKABLE bool submitRating(int score, const QString& comment);
    Q_INVOKABLE QVariantList getRatings();

    Q_INVOKABLE QStringList getOverduePackagesByPhone(const QString& phone);

private:
    DatabaseManager* m_db;
    QString getLockerStatus(int lockerId);
    bool updateLockerPackage(int lockerId, int packageId);
};

#endif // PACKAGEMANAGER_H
