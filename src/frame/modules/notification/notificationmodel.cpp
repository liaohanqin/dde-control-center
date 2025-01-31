// SPDX-FileCopyrightText: 2019 - 2022 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: LGPL-3.0-or-later

#include "notificationmodel.h"
#include "model/sysitemmodel.h"
#include "model/appitemmodel.h"

using namespace dcc;
using namespace dcc::notification;

#define SYSTEMNOTIFY_NAME "SystemNotify"

NotificationModel::NotificationModel(QObject *parent)
    : QObject(parent)
    , m_sysItemModel(new SysItemModel(this))
{

}

void NotificationModel::setSysSetting(SysItemModel *item)
{
    m_sysItemModel = item;
}

void NotificationModel::clearModel()
{
    m_sysItemModel->deleteLater();
    m_sysItemModel = nullptr;
    qDeleteAll(m_appItemModels);
    m_appItemModels.clear();
}

void NotificationModel::appAdded(AppItemModel *item)
{
    m_appItemModels.append(item);
    Q_EMIT appListChanged();
}

void NotificationModel::appRemoved(const QString &appName)
{
    for (int i = 0; i < m_appItemModels.size(); i++) {
        if (m_appItemModels[i]->getActName() == appName) {
            m_appItemModels[i]->deleteLater();
            m_appItemModels[i] = nullptr;
            m_appItemModels.removeAt(i);
            break;
        }
    }

    Q_EMIT appListChanged();
}


