#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>

class SettingsManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isDarkMode READ isDarkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    bool isDarkMode() const;
    void setDarkMode(bool dark);

    QString language() const;
    void setLanguage(const QString& lang);

signals:
    void darkModeChanged();
    void languageChanged();

private:
    QSettings m_settings;
};

#endif // SETTINGSMANAGER_H 