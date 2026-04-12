#pragma once

#include <QString>

struct Transaction {
    int m_id = 0;
    QString m_type;
    double m_amount = 0.0;
    QString m_category;
    QString m_date;
    QString m_description;
    QString m_paymentMethod;
};
