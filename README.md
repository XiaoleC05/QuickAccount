# 快账（QuickAccount）

基于 **Qt 6 + Qt Quick（QML）+ SQLite** 的跨平台个人记账桌面端原型：**快速记账、列表与多条件搜索、首页汇总**。数据默认保存在本机应用数据目录下的 SQLite 文件中。

---

## 功能概览

- **记账**：收入/支出、金额、日期、分类、支付方式、备注  
- **记录**：关键词、分类、支付方式、日期区间、金额区间组合筛选（参数化 SQL）  
- **首页**：总收入、总支出、结余汇总  
- **设置**：查看数据库文件路径  

---

## 技术栈

| 项目 | 说明 |
|------|------|
| 语言 | C++17 |
| UI | Qt Quick / Qt Quick Controls（Fusion 样式） |
| 构建 | CMake + Ninja（或 MinGW Makefiles） |
| 数据库 | SQLite（`QSQLITE`） |
| 架构 | QML → `TransactionService` → `TransactionDAO` → SQLite |

---

## 环境要求

- **Qt 6.2+**（需模块：`Core`、`Quick`、`Sql`、`QuickControls2`）  
- **CMake 3.16+**  
- **编译器**：本仓库在 **MinGW 64-bit**（随 Qt 安装）下验证；亦可用 MSVC 套件（需自行调整 `CMAKE_PREFIX_PATH` 与部署方式）  
- **Ninja**（可选，与 Qt 同捆的 `Tools/Ninja` 即可）

---

## 克隆与构建（Windows / MinGW 示例）

将 `CMAKE_PREFIX_PATH` 换成你的 Qt 安装路径（例如 `D:/Qt/6.11.0/mingw_64`），并把 Ninja、MinGW、`CMake` 加入当前终端 `PATH`：

```powershell
cd QuickAccount
$env:PATH = "D:\Qt\Tools\Ninja;D:\Qt\Tools\mingw1310_64\bin;D:\Qt\Tools\CMake_64\bin;" + $env:PATH

cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_PREFIX_PATH="D:/Qt/6.11.0/mingw_64" `
  -DCMAKE_CXX_COMPILER="D:/Qt/Tools/mingw1310_64/bin/g++.exe"

cmake --build build
```

构建成功后：

- 主程序：`build/QuickAccount.exe`  
- 诊断小程序（仅 Qt Core）：`build/probe/QuickAccountProbe.exe`  

Windows 下 CMake 已对上述目标配置 **`windeployqt` POST_BUILD**，依赖会拷贝到各自输出目录旁。若移动 exe，请在对应目录重新执行 `windeployqt`（主程序需加 `--qmldir` 指向本仓库 `qml` 目录）。

---

## 运行

```powershell
.\build\QuickAccount.exe
```

若双击运行缺 DLL，请确认在 **`build` 目录** 下运行，或对 exe 执行：

```powershell
& "D:\Qt\6.11.0\mingw_64\bin\windeployqt.exe" --qmldir ".\qml" ".\build\QuickAccount.exe"
```

（路径按本机 Qt 安装调整。）

---

## 可选环境变量（Windows）

| 变量 | 作用 |
|------|------|
| `QUICKACCOUNT_QUICK_BACKEND` | 写入 `QT_QUICK_BACKEND`（如 `software`、`rhi`），由 `early_env.cpp` 在进程早期处理 |
| `QUICKACCOUNT_SAFE_GRAPHICS` | 任意非空且未设置 `QT_QUICK_BACKEND` 时，设为 `software`（偏保守图形路径） |
| `QUICKACCOUNT_USE_HWGL` | 若设置，则不再由 `early_env` 自动改 `QT_QUICK_BACKEND` |

---

## 目录结构（节选）

```text
QuickAccount/
├── CMakeLists.txt
├── main.cpp
├── early_env.cpp          # Windows 下可选图形相关环境变量
├── probe.cpp              # QuickAccountProbe 源码
├── core/
│   ├── model/Transaction.h
│   ├── dao/               # DatabaseManager、TransactionDAO
│   └── service/           # TransactionService（暴露给 QML 的 TxService）
└── qml/                   # Main、首页、记账、记录、设置
```

---

## 许可证

未指定默认许可证；如需开源发布请自行补充 `LICENSE` 文件并更新本说明。
