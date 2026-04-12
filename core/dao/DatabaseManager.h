#pragma once

#include <QSqlDatabase>
#include <QString>

class DatabaseManager {
public:
    static DatabaseManager &instance();

    DatabaseManager(const DatabaseManager &) = delete;
    DatabaseManager &operator=(const DatabaseManager &) = delete;

    bool openDatabase();
    QSqlDatabase database() const;
    QString databaseFilePath() const;

private:
    DatabaseManager() = default;
    ~DatabaseManager() = default;

    void initTables();

    QString m_connectionName;
    QString m_databasePath;
};
