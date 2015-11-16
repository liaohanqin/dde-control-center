#include "generatedview.h"

#include <QApplication>
#include <QClipboard>
#include <QLabel>
#include <QVBoxLayout>
#include <QTimer>
#include <QDebug>

#include <libdui/dthememanager.h>
#include <libdui/dtextbutton.h>

#include "constants.h"

#include "../helper.h"

DUI_USE_NAMESPACE

GeneratedView::GeneratedView(const QString& token, QWidget* p)
    : AbstractView(p),
      m_copyTipVisableTimer(new QTimer)
{
    setObjectName("GeneratedView");
    m_copyTipVisableTimer->setInterval(3000);
    QObject::connect(m_copyTipVisableTimer, &QTimer::timeout, [this] {
        m_copyTip->setWindowOpacity(0);
    });

    initialize();

    m_token->setText(token);

    auto button = new DTextButton(tr("Copy Code"));
    connect(button, &DTextButton::clicked, [this] {
        m_copyTip->setWindowOpacity(1);
        QString token = m_token->text();
        QApplication::clipboard()->setText(token);
        qDebug() << "Copy Code button on GeneratedView is clicked.";
        m_copyTipVisableTimer->stop();
        m_copyTipVisableTimer->start();
    });
    addButton(button);

    button = new DTextButton(tr("Cancel"));
    connect(button, &DTextButton::clicked, [this] {
        qDebug() << "cancel button on GeneratedView is clicked";
        emit cancel();
    });
    addButton(button);
}

QWidget* GeneratedView::createMainWidget()
{
    auto mainWidget = new QWidget;

    auto layout = new QVBoxLayout;
    layout->setSpacing(0);
    layout->setMargin(0);

    layout->addSpacing(6);

    m_token = new QLabel;
    m_token->setObjectName("token");
    m_token->setFixedSize(DCC::ModuleContentWidth, 50);
    m_token->setAlignment(Qt::AlignCenter);
    layout->addWidget(m_token);

    m_copyTip = new QLabel;
    m_copyTip->setObjectName("copyTip");
    m_copyTip->setWindowOpacity(0);
    m_copyTip->setText(tr("Copied to clipboard successfully"));
    m_copyTip->setAlignment(Qt::AlignCenter);
    m_copyTip->setFixedWidth(DCC::ModuleContentWidth);
    layout->addWidget(m_copyTip);
    layout->addSpacing(15);

    auto tip = new QLabel;
    tip->setObjectName("tip");
    tip->setWordWrap(true);
    tip->setAlignment(Qt::AlignVCenter);
    tip->setText(tr("To start sharing your desktop, please provide the above verification code to whom will assist you. Your shared session will begin immediately after verification code input"));
    tip->setFixedWidth(DCC::ModuleContentWidth-32);
    layout->addWidget(tip);
    layout->setAlignment(tip, Qt::AlignHCenter);
    layout->addSpacing(10);

    mainWidget->setLayout(layout);
    setStyleSheet(readStyleSheet("generatedview"));
    return mainWidget;
}
