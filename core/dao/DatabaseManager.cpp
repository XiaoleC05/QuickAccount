#include "DatabaseManager.h"

#include <QCoreApplication>
#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>

DatabaseManager &DatabaseManager::instance()
{
    static DatabaseManager inst;
    return inst;
}

bool DatabaseManager::openDatabase()
{
    if (QSqlDatabase::contains(m_connectionName)) {
        return true;
    }

    m_connectionName = QStringLiteral("quickaccount_connection");
    const QString base = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation);
    QDir().mkpath(base);
    m_databasePath = base + QStringLiteral("/quickaccount.db");

    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
    db.setDatabaseName(m_databasePath);
    if (!db.open()) {
        qWarning("DatabaseManager: failed to open database: %s",
                 qPrintable(db.lastError().text()));
        return false;
    }

    initTables();
    return true;
}

QSqlDatabase DatabaseManager::database() const
{
    return QSqlDatabase::database(m_connectionName);
}

QString DatabaseManager::databaseFilePath() const
{
    return m_databasePath;
}

void DatabaseManager::initTables()
{
    QSqlQuery query(database());
    const QString sql = QStringLiteral(
        "CREATE TABLE IF NOT EXISTS transactions ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "type TEXT NOT NULL,"
        "amount REAL NOT NULL,"
        "category TEXT NOT NULL,"
        "date TEXT NOT NULL,"
        "description TEXT,"
        "payment_method TEXT NOT NULL"
        ")");
    if (!query.exec(sql)) {
        qWarning("DatabaseManager: init tables failed: %s",
                 qPrintable(query.lastError().text()));
    }

    QSqlQuery idx(database());
    idx.exec(QStringLiteral(
        "CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)"));
    idx.exec(QStringLiteral(
        "CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category)"));
}
