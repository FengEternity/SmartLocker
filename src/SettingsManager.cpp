#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_settings("SmartLocker", "Settings")
{
}

bool SettingsManager::isDarkMode() const
{
    return m_settings.value("darkMode", false).toBool();
}

void SettingsManager::setDarkMode(bool dark)
{
    if (isDarkMode() != dark) {
        m_settings.setValue("darkMode", dark);
        emit darkModeChanged();
    }
}

QString SettingsManager::language() const
{
    return m_settings.value("language", "zh").toString();
}

void SettingsManager::setLanguage(const QString& lang)
{
    if (language() != lang) {
        m_settings.setValue("language", lang);
        emit languageChanged();
    }
} 