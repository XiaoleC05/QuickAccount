# 快账（QuickAccount）

[![Build](https://github.com/XiaoleC05/QuickAccount/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/XiaoleC05/QuickAccount/actions/workflows/build.yml)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android%20%28APK%20源码构建%29-lightgrey.svg)](#从源码构建)
[![Qt](https://img.shields.io/badge/Qt-6-41cd52.svg)](https://www.qt.io/)
[![CMake](https://img.shields.io/badge/CMake-%E2%89%A53.16-064f8d.svg)](https://cmake.org/)
[![C++](https://img.shields.io/badge/C%2B%2B-17-00599c.svg)](https://en.cppreference.com/w/cpp/17)
[![License](https://img.shields.io/badge/license-TBD-lightgrey.svg)](LICENSE)

> 若当前仓库来自 fork 或已改名，请将上方 **Build** 徽章链接中的 `XiaoleC05/QuickAccount` 替换为实际的 `所有者/仓库名`。

一款面向个人使用的**本地记账**桌面应用：数据保存在本机 SQLite 数据库中，无需联网即可记账、查账与简单统计。当前版本以**开源源码**形式提供，适合希望自行编译安装或参与改进的读者。

---

## 能做什么

| 能力 | 说明 |
|------|------|
| **记账** | 记录收入或支出，填写金额、日期、分类、支付方式与备注 |
| **查账** | 在「记录」中按关键词、分类、支付方式、日期区间、金额区间组合筛选 |
| **概览** | 在「首页」查看总收入、总支出与结余 |
| **数据位置** | 在「设置」中查看数据库文件路径，便于备份或迁移 |

所有账目数据均存储在**本机**（桌面为当前用户数据目录；Android 为应用私有目录），不会由本应用主动上传到云端（除非使用者自行拷贝数据库文件）。

---

## 功能使用手册（逐步操作）

以下步骤面向第一次接触本应用的使用者。只要应用能正常打开，即可按本节直接完成录入、查询与备份。

### 1. 首次启动与界面认识

1. 启动应用后，窗口上方为标题栏，下方为底部导航。  
2. 底部依次是 **首页 / 记账 / 记录 / 设置** 四个标签页。  
3. 建议首次先进入 **设置**，确认数据库路径，便于后续备份。  
4. 返回 **记账** 页录入第一笔数据，再到 **首页** 与 **记录** 页核对结果。

### 2. 首页：查看总览与最近记录

1. 点击底部 **首页**。  
2. 在「财务概览」区域查看三项核心数据：  
   - **总收入**：所有收入记录金额之和  
   - **总支出**：所有支出记录金额之和  
   - **结余**：总收入减去总支出  
3. 在「收支占比」条中查看当前支出占比。  
4. 在「最近记录」中查看最新几条账目，快速确认刚录入的数据是否生效。  

### 3. 记账：新增一条支出或收入

1. 点击底部 **记账**。  
2. 在顶部选择类型：  
   - 点 **支出**：记录消费  
   - 点 **收入**：记录进账  
3. 在「金额」输入大于 0 的数字（示例：`32.50`）。  
4. 在「日期」输入 `yyyy-MM-dd` 格式（示例：`2026-04-15`）。  
5. 在「分类」下拉中选择用途（餐饮/交通/购物等）。  
6. 在「支付方式」下拉中选择渠道（现金/银行卡/支付宝/微信等）。  
7. 在「备注」填写可选说明（商家名、用途、场景）。  
8. 点击 **保存**。  
9. 看到「已保存」提示后，表示写入成功。  
10. 返回 **首页** 或 **记录** 页检查新增数据。  

常见提示：
- 若金额无效（非数字或小于等于 0），会提示修正后再保存。  
- 若日期格式不正确或日期不存在，会提示按 `yyyy-MM-dd` 重新输入。  

### 4. 记录：搜索、筛选、排序

1. 点击底部 **记录**。  
2. 关键字搜索：在顶部搜索框输入备注关键字，点 **搜索**。  
3. 类型筛选：在「类型」选择 **全部/支出/收入**。  
4. 分类筛选：在「分类」选择目标分类。  
5. 支付方式筛选：在「支付方式」选择目标方式。  
6. 日期区间筛选：  
   - 开始日期：输入起始日  
   - 结束日期：输入结束日  
7. 金额区间筛选：  
   - 最小金额：限定下界  
   - 最大金额：限定上界  
8. 快捷筛选：  
   - 点 **今天**：只看今日  
   - 点 **近7天**：看最近 7 天  
   - 点 **本月**：看本月数据  
9. 排序：在右侧排序框选择  
   - 日期：新到旧 / 旧到新  
   - 金额：大到小 / 小到大  
10. 结果区会显示匹配记录，右上角会显示「共 N 条」。  
11. 若显示「暂无匹配记录」，可放宽条件后重试。  
12. 需要清空当前条件时，点击 **重置条件**。  

### 5. 记录：删除单条数据

1. 在 **记录** 页找到目标条目。  
2. 点击该条右侧 **删除**。  
3. 在确认弹窗中点 **确定（OK）**。  
4. 删除成功后列表会自动刷新，首页汇总也会同步更新。  

### 6. 设置：查看数据库路径与备份

1. 点击底部 **设置**。  
2. 在「数据库文件路径」查看当前 SQLite 文件位置。  
3. 点击 **刷新路径** 可重新读取当前路径。  
4. 备份方式：关闭应用后，拷贝该路径下的 `quickaccount.db` 到安全目录。  
5. 迁移方式：在新设备同位置放入备份数据库（或替换原文件）后重启应用。  

### 7. 推荐使用流程（每日 30 秒）

1. 打开应用进入 **记账**。  
2. 录入当天支出/收入并保存。  
3. 切到 **首页** 看结余变化。  
4. 周末在 **记录** 用「近7天」复盘消费结构。  

---

## 运行前需要知道的事

- 本仓库**默认不附带**已签名的安装包；通常需要从**源码编译**后运行（见下文「从源码构建」）。  
- 若后续提供 **Releases** 中的预编译版本，安装与运行方式以发布页说明为准。  
- **桌面**：以 **Windows + MinGW** 为主要验证环境；Linux 可自行用发行版 Qt6 套件构建。  
- **Android**：仓库内已含最小 **`android/`** 包模板与 CMake 开关，可自行编 **APK 自用**（见下文）；未在 CI 中验证，需本机安装 **Qt for Android、SDK、NDK、JDK**。

---

## 从源码构建（面向贡献者与高级用户）

### 依赖

- **CMake** 3.16 及以上  
- **Qt 6.2** 及以上，并安装模块：**Qt Quick**、**Qt Quick Controls 2**、**Qt SQL**（及构建所需的 **Qt Core**）  
- 推荐 **Ninja** 与 **MinGW 64-bit**（与 Qt 在线安装程序中选项一致）；也可改用 **MSVC** 等工具链，需自行调整 `CMAKE_PREFIX_PATH` 与部署步骤  

### 克隆与编译（Windows / MinGW 示例）

请将示例中的 Qt 路径替换为**本机实际安装路径**（指向包含 `lib/cmake/Qt6` 的套件根目录，例如 `…/6.x.x/mingw_64`）：

```powershell
git clone git@github.com:OWNER/QuickAccount.git
cd QuickAccount
```

将 `OWNER` 替换为 GitHub 用户名或组织名（使用官方仓库时填作者账号；使用 fork 时填自己的账号）。  
若尚未配置 SSH 公钥，请参阅 GitHub 文档：[Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)。仍可使用 HTTPS：`git clone https://github.com/OWNER/QuickAccount.git`。

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

### Android 自用 APK（已安装 Qt for Android 时）

用于**自己安装使用**，不涉及应用商店上架。下面按 **Qt Creator** 为主（也可改用文末 **CMake Presets** 命令行）。

#### 1. 确认 Android 环境全是「绿勾」

1. 打开 **Qt Creator**。  
2. 菜单 **编辑 → Preferences**（Windows；macOS 为 **Qt Creator → Settings**）。  
3. 左侧进入 **设备 → Android**（或 **Environment → Devices → Android**，视版本略有不同）。  
4. 检查 **JDK 位置**、**Android SDK 位置**、**Android NDK** 均已填写且版本满足当前 Qt 版本说明；列表中应无红色错误。  
5. 若提示缺少组件，用 **SDK 管理器** 安装 **Platform Tools**、**至少一个 Platform**（建议 API 34）、以及 Qt 文档要求的 **NDK** 版本。

#### 2. 确认有可用的 Android 套件（Kit）

1. 菜单 **编辑 → Preferences → Kits**。  
2. 在 **Kits** 列表里应能看到类似 **「Desktop Qt …」** 之外的 **「Android Qt 6.x … Clang arm64-v8a」**（名称随安装变化）。  
3. 若没有：回到 **Qt Maintenance Tool**，在已安装的 Qt 版本下勾选 **Android** 架构（如 **Android ARM64 v8a**）并完成安装，再重启 Qt Creator。

#### 3. 打开本项目并切换到 Android 套件

1. **文件 → 打开文件或项目**，选择本仓库根目录的 **`CMakeLists.txt`**。  
2. 窗口**左下角**（或左侧栏）当前 **Kit/构建套件** 处，点一下，在列表里选中 **Android** 对应的 Kit（不要选 Desktop MinGW/MSVC）。  
3. 若弹出 **Configure Project**，选 Android Kit 后点 **Configure Project**。

#### 4. 配置并构建

1. 左侧点 **「项目」**（扳手图标），确认 **构建配置** 为 **Debug** 或 **Release** 均可。  
2. 菜单 **构建 → 清除**（可选，首次可跳过）。  
3. 点左下角 **锤子**「构建」或菜单 **构建 → 构建项目 "QuickAccount"**。  
4. 等待底部 **「编译输出」** 中出现 **成功** / **Build finished**。

#### 5. 生成 APK 并找到文件

1. 菜单 **构建 → 构建 Android APK**（部分版本在 **构建** 子菜单或 **Android** 相关菜单下；若没有，见下条「从构建目录找」）。  
2. **从构建目录找**：菜单 **构建 → 打开构建目录**（或 **项目 → 构建设置 → 打开构建目录**），在资源管理器中在该目录及子目录下搜索 **`*.apk`**。常见位置形如：  
   - `…/build-QuickAccount-Android_…/android-build-QuickAccount/build/outputs/apk/…/`  
   具体层级因 **Qt Creator / Qt 版本** 会略有差异，以本机搜索结果为准。

#### 6. 装到手机（USB 调试）

1. 手机：**设置 → 关于手机** 连点版本号打开 **开发者选项**，开启 **USB 调试**。  
2. 用数据线连接电脑；在电脑终端执行（将路径替换为实际 APK 路径）：  
   `adb install -r "完整路径\app-debug.apk"`  
3. 或在 Qt Creator **运行** 旁选择已识别的 **Android 设备**，使用 **运行**（会先部署再启动）。

**说明：**

- 应用包名默认为 **`com.quickaccount.app`**；与已安装应用冲突时，请改 `android/AndroidManifest.xml` 里的 `package`。  
- **调试包**使用默认调试签名，仅适合自用；**正式发布**需自行配置 keystore（Qt Creator / Gradle 文档）。  
- 界面在 Android 上按 **屏幕宽高** 铺满（`qml/Main.qml`）；布局仍偏桌面，后续可再优化触控与密度。

#### 7.（可选）用 CMake Presets 命令行编 APK

仓库根目录提供 **`CMakePresets.json`**（需 **CMake 3.23+** 且支持预设中的环境变量展开）。在 **PowerShell** 中先设置路径再配置、构建（以下为通用示例，请按本机环境修改）：

```powershell
cd <QuickAccount项目根目录>
$env:ANDROID_NDK_ROOT = "<Android NDK 路径>"
$env:QT_ANDROID_PATH   = "<Qt Android 套件路径，如 .../android_arm64_v8a>"
$env:QT_HOST_PATH      = "<Qt Host 套件路径，如 .../mingw_64>"

cmake --preset android-arm64-release
cmake --build --preset android-arm64-release
```

完成后在 **`build-android-release`** 目录下搜索 **`*.apk`** 即可。

---

## 技术概览（供审阅与二次开发）

- **界面**：Qt Quick（QML）+ Qt Quick Controls，当前使用 **Fusion** 视觉风格  
- **逻辑**：C++17；界面通过上下文属性 `TxService` 调用业务层，数据经 DAO 写入 **SQLite**  
- **结构**：`qml/` 为界面；`core/` 为模型、数据访问与服务；`android/` 为 Android 包覆盖资源（与 Qt 默认模板合并）  

更细的类设计与数据表结构可参考源码与注释。

---

## 开发者视角：功能流程

本节面向维护者与二次开发者，描述每个核心功能从界面触发到数据落库的完整链路。

### 1. 启动流程（Application Lifecycle - Bootstrap）

1. 进程入口执行 `main.cpp`。  
2. 调用 `quickaccount_apply_early_env()`（`early_env.cpp`）：根据环境变量预设图形后端（Windows 场景兼容）。  
3. 创建 `QGuiApplication`，设置应用名、组织名、图标、Fusion 风格。  
4. 创建 `TransactionService` 实例并注入 QML 上下文：`TxService`。  
5. `QQmlApplicationEngine::loadFromModule("QuickAccount", "Main")` 加载主界面。  
6. 进入事件循环 `app.exec()`。  

### 2. 数据库初始化流程

1. 首次执行任何业务方法（如 `addTransaction/searchTransactions/getSummary`）时，`TransactionService::ensureDao()` 触发初始化。  
2. `DatabaseManager::openDatabase()` 打开 SQLite：  
   - 路径：`QStandardPaths::AppDataLocation/quickaccount.db`  
   - 连接名：`quickaccount_connection`  
3. `DatabaseManager::initTables()` 自动建表与索引：  
   - 表：`transactions`  
   - 索引：`date`、`category`  
4. 创建 `TransactionDAO` 并缓存到 `m_dao`，后续复用。  

### 3. 新增记账流程（记账页 -> Service -> DAO）

1. 用户在 `qml/BookPage.qml` 填写类型、金额、日期、分类、支付方式、备注。  
2. 点击保存后调用：  
   - `TxService.addTransaction(type, amount, category, date, description, paymentMethod)`  
3. `TransactionService::addTransaction()` 进行业务校验：  
   - 类型必须为 `income/expense`  
   - 金额必须 `> 0` 且在上限内  
   - 分类与支付方式必须在白名单中  
   - 日期必须是合法 `yyyy-MM-dd`  
4. 校验通过后组装 `Transaction` 模型并调用 `TransactionDAO::addTransaction()`。  
5. DAO 使用参数绑定执行 INSERT。  
6. 成功后 `TransactionService` 发出 `dataChanged()` 信号，首页/记录页收到后自动刷新。  

### 4. 记录查询流程（记录页筛选 -> DAO 动态条件）

1. `qml/RecordsPage.qml` 收集筛选参数：关键词、类型、分类、支付方式、起止日期、金额区间。  
2. 调用 `TxService.searchTransactions(...)`。  
3. `TransactionService::searchTransactions()` 做参数规范化：  
   - 无效金额边界改为哨兵值（不限制）  
   - 纠正 `min > max` 的情况  
   - 非白名单分类/支付方式置空  
   - 非法日期置空  
4. 调用 `TransactionDAO::searchTransactions()`：  
   - 按输入动态拼接 WHERE 条件  
   - 仍使用参数绑定，避免拼接注入风险  
   - 默认 `ORDER BY date DESC, id DESC`  
5. 返回 `QVariantList` 到 QML，页面再执行本地排序/显示。  

### 5. 删除记录流程

1. 记录页点击“删除”，弹确认框。  
2. 确认后调用 `TxService.deleteTransaction(id)`。  
3. Service 校验 `id > 0` 后调用 `TransactionDAO::deleteTransaction(id)`。  
4. DAO 执行 DELETE，成功则发 `dataChanged()`，页面自动刷新。  

### 6. 首页统计流程

1. 首页加载或收到 `dataChanged()` 时执行 `reload()`。  
2. 调用 `TxService.getSummary()`，内部转发到 `TransactionDAO::summary()`。  
3. DAO 分别聚合：  
   - `type = income` 总和  
   - `type = expense` 总和  
4. Service 返回 `{totalIncome,totalExpense,balance}`，QML 更新卡片、占比与最近记录显示。  

---

## 开发者视角：整个软件生命周期

下述生命周期覆盖从需求迭代到发布维护的完整工程流程。

### A. 需求与设计阶段

1. 明确业务目标（例如新增筛选、优化录入效率、增加统计维度）。  
2. 定义变更边界：QML 交互层 / Service 校验层 / DAO 查询层。  
3. 评估是否涉及数据结构变更（表字段、索引、兼容策略）。  

### B. 实现阶段

1. **UI 变更优先在 QML**：保持界面组件化、状态驱动。  
2. **业务规则集中在 Service**：避免规则散落在多个页面。  
3. **数据访问集中在 DAO**：SQL 统一维护，使用参数绑定。  
4. 如新增功能涉及多个层次，按 “Model -> DAO -> Service -> QML” 顺序逐层打通。  

### C. 验证阶段

1. 本地构建（Qt Creator 或 CMake 命令行）。  
2. 冒烟测试最小闭环：  
   - 新增记录  
   - 条件查询  
   - 删除记录  
   - 首页统计同步  
3. 回归验证：  
   - 无记录/极端金额/非法日期输入  
   - 重启后数据持久化是否正确  

### D. 发布阶段

1. 桌面端：构建 `QuickAccount.exe` 并执行部署（`windeployqt`）。  
2. Android：按 Android Kit 构建 APK（或 CMake Presets）。  
3. 发布前确认：版本说明、兼容性说明、数据库备份提醒。  

### E. 运行与维护阶段

1. 收集用户反馈（Issue/日志/复现步骤）。  
2. 根据高频问题优化交互与校验逻辑。  
3. 进行小步迭代：优先修复稳定性与数据正确性，再做视觉优化。  
4. 当数据结构变化时，维护兼容迁移策略（初始化脚本、ALTER、回滚预案）。  

### F. 退役/迁移阶段（长期）

1. 若迁移技术栈（如云同步、服务端化），优先保持 SQLite 数据可导出。  
2. 提供旧数据迁移工具或导入脚本，避免用户历史账目丢失。  
3. 在 README 和 Release Notes 中保留迁移路径说明。  

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
