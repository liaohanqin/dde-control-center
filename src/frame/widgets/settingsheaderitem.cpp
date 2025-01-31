// SPDX-FileCopyrightText: 2011 - 2022 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: LGPL-3.0-or-later

#include "widgets/settingsheaderitem.h"

#include "widgets/labels/normallabel.h"

namespace dcc {
namespace widgets {

SettingsHeaderItem::SettingsHeaderItem(QWidget *parent)
    : SettingsItem(parent),
      m_mainLayout(new QHBoxLayout),
      m_headerText(new TitleLabel)
{
    m_headerText->setObjectName("SettingsHeaderItemTitle");

    m_mainLayout->addSpacing(20);
    m_mainLayout->addWidget(m_headerText);
    m_mainLayout->addStretch();

    setFixedHeight(24);
    m_mainLayout->setSpacing(0);
    m_mainLayout->setMargin(0);

    setLayout(m_mainLayout);
}

void SettingsHeaderItem::setTitle(const QString &title)
{
    m_headerText->setText(title);
}

void SettingsHeaderItem::setRightWidget(QWidget *widget)
{
    Q_ASSERT(widget);

    m_mainLayout->addWidget(widget, 0, Qt::AlignRight);
}

}
}
