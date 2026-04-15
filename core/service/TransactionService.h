#pragma once

#include "core/dao/TransactionDAO.h"

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <memory>

class TransactionService : public QObject {
    Q_OBJECT
public:
    explicit TransactionService(QObject *parent = nullptr);

    Q_INVOKABLE bool addTransaction(
        const QString &type,
        double amount,
        const QString &category,
        const QString &date,
        const QString &description,
        const QString &paymentMethod);

    Q_INVOKABLE QVariantList getTransactions();
    Q_INVOKABLE void deleteTransaction(int id);
    Q_INVOKABLE bool updateTransaction(
        int id,
        const QString &type,
        double amount,
        const QString &category,
        const QString &date,
        const QString &description,
        const QString &paymentMethod);

    Q_INVOKABLE QVariantList searchTransactions(
        const QString &keyword,
        const QString &category,
        const QString &paymentMethod,
        const QString &startDate,
        const QString &endDate,
        double minAmount,
        double maxAmount);

    Q_INVOKABLE QVariantMap getSummary();

    Q_INVOKABLE QStringList categoryOptions() const;
    Q_INVOKABLE QStringList paymentMethodOptions() const;
    Q_INVOKABLE QString databaseFilePath() const;

signals:
    void dataChanged();

private:
    bool ensureDao();

    std::unique_ptr<TransactionDAO> m_dao;

    static QVariantMap transactionToMap(const struct Transaction &t);
};
