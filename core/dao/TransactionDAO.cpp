#include "TransactionDAO.h"

#include <QSqlError>
#include <QSqlQuery>
#include <QtGlobal>
#include <QVariantMap>

namespace {
constexpr double kNoAmountBound = -1.0;
}

TransactionDAO::TransactionDAO(const QSqlDatabase &db)
    : m_db(db)
{
}

bool TransactionDAO::addTransaction(const Transaction &t)
{
    QSqlQuery query(m_db);
    query.prepare(
        QStringLiteral("INSERT INTO transactions (type, amount, category, date, description, payment_method) "
                       "VALUES (?, ?, ?, ?, ?, ?)"));
    query.addBindValue(t.m_type);
    query.addBindValue(t.m_amount);
    query.addBindValue(t.m_category);
    query.addBindValue(t.m_date);
    query.addBindValue(t.m_description);
    query.addBindValue(t.m_paymentMethod);
    if (!query.exec()) {
        qWarning("TransactionDAO::addTransaction: %s", qPrintable(query.lastError().text()));
        return false;
    }
    return true;
}

QList<Transaction> TransactionDAO::getAllTransactions() const
{
    QList<Transaction> list;
    QSqlQuery query(m_db);
    query.prepare(QStringLiteral(
        "SELECT id, type, amount, category, date, description, payment_method "
        "FROM transactions ORDER BY date DESC, id DESC"));
    if (!query.exec()) {
        qWarning("TransactionDAO::getAllTransactions: %s", qPrintable(query.lastError().text()));
        return list;
    }
    while (query.next()) {
        list.append(transactionFromQuery(query));
    }
    return list;
}

bool TransactionDAO::deleteTransaction(int id)
{
    QSqlQuery query(m_db);
    query.prepare(QStringLiteral("DELETE FROM transactions WHERE id = ?"));
    query.addBindValue(id);
    if (!query.exec()) {
        qWarning("TransactionDAO::deleteTransaction: %s", qPrintable(query.lastError().text()));
        return false;
    }
    return query.numRowsAffected() > 0;
}

bool TransactionDAO::updateTransaction(const Transaction &t)
{
    QSqlQuery query(m_db);
    query.prepare(
        QStringLiteral("UPDATE transactions SET type=?, amount=?, category=?, date=?, description=?, payment_method=? "
                       "WHERE id=?"));
    query.addBindValue(t.m_type);
    query.addBindValue(t.m_amount);
    query.addBindValue(t.m_category);
    query.addBindValue(t.m_date);
    query.addBindValue(t.m_description);
    query.addBindValue(t.m_paymentMethod);
    query.addBindValue(t.m_id);
    if (!query.exec()) {
        qWarning("TransactionDAO::updateTransaction: %s", qPrintable(query.lastError().text()));
        return false;
    }
    return query.numRowsAffected() > 0;
}

QList<Transaction> TransactionDAO::searchTransactions(
    const QString &keyword,
    const QString &category,
    const QString &paymentMethod,
    const QString &startDate,
    const QString &endDate,
    const double minAmount,
    const double maxAmount) const
{
    QList<Transaction> list;
    QString sql = QStringLiteral(
        "SELECT id, type, amount, category, date, description, payment_method "
        "FROM transactions WHERE 1=1");

    if (!keyword.trimmed().isEmpty()) {
        sql += QStringLiteral(
            " AND instr(lower(ifnull(description, '')), lower(?)) > 0");
    }
    if (!category.trimmed().isEmpty()) {
        sql += QStringLiteral(" AND category = ?");
    }
    if (!paymentMethod.trimmed().isEmpty()) {
        sql += QStringLiteral(" AND payment_method = ?");
    }
    if (!startDate.trimmed().isEmpty()) {
        sql += QStringLiteral(" AND date >= ?");
    }
    if (!endDate.trimmed().isEmpty()) {
        sql += QStringLiteral(" AND date <= ?");
    }
    if (qAbs(minAmount - kNoAmountBound) > 1e-9) {
        sql += QStringLiteral(" AND amount >= ?");
    }
    if (qAbs(maxAmount - kNoAmountBound) > 1e-9) {
        sql += QStringLiteral(" AND amount <= ?");
    }

    sql += QStringLiteral(" ORDER BY date DESC, id DESC");

    QSqlQuery query(m_db);
    query.prepare(sql);

    if (!keyword.trimmed().isEmpty()) {
        query.addBindValue(keyword.trimmed());
    }
    if (!category.trimmed().isEmpty()) {
        query.addBindValue(category.trimmed());
    }
    if (!paymentMethod.trimmed().isEmpty()) {
        query.addBindValue(paymentMethod.trimmed());
    }
    if (!startDate.trimmed().isEmpty()) {
        query.addBindValue(startDate.trimmed());
    }
    if (!endDate.trimmed().isEmpty()) {
        query.addBindValue(endDate.trimmed());
    }
    if (qAbs(minAmount - kNoAmountBound) > 1e-9) {
        query.addBindValue(minAmount);
    }
    if (qAbs(maxAmount - kNoAmountBound) > 1e-9) {
        query.addBindValue(maxAmount);
    }

    if (!query.exec()) {
        qWarning("TransactionDAO::searchTransactions: %s", qPrintable(query.lastError().text()));
        return list;
    }
    while (query.next()) {
        list.append(transactionFromQuery(query));
    }
    return list;
}

Transaction TransactionDAO::transactionFromQuery(QSqlQuery &query)
{
    Transaction t;
    t.m_id = query.value(0).toInt();
    t.m_type = query.value(1).toString();
    t.m_amount = query.value(2).toDouble();
    t.m_category = query.value(3).toString();
    t.m_date = query.value(4).toString();
    t.m_description = query.value(5).toString();
    t.m_paymentMethod = query.value(6).toString();
    return t;
}

QVariantMap TransactionDAO::summary() const
{
    QVariantMap map;
    double income = 0.0;
    double expense = 0.0;

    QSqlQuery q1(m_db);
    q1.prepare(QStringLiteral("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = ?"));
    q1.addBindValue(QStringLiteral("income"));
    if (q1.exec() && q1.next()) {
        income = q1.value(0).toDouble();
    }

    QSqlQuery q2(m_db);
    q2.prepare(QStringLiteral("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = ?"));
    q2.addBindValue(QStringLiteral("expense"));
    if (q2.exec() && q2.next()) {
        expense = q2.value(0).toDouble();
    }

    map.insert(QStringLiteral("totalIncome"), income);
    map.insert(QStringLiteral("totalExpense"), expense);
    map.insert(QStringLiteral("balance"), income - expense);
    return map;
}
