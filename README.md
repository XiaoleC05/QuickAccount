# 快账（QuickAccount）

[![Build](https://github.com/XiaoleC05/QuickAccount/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/XiaoleC05/QuickAccount/actions/workflows/build.yml)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey.svg)](#从源码构建)
[![Qt](https://img.shields.io/badge/Qt-6-41cd52.svg)](https://www.qt.io/)
[![CMake](https://img.shields.io/badge/CMake-%E2%89%A53.16-064f8d.svg)](https://cmake.org/)
[![C++](https://img.shields.io/badge/C%2B%2B-17-00599c.svg)](https://en.cppreference.com/w/cpp/17)
[![License](https://img.shields.io/badge/license-TBD-lightgrey.svg)](LICENSE)

> 若仓库已 fork 或改名，请将上方 **Build** 徽章链接中的 `XiaoleC05/QuickAccount` 替换为实际的 `所有者/仓库名`。

一款面向个人使用的**本地记账**桌面应用：数据保存在本机 SQLite 数据库中，无需联网即可记账、查账与简单统计。当前版本以**开源源码**形式提供，适合希望自行编译安装或参与改进的读者。

---

## 能做什么

| 能力 | 说明 |
|------|------|
| **记账** | 记录收入或支出，填写金额、日期、分类、支付方式与备注 |
| **查账** | 在「记录」中按关键词、分类、支付方式、日期区间、金额区间组合筛选 |
| **概览** | 在「首页」查看总收入、总支出与结余 |
| **数据位置** | 在「设置」中查看数据库文件路径，便于备份或迁移 |

所有账目数据均存储在**当前计算机**上，不会由本应用主动上传到云端（除非使用者自行拷贝数据库文件）。

---

## 运行前需要知道的事

- 本仓库**默认不附带**已签名的安装包；通常需要从**源码编译**后运行（见下文「从源码构建」）。  
- 若后续提供 **Releases** 中的预编译版本，安装与运行方式以发布页说明为准。  
- 支持平台与 Qt 官方对 **Qt 6 + 桌面** 的支持范围一致；当前工程以 **Windows + MinGW** 为主要验证环境。

---

## 从源码构建（面向贡献者与高级用户）

### 依赖

- **CMake** 3.16 及以上  
- **Qt 6.2** 及以上，并安装模块：**Qt Quick**、**Qt Quick Controls 2**、**Qt SQL**（及构建所需的 **Qt Core**）  
- 推荐 **Ninja** 与 **MinGW 64-bit**（与 Qt 在线安装程序中选项一致）；也可改用 **MSVC** 等工具链，需自行调整 `CMAKE_PREFIX_PATH` 与部署步骤  

### 克隆与编译（Windows / MinGW 示例）

请将示例中的 Qt 路径替换为**本机实际安装路径**（指向包含 `lib/cmake/Qt6` 的套件根目录，例如 `…/6.x.x/mingw_64`）：

```powershell
git clone https://github.com/OWNER/QuickAccount.git
cd QuickAccount
```

将 `OWNER` 替换为 GitHub 用户名或组织名（使用官方仓库时填作者账号；使用 fork 时填自己的账号）。

```powershell
# 将 Ninja、CMake、MinGW 加入 PATH（路径按本机 Qt 安装位置修改）
$env:PATH = "<Qt的Tools目录>\Ninja;<Qt的Tools目录>\mingw1310_64\bin;<Qt的Tools目录>\CMake_64\bin;" + $env:PATH

cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_PREFIX_PATH="<Qt套件路径>/mingw_64" `
  -DCMAKE_CXX_COMPILER="<Qt的Tools目录>/mingw1310_64/bin/g++.exe"

cmake --build build
```

编译成功后：

- 主程序位于 `build/QuickAccount.exe`  
- 另含仅用于环境诊断的小工具：`build/probe/QuickAccountProbe.exe`（输出目录与主程序分离，避免部署时 DLL 互相覆盖）  

构建过程中会对 Windows 目标执行 **`windeployqt`**，将运行所需 Qt 文件复制到输出目录旁。若将 `QuickAccount.exe` 拷贝到其他文件夹单独分发，需在目标位置重新对主程序执行 `windeployqt`（并指定本仓库的 `qml` 目录），否则可能出现缺少 DLL 或无法启动的情况。

### 运行

在包含 `QuickAccount.exe` 与已部署依赖的目录中启动；或在构建目录下直接运行：

```powershell
.\build\QuickAccount.exe
```

---

## 技术概览（供审阅与二次开发）

- **界面**：Qt Quick（QML）+ Qt Quick Controls，当前使用 **Fusion** 视觉风格  
- **逻辑**：C++17；界面通过上下文属性 `TxService` 调用业务层，数据经 DAO 写入 **SQLite**  
- **结构**：`qml/` 为界面；`core/` 为模型、数据访问与服务  

更细的类设计与数据表结构可参考源码与注释。

---

## 故障排除（节选）

| 现象 | 可尝试 |
|------|--------|
| 提示缺少 Qt 相关 DLL | 在 exe 所在目录执行 `windeployqt`，主程序需加 `--qmldir` 指向源码中的 `qml` 文件夹 |
| 图形界面异常或闪退 | 在受限制显卡/远程桌面环境下，可查阅 Qt 文档设置 `QT_QUICK_BACKEND` 等变量；本仓库在 Windows 启动早期支持通过环境变量 `QUICKACCOUNT_QUICK_BACKEND`、`QUICKACCOUNT_SAFE_GRAPHICS`、`QUICKACCOUNT_USE_HWGL` 进行调节（详见源码 `early_env.cpp`） |
| 无法连接 GitHub | 检查网络、代理、防火墙；HTTPS 克隆需保证能访问 `github.com:443` |

---

## 参与与反馈

- **问题与建议**：请使用 GitHub **Issues** 描述复现步骤、系统版本与 Qt 版本。  
- **代码贡献**：欢迎通过 **Pull Request** 提交；请保持改动与议题相关，并尽量附带可理解的提交说明。  

---

## 许可证

仓库内若未包含 `LICENSE` 文件，则默认权利义务以 GitHub 展示及当地法律为准；计划对外分发时，建议维护者补充明确的开源许可证文本。
