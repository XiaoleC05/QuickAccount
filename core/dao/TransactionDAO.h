#pragma once

#include "core/model/Transaction.h"

#include <QList>
#include <QSqlDatabase>
#include <QString>
#include <QVariantMap>

class TransactionDAO {
public:
    explicit TransactionDAO(const QSqlDatabase &db);

    bool addTransaction(const Transaction &t);
    QList<Transaction> getAllTransactions() const;
    bool deleteTransaction(int id);
    bool updateTransaction(const Transaction &t);

    QList<Transaction> searchTransactions(
        const QString &keyword,
        const QString &category,
        const QString &paymentMethod,
        const QString &startDate,
        const QString &endDate,
        double minAmount,
        double maxAmount) const;

    QVariantMap summary() const;

private:
    QSqlDatabase m_db;

    static Transaction transactionFromQuery(class QSqlQuery &query);
};
