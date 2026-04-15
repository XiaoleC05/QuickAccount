#include "TransactionService.h"

#include "core/dao/DatabaseManager.h"
#include "core/model/Transaction.h"

#include <QDate>
#include <QSqlDatabase>
#include <QtGlobal>

namespace {
constexpr double kNoAmountFilter = -1.0;

bool isValidType(const QString &type)
{
    return type == QStringLiteral("income") || type == QStringLiteral("expense");
}

bool isValidIsoDate(const QString &date)
{
    return date.size() == 10 && QDate::fromString(date, QStringLiteral("yyyy-MM-dd")).isValid();
}

bool isAllowedOption(const QString &value, const QStringList &allowed)
{
    return !value.isEmpty() && allowed.contains(value);
}

bool fillValidatedTransaction(
    Transaction &out,
    const QString &type,
    const double amount,
    const QString &category,
    const QString &date,
    const QString &description,
    const QString &paymentMethod,
    const QStringList &allowedCat,
    const QStringList &allowedPay)
{
    if (!isValidType(type)) {
        return false;
    }
    if (!(amount > 0.0) || amount > 1e12) {
        return false;
    }
    const QString cat = category.trimmed();
    const QString pay = paymentMethod.trimmed();
    if (!isAllowedOption(cat, allowedCat) || !isAllowedOption(pay, allowedPay)) {
        return false;
    }
    const QString d = date.trimmed();
    if (!isValidIsoDate(d)) {
        return false;
    }

    out.m_type = type;
    out.m_amount = amount;
    out.m_category = cat;
    out.m_date = d;
    out.m_description = description.trimmed();
    out.m_paymentMethod = pay;
    return true;
}

QString normalizedOptionalDate(const QString &raw)
{
    const QString value = raw.trimmed();
    if (value.isEmpty()) {
        return QString();
    }
    return isValidIsoDate(value) ? value : QString();
}
}

TransactionService::TransactionService(QObject *parent)
    : QObject(parent)
{
}

bool TransactionService::ensureDao()
{
    if (m_dao) {
        return true;
    }
    if (!DatabaseManager::instance().openDatabase()) {
        qWarning("TransactionService: database open failed");
        return false;
    }
    const QSqlDatabase db = DatabaseManager::instance().database();
    if (!db.isValid()) {
        qWarning("TransactionService: invalid database handle");
        return false;
    }
    m_dao = std::make_unique<TransactionDAO>(db);
    return true;
}

bool TransactionService::addTransaction(
    const QString &type,
    const double amount,
    const QString &category,
    const QString &date,
    const QString &description,
    const QString &paymentMethod)
{
    const QStringList allowedCat = categoryOptions();
    const QStringList allowedPay = paymentMethodOptions();
    Transaction t;
    // REVIEW: 安全校验（类型/金额/枚举类字段白名单）
    if (!fillValidatedTransaction(
            t,
            type,
            amount,
            category,
            date,
            description,
            paymentMethod,
            allowedCat,
            allowedPay)) {
        qWarning("TransactionService::addTransaction: validation failed");
        return false;
    }

    if (!ensureDao()) {
        return false;
    }
    if (m_dao->addTransaction(t)) {
        emit dataChanged();
        return true;
    }
    return false;
}

QVariantList TransactionService::getTransactions()
{
    if (!ensureDao()) {
        return {};
    }
    QVariantList out;
    const QList<Transaction> rows = m_dao->getAllTransactions();
    for (const Transaction &t : rows) {
        out.append(transactionToMap(t));
    }
    return out;
}

void TransactionService::deleteTransaction(int id)
{
    if (id <= 0) {
        return;
    }
    if (!ensureDao()) {
        return;
    }
    if (m_dao->deleteTransaction(id)) {
        emit dataChanged();
    }
}

bool TransactionService::updateTransaction(
    const int id,
    const QString &type,
    const double amount,
    const QString &category,
    const QString &date,
    const QString &description,
    const QString &paymentMethod)
{
    // REVIEW: 安全校验（与 addTransaction 一致）
    if (id <= 0) {
        return false;
    }
    const QStringList allowedCat = categoryOptions();
    const QStringList allowedPay = paymentMethodOptions();
    Transaction t;
    if (!fillValidatedTransaction(
            t,
            type,
            amount,
            category,
            date,
            description,
            paymentMethod,
            allowedCat,
            allowedPay)) {
        return false;
    }
    if (!ensureDao()) {
        return false;
    }
    t.m_id = id;

    const bool ok = m_dao->updateTransaction(t);
    if (ok) {
        emit dataChanged();
    }
    return ok;
}

QVariantList TransactionService::searchTransactions(
    const QString &keyword,
    const QString &category,
    const QString &paymentMethod,
    const QString &startDate,
    const QString &endDate,
    const double minAmount,
    const double maxAmount)
{
    // REVIEW: 安全校验（金额边界仅作合理性限制，避免异常输入）
    double minF = minAmount;
    double maxF = maxAmount;
    if (qAbs(minF - kNoAmountFilter) > 1e-9 && (minF < 0.0 || minF > 1e12)) {
        minF = kNoAmountFilter;
    }
    if (qAbs(maxF - kNoAmountFilter) > 1e-9 && (maxF < 0.0 || maxF > 1e12)) {
        maxF = kNoAmountFilter;
    }
    if (qAbs(minF - kNoAmountFilter) > 1e-9 && qAbs(maxF - kNoAmountFilter) > 1e-9 && minF > maxF) {
        const double tmp = minF;
        minF = maxF;
        maxF = tmp;
    }

    const QString cat = category.trimmed();
    const QString pay = paymentMethod.trimmed();
    const QStringList allowedCat = categoryOptions();
    const QStringList allowedPay = paymentMethodOptions();
    const QString categoryArg = isAllowedOption(cat, allowedCat) ? cat : QString();
    const QString paymentArg = isAllowedOption(pay, allowedPay) ? pay : QString();
    const QString startDateArg = normalizedOptionalDate(startDate);
    const QString endDateArg = normalizedOptionalDate(endDate);

    if (!ensureDao()) {
        return {};
    }
    QVariantList out;
    const QList<Transaction> rows = m_dao->searchTransactions(
        keyword,
        categoryArg,
        paymentArg,
        startDateArg,
        endDateArg,
        minF,
        maxF);
    for (const Transaction &t : rows) {
        out.append(transactionToMap(t));
    }
    return out;
}

QVariantMap TransactionService::getSummary()
{
    if (!ensureDao()) {
        QVariantMap empty;
        empty.insert(QStringLiteral("totalIncome"), 0.0);
        empty.insert(QStringLiteral("totalExpense"), 0.0);
        empty.insert(QStringLiteral("balance"), 0.0);
        return empty;
    }
    return m_dao->summary();
}

QStringList TransactionService::categoryOptions() const
{
    return {
        QStringLiteral("餐饮"),
        QStringLiteral("交通"),
        QStringLiteral("购物"),
        QStringLiteral("娱乐"),
        QStringLiteral("医疗"),
        QStringLiteral("教育"),
        QStringLiteral("住房"),
        QStringLiteral("其他"),
    };
}

QStringList TransactionService::paymentMethodOptions() const
{
    return {
        QStringLiteral("现金"),
        QStringLiteral("借记卡"),
        QStringLiteral("信用卡"),
        QStringLiteral("支付宝"),
        QStringLiteral("微信"),
        QStringLiteral("其他"),
    };
}

QString TransactionService::databaseFilePath() const
{
    if (!const_cast<TransactionService *>(this)->ensureDao()) {
        return QString();
    }
    return DatabaseManager::instance().databaseFilePath();
}

QVariantMap TransactionService::transactionToMap(const Transaction &t)
{
    QVariantMap m;
    m.insert(QStringLiteral("id"), t.m_id);
    m.insert(QStringLiteral("type"), t.m_type);
    m.insert(QStringLiteral("amount"), t.m_amount);
    m.insert(QStringLiteral("category"), t.m_category);
    m.insert(QStringLiteral("date"), t.m_date);
    m.insert(QStringLiteral("description"), t.m_description);
    m.insert(QStringLiteral("paymentMethod"), t.m_paymentMethod);
    return m;
}
