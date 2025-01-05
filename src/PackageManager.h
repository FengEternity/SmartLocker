// PackageManager.h
#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QString>
#include <QObject>
#include "DatabaseManager.h"

class PackageManager : public QObject {
    Q_OBJECT

public:
    explicit PackageManager(DatabaseManager* db, QObject *parent = nullptr);

    Q_INVOKABLE bool depositPackage(const QString& phoneNumber, int lockerId, 
                                  const QString& courierAccount);
    Q_INVOKABLE bool pickupPackage(const QString& pickupCode);
    Q_INVOKABLE QString queryPackagesByPhone(const QString& phoneNumber);
    Q_INVOKABLE QStringList getOverduePackages();
    Q_INVOKABLE bool isLockerAvailable(int lockerId);
    Q_INVOKABLE QStringList getAvailableLockers();
    Q_INVOKABLE bool updateLockerStatus(int lockerId, const QString& status);

private:
    DatabaseManager* m_db;
};

#endif // PACKAGEMANAGER_H
