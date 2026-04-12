#include <QCoreApplication>
#include <cstdio>

// 仅链接 Qt6Core：若本程序也 0xc0000005，问题在 Qt 安装/系统 DLL；若本程序正常而 QuickAccount.exe 崩，问题在 Quick/QML/业务。
int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    std::puts("QuickAccountProbe: Qt6Core OK");
    return 0;
}
