#include "accountsmodule.h"
#include "accountsdetailwidget.h"

AccountsModule::AccountsModule(FrameProxyInterface *frame, QObject *parent)
    : QObject(parent),
      ModuleInterface(frame),

      m_accountsWidget(nullptr)
{
}

void AccountsModule::initialize()
{
    m_userList = new UserModel;
    m_accountsWorker = new AccountsWorker(m_userList);

    m_userList->moveToThread(qApp->thread());
    m_accountsWorker->moveToThread(qApp->thread());
}

void AccountsModule::moduleActive()
{
}

void AccountsModule::moduleDeactive()
{
}

ModuleWidget *AccountsModule::moduleWidget()
{
    if (!m_accountsWidget)
    {
        m_accountsWidget = new AccountsWidget;

        connect(m_accountsWidget, &AccountsWidget::showAccountsDetail, this, &AccountsModule::showAccountsDetail);
        connect(m_userList, &UserModel::userAdded, m_accountsWidget, &AccountsWidget::addUser);
        connect(m_userList, &UserModel::userRemoved, m_accountsWidget, &AccountsWidget::removeUser);

        for (auto user : m_userList->userList())
            m_accountsWidget->addUser(user);
    }

    return m_accountsWidget;
}

const QString AccountsModule::name() const
{
    return "Accounts";
}

AccountsModule::~AccountsModule()
{
    m_userList->deleteLater();
    m_accountsWorker->deleteLater();
}

void AccountsModule::showAccountsDetail(User *account)
{
    AccountsDetailWidget *w = new AccountsDetailWidget(account);

    connect(w, &AccountsDetailWidget::requestSetAutoLogin, m_accountsWorker, &AccountsWorker::setAutoLogin);
//    connect(w, &AccountsDetailWidget::requestSetAutoLogin, [=] (User *u, bool b) { m_accountsWorker->setAutoLogin(u, b); });

    m_frameProxy->pushWidget(this, w);
}

void AccountsModule::contentPopped(ContentWidget * const w)
{
    w->deleteLater();
}
