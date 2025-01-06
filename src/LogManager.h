 // LogManager.h
#ifndef LOGMANAGER_H
#define LOGMANAGER_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QDateTime>
#include <QMutex>
#include <QDebug>

class LogManager : public QObject {
    Q_OBJECT

public:
    enum LogLevel {
        DEBUG,
        INFO,
        WARNING,
        ERROR,
        CRITICAL
    };
    Q_ENUM(LogLevel)

    static LogManager& getInstance();

    Q_INVOKABLE void debug(const QString& message);
    Q_INVOKABLE void info(const QString& message);
    Q_INVOKABLE void warning(const QString& message);
    Q_INVOKABLE void error(const QString& message);
    Q_INVOKABLE void critical(const QString& message);

    void setLogFile(const QString& filePath);
    void setLogLevel(LogLevel level);

private:
    explicit LogManager(QObject *parent = nullptr);
    ~LogManager();
    
    void log(LogLevel level, const QString& message);
    QString levelToString(LogLevel level);
    
    static LogManager* instance;
    QFile* logFile;
    LogLevel currentLevel;
    QMutex mutex;
    QString logFilePath;
};

#endif // LOGMANAGER_H