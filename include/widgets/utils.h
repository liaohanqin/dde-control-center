#ifndef UTILS_H
#define UTILS_H

#include <QString>
#include <QLocale>
#include <QFile>
#include <QSettings>
#include <QTextCodec>

static const QStringList DCC_CONFIG_FILES {
    "/etc/deepin/dde-control-center.conf",
    "/usr/share/dde-control-center/dde-control-center.conf"
};

static const QMap<QString, QString> SYSTEM_LOCAL_MAP {
    {"zh_CN", "zh_CN"},
    {"zh_TW", "zh_TW"},
};

static const QString getLicense(const QString &filePath, const QString &type)
{
    const QString& locale { QLocale::system().name() };
    QString lang;
    if (SYSTEM_LOCAL_MAP.keys().contains(locale)) {
        lang = { SYSTEM_LOCAL_MAP.value(QLocale::system().name(), "en_US") };
    }

    if (lang.isEmpty()) {
        lang = { SYSTEM_LOCAL_MAP.value(QLocale::system().name(), "en_US") };
    }

    QString path = QString(filePath).arg(lang).arg(type);
    QFile license(path);
    if (!license.open(QIODevice::ReadOnly))
        return QString();

    const QByteArray buf = license.readAll();
    QTextCodec *tc = QTextCodec::codecForName("GBK");
    license.close();

    return tc->toUnicode(buf);
}

template <typename T>
T valueByQSettings(const QStringList& configFiles,
                   const QString&     group,
                   const QString&     key,
                   const QVariant&    failback)
{
    for (const QString& path : configFiles) {
        QSettings settings(path, QSettings::IniFormat);
        if (!group.isEmpty()) {
            settings.beginGroup(group);
        }

        const QVariant& v = settings.value(key);
        if (v.isValid()) {
            T t = v.value<T>();
            return t;
        }
    }

    return failback.value<T>();
}

#endif // UTILS_H
