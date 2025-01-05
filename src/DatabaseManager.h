// DatabaseManager.h
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QString>
#include <QSqlDatabase>

class DatabaseManager {
public:
    explicit DatabaseManager(const QString& path);
    bool verifyCredentials(const QString& username, const QString& password, const QString& role);
    bool insertUser(const QString& username, const QString& password, const QString& role);
    void initializeDatabase();
    bool userExists(const QString& username);

    // 新增快递相关方法
    bool createPackage(const QString& phoneNumber, const QString& courierAccount, int lockerId);
    bool updatePackageStatus(const QString& packageId, const QString& status);
    bool verifyPickupCode(const QString& pickupCode);
    QString getPackagesByPhone(const QString& phoneNumber);
    QStringList getOverduePackages();

    QSqlDatabase& getDatabase() { return db; }

private:
    QSqlDatabase db;
    QString generatePickupCode(const QString& phoneNumber);
};

#endif // DATABASEMANAGER_H