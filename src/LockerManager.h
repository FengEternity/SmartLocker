// LockerManager.h
#ifndef LOCKERMANAGER_H
#define LOCKERMANAGER_H

class LockerManager {
public:
    void assignLocker(int lockerId, int userId);
    bool isLockerAvailable(int lockerId);
    // 其他储物柜操作
};

#endif // LOCKERMANAGER_H