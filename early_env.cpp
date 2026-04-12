#if defined(_WIN32)

#    define WIN32_LEAN_AND_MEAN
#    include <windows.h>

// 仅通过环境变量控制图形后端，避免在未知驱动上默认强制 software 反而触发崩溃。
// QUICKACCOUNT_QUICK_BACKEND：原样写入 QT_QUICK_BACKEND（如 software、rhi）。
// QUICKACCOUNT_SAFE_GRAPHICS：任意非空值且未设置 QT_QUICK_BACKEND 时，设为 software。
extern "C" void quickaccount_apply_early_env()
{
    char buf[64];

    DWORD n = GetEnvironmentVariableA("QUICKACCOUNT_QUICK_BACKEND", buf, sizeof(buf));
    if (n > 0 && n < sizeof(buf)) {
        buf[n] = '\0';
        SetEnvironmentVariableA("QT_QUICK_BACKEND", buf);
        return;
    }

    if (GetEnvironmentVariableA("QUICKACCOUNT_SAFE_GRAPHICS", nullptr, 0) == 0) {
        return;
    }

    DWORD m = GetEnvironmentVariableA("QT_QUICK_BACKEND", nullptr, 0);
    if (m == 0 && GetLastError() == ERROR_ENVVAR_NOT_FOUND) {
        SetEnvironmentVariableA("QT_QUICK_BACKEND", "software");
    }
}

#else

extern "C" void quickaccount_apply_early_env() {}

#endif
