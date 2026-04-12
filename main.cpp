#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "core/service/TransactionService.h"

extern "C" void quickaccount_apply_early_env();

int main(int argc, char *argv[])
{
    quickaccount_apply_early_env();

#if defined(Q_OS_WIN)
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#endif

    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("QuickAccount"));
    QCoreApplication::setOrganizationName(QStringLiteral("QuickAccount"));

    const QString appDir = QCoreApplication::applicationDirPath();
    QCoreApplication::addLibraryPath(appDir);

    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    static TransactionService s_txService;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("TxService"), &s_txService);
    qWarning().noquote() << "[QuickAccount] load QML module…";
    engine.loadFromModule(QStringLiteral("QuickAccount"), QStringLiteral("Main"));
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "[QuickAccount] QML load failed (root empty)";
        return -1;
    }
    qWarning().noquote() << "[QuickAccount] QML root ready";
    return app.exec();
}
