// PackageManager.h
#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include <QString>

class PackageManager {
public:
    void storePackage(int packageId, int lockerId);
    void updatePackageStatus(int packageId, const QString& status);
    // 其他包裹操作
};

#endif // PACKAGEMANAGER_H