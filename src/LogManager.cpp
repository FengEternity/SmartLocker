 #include "LogManager.h"
#include <QTextStream>
#include <QDir>

LogManager* LogManager::instance = nullptr;

LogManager::LogManager(QObject *parent)
    : QObject(parent)
    , logFile(nullptr)
    , currentLevel(LogLevel::INFO)
{
    // 设置默认日志文件路径
    QString defaultLogPath = QDir::current().filePath("smartlocker.log");
    setLogFile(defaultLogPath);
}

LogManager::~LogManager()
{
    if (logFile) {
        logFile->close();
        delete logFile;
    }
}

LogManager& LogManager::getInstance()
{
    if (!instance) {
        instance = new LogManager();
    }
    return *instance;
}

void LogManager::setLogFile(const QString& filePath)
{
    QMutexLocker locker(&mutex);
    
    if (logFile) {
        logFile->close();
        delete logFile;
    }

    logFile = new QFile(filePath);
    logFilePath = filePath;

    if (!logFile->open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        qDebug() << "Failed to open log file:" << filePath;
        delete logFile;
        logFile = nullptr;
        return;
    }
}

void LogManager::setLogLevel(LogLevel level)
{
    currentLevel = level;
}

void LogManager::debug(const QString& message)
{
    log(LogLevel::DEBUG, message);
}

void LogManager::info(const QString& message)
{
    log(LogLevel::INFO, message);
}

void LogManager::warning(const QString& message)
{
    log(LogLevel::WARNING, message);
}

void LogManager::error(const QString& message)
{
    log(LogLevel::ERROR, message);
}

void LogManager::critical(const QString& message)
{
    log(LogLevel::CRITICAL, message);
}

QString LogManager::levelToString(LogLevel level)
{
    switch (level) {
        case DEBUG: return "DEBUG";
        case INFO: return "INFO";
        case WARNING: return "WARNING";
        case ERROR: return "ERROR";
        case CRITICAL: return "CRITICAL";
        default: return "UNKNOWN";
    }
}

void LogManager::log(LogLevel level, const QString& message)
{
    if (level < currentLevel) return;

    QMutexLocker locker(&mutex);

    if (!logFile || !logFile->isOpen()) return;

    QTextStream stream(logFile);
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString logMessage = QString("[%1] [%2] %3\n")
        .arg(timestamp)
        .arg(levelToString(level))
        .arg(message);

    stream << logMessage;
    stream.flush();

    // 同时输出到控制台
    qDebug().noquote() << logMessage.trimmed();
}