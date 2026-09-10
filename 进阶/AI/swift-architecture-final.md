---
description: ThenObfuscation 全局 Swift 代码 / 文件 / 项目架构规范
alwaysApply: true
---

# Swift 架构与代码规范

ThenObfuscation 仓库内 **所有 iOS 子项目** 统一遵守。已有代码风格不一致时，**新文件与新模块** 按本规范执行，不顺手大规模重命名旧代码。

## 1. 目录结构（工程化分层标准）

每个 App 独立 `.xcodeproj`，源码根固定 **七目录**：`App / Core / Vendor / Common / Extensions / Features / Resources`。`Core / Vendor / Common / Extensions` 是移动端通用约定，非苹果官方标准；**不用 Xcode 虚拟 Group，一律真实磁盘目录**。工程级配置（`*.entitlements`、`PrivacyInfo.xcprivacy`）留源码根。

```text
<App>/
├── App/                    # 应用壳：*App.swift、*Container、*Router、AppSecrets、AppIntents/、启动装配
├── Core/                   # 业务大脑，与 UI 无关，只依赖系统 SDK + 基础工具
│   ├── Entities/           # 领域模型：@Model / @Observable 实体、聚合与快照值对象、跨功能 DTO
│   ├── UseCases/           # 业务用例（按需，无则不建）
│   ├── Services/           # 业务服务：数据访问（*Store / *Service / *Client）+ 业务加工（CSV、PDF、报表）
│   └── BusinessEnums/      # 业务枚举、业务常量
├── Vendor/                 # 第三方 SDK / 系统面板二次封装：只做适配桥接，禁止业务逻辑
├── Common/                 # 通用层，无业务含义，全 App 复用
│   ├── Utils/              # 工具函数、<AppName>Log、Formatting（基础工具层）
│   └── Components/         # 通用 UI 组件：Toast、Theme、标签样式、占位、Loading
├── Extensions/             # 系统类型扩展：String+Ext.swift、View+Ext.swift（按需）
├── Features/               # 业务模块，按功能拆分；内部平铺，View / Presenter / 私有模型靠 §2 命名表达
│   └── <Feature>/
└── Resources/              # Assets.xcassets、*.xcstrings、LaunchScreen.storyboard、示例数据
```

### 依赖方向（禁止反向）

```text
Features / App → Core、Common、Vendor、Extensions
Core    → 仅系统 SDK + Common/Utils（基础工具层）；❌ Features / Common/Components / Vendor
Common  ← ❌ 禁止依赖 Core（不能感知业务模型）
Vendor  ← ❌ 禁止依赖业务层（Core / Features）
```

- Feature 之间禁止互相依赖，唯一例外：跨功能共享的页面/业务组件归属其领域主功能（渲染哪个领域的实体就归哪个功能，如 QuoteDetailView → Features/Quotes/），其他功能仅可单向引用、不得反向；View 不发起网络 / 不读写持久化，Service / Store 不持有 View 或 SwiftUI 状态
- 页面 ViewModel / Presenter 永远在 `Features/<Feature>/`，引用 Core 的服务；❌ 不把页面 ViewModel 塞进 Core
- `@Model` / `@Observable` 业务实体 → `Core/Entities/`；Model 不得依赖 SwiftUI / UIKit，不做 I/O / 网络

### Features 内部（平铺 + 命名约定）

- 一个用户任务一个文件夹；页面私有模型（sheet 载荷、DTO、解析结果）随功能平铺放，一文件一类型
- View / 状态编排 / 子模块按 §2 命名聚拢（`HomeView.swift`、`HomeView+Presenter.swift`、`HomeView+List.swift`）；独立子屏幕在 Feature 内开子目录（如 `Composer/`）
- Feature 之间禁止互相依赖；跨功能共享页面/业务组件归领域主功能所有，其他功能单向引用、不得反向

### 边界判断（四问）

| 问题 | 判定 |
|---|---|
| Common 还是 Core？ | 拿掉这个 App 还能复用 → Common；与业务规则强绑定 → Core |
| Vendor 还是 Core？ | 只包装 SDK / 系统面板、隔离外部 API → Vendor；经过业务加工 → Core |
| Extension 还是 Common/Utils？ | 系统类型语法增强（如 `String.isNotEmpty`）→ Extensions；成套工具函数 → Common/Utils |
| 页面模型放哪？ | 单 Feature 私有（sheet 载荷、DTO）随功能放；两个及以上 Feature 共享 → `Core/Entities/` |

### 硬性条款

- ❌ 反模式：把业务方法写进系统 Extension（`String.toUserNickName()` 是业务，放 Core）
- ❌ 不建空目录：`UseCases/`、`Extensions/` 等子层出现首个文件时才创建；禁止为对称建空 Repository / Interactor / UseCase
- 变体：小项目允许 Core 子层合并简化；拆 Swift Package 的多模块化不在本仓库范围

## 2. 命名与文件类型

一个文件 = 一个主类型，**文件名与主类型名一致**。

| 类型 | 后缀 | 示例 |
|------|------|------|
| 页面 | `*View.swift` | `HomeView.swift` |
| 状态编排 | `*Presenter.swift` 或 `*ViewModel(s).swift` | `HomeView+Presenter.swift` |
| 网络 / 能力 | `*Service.swift`、`*Client.swift` | `APIClient.swift` |
| 持久化 | `*Store.swift` | `LibraryStore.swift` |
| 数据聚合 | `*Repository.swift` | `FeedRepository.swift` |
| 解析 | `*Parser.swift` | `HTMLParser.swift` |
| 路由 / 主题 | `*Router.swift`、`*Theme.swift` | `AppRouter.swift` |
| 独立复用组件 | `*Cell.swift`、`*Card.swift`、`*Bar.swift` | `StickerCell.swift` |

### 视图拆分统一用「主类型名 + 子模块」

一个视图拆多个文件时，**所有子文件命名为 `<主View名>+<子模块>.swift`**（`extension` 或子视图），按名聚拢：

```text
Features/Home/
├── HomeView.swift            # 主结构 + body
├── HomeView+Presenter.swift  # 该屏状态编排
├── HomeView+Sections.swift   # 分区拼装
├── HomeView+Toolbar.swift    # 工具栏
└── HomeView+Search.swift     # 搜索子视图
```

- 屏幕状态类嵌套在主视图命名空间：`extension HomeView { @Observable final class Presenter { … } }`（iOS 15/16 轨为 `ObservableObject`），写入 `<View>+Presenter.swift`
- 「杂项组件袋」（如 `HomeComponents.swift`）**不再使用**；独立屏幕成组在 Feature 内开子目录（如 `Composer/`），不摊在 Feature 根
- 仅当组件被 **多个 Feature 复用** 时才用独立类型名（如 `StickerCell`）并置于 `Common/Components/`
- 同规则适用于其他主类型：`APIClient+Feed.swift`、`LibraryStore+Migration.swift`

类型名、文件名、UI 文案、API 字段：**英文**；注释、`// MARK:`、日志正文：**中文**。

## 3. 状态管理与 SwiftUI Observation

以工程 **Deployment Target** 选型；同一 App 不无理由混用两套状态体系。

### 3.1 Ownership

| 语义 | iOS 17+ | iOS 15/16 |
|---|---|---|
| Owner / lifetime | `@Observable` + `@State` | `ObservableObject` + `@StateObject` |
| 子 View 只读 | 普通属性 / `let` | `@ObservedObject` |
| 子 View 需要 Binding | `@Bindable` | `@ObservedObject` / Binding |
| 跨层级依赖 | `@Environment(Type.self)` | `@EnvironmentObject` |

- `@State` = ownership；只有真正拥有生命周期的一方使用。
- `@Bindable` = Binding access，不代表 ownership；只在需要 Binding 的最小作用域使用。
- 非拥有方禁止再次套 `@State` / `@StateObject`，禁止复制传入的业务模型来“解决刷新”。
- `@Environment` 用于跨层级共享依赖，不替代明确的局部 View input。
- 禁止在 `View.init` 创建需要长生命周期的业务状态。

### 3.2 Observable

iOS 17+ 新代码：

```swift
@MainActor
@Observable
final class HomePresenter {
  var items: [FeedItem] = []
  var isLoading = false
}
```

- 状态编排类统一 `@MainActor`；新代码优先 `*Presenter`，已有模块沿用 `*ViewModel`。
- 嵌套 `class` 每层必须 `@Observable`；`struct` 不需要。
- `@Observable` 只保存 UI / domain state；Task、callback、network handle、raw wire 等非观察状态标 `@ObservationIgnored`，不要让 Presenter 变成依赖垃圾桶。
- Model 不做 View 渲染、不做直接 UI 操作。
- 禁止通过 `objectWillChange` 等人工通知模拟 Observation 刷新。
- 刷新异常优先 `Self._printChanges()`，根据实际 dependency 修复，不使用强制刷新 workaround。

### 3.3 Collection / Item

数组元素为 `class` 时，item 自身必须 `@Observable`，子 View 直接接收 item：

```swift
struct ItemView: View {
  let item: FeedItem

  var body: some View {
    Text(item.title)
  }
}
```

禁止：

```swift
Text(presenter.items[index].title)
```

子 View 应依赖实际使用的 item / property，不通过父 Presenter + index 建立过宽 dependency。

### 3.4 Identity

- 动态 `ForEach` 优先使用稳定、业务语义明确的 `Identifiable.ID`。
- 禁止用数组 index 作为长期业务 identity。
- 禁止无理由使用 `id: \.self` 表示复杂实体。
- 禁止 `.id(UUID())`、随机 ID、每次 body 变化产生的新 ID 来强制刷新。
- `.id(...)` 只在明确需要切换 identity、并有意重建该 subtree 生命周期时使用。
- Identity 表示“是谁”，不是“当前排第几个”。

### 3.5 State / Derived State / Body

```text
业务 / 页面状态       → @Observable Presenter
局部短生命周期 UI 状态 → @State
廉价纯派生值           → computed property
昂贵派生计算           → 预计算 / 缓存 / 独立计算层
```

- 不要为可直接推导的值增加重复 mutable state。
- `body` 必须保持纯粹；禁止 I/O、网络、解码及明显昂贵计算。
- `body` 内避免大规模 `filter/sort/map/grouping`；复杂计算移出 View。
- `LazyVStack/LazyVGrid` 只解决子 View 的延迟创建，不等于解决 dependency、计算或数据源性能问题。

### 3.6 Lifecycle / Concurrency

- `body` 禁止副作用。
- 异步加载优先 `.task`；与具体输入 / identity 绑定的任务优先 `.task(id:)`。
- 不把 `.onAppear { Task { ... } }` 作为默认异步模式。
- 每个非结构化 `Task {}` 必须有明确生命周期 owner；禁止无意义创建孤儿 Task。
- 异步工作必须正确处理 cancellation，避免旧请求覆盖新状态。
- UI 状态提交在 `@MainActor`；网络、解析、重计算不因方便而全部塞进 MainActor。
- 不为了规避并发错误滥用 `Task.detached`、`nonisolated` 或 `MainActor.run`。

## 4. 文件头与组织


每个新建 Swift 文件 **必须**带 Xcode 模板式统一文件头：

```swift
//
//  FileName.swift
//  <AppName>
//
//  Created by <AppName> on YYYY-MM-DD.
//
```

- 第 2 行：文件名（与磁盘一致）；第 3 行：Target 名；第 5 行：`Created by <AppName> on` + 当天 ISO 日期
- 职责说明用类型上方一行中文注释或 `// MARK: - 中文标题`，**不替代** Created 行
- 修改已有文件不改作者、不强制补 Created 行（大幅重建模块除外）
- `#Preview` 放文件末尾；每个新建 `*View.swift` 及独立组件文件**必须**有可运行 `#Preview`（需 Store 的用项目 Container 注入），多状态补代表性 Preview 且不请求真实 API
- 单文件建议 **≤ 300 行**；超出优先按 §2 拆 `<主类型名>+<子模块>.swift`

Markdown 新建文件可选 HTML 注释头，含文件名、项目名、中文说明、创建日期。

## 5. Swift 编码约定

- 新 UI：**SwiftUI**；UIKit 仅用于相机、Share Sheet 等必要桥接，封装一律放 `Vendor/`
- **Sheet / Cover 单字段驱动**：不得用 `isPresented` Bool + 另存 URL / prompt / model 双字段共同驱动；必须用单一 `Identifiable?` + `.sheet(item:)`。sheet 载荷 `struct` 实现 `Identifiable`，随所属功能平铺放；系统面板 API（`fileImporter`、`photosPicker` 等）可用其原生 Bool 参数；同页多个 sheet 各用独立载荷类型
- 并发：`async/await`；UI 更新在 `@MainActor`
- 错误：面向用户的 `LocalizedError`；**短成功 / 失败用全局 Toast**；破坏性操作用 `confirmationDialog`；需要阅读的长文案才用 Alert。每个 App **必须**有全局 Toast（§6.1）
- 动画遵守 §5.1：默认声明式 `.animation(_:value:)`；`value` / `onChange(of:)` 使用具体属性；不要用 `.id()` / 延迟 / transaction 作为默认修复
- `.refreshable` 挂 `ScrollView` / `List`；空态也要能滚；生产不用 `AsyncImage`，远端图用封装组件
- 资源：颜色 / 图标进 `Assets.xcassets`；主题色走 `*Theme`，禁止散落魔法数
- 权限：`Info.plist` 仅声明实际用到的键；禁止 `NSAllowsArbitraryLoads`
- 新建文件须加入对应 `.xcodeproj` / `project.pbxproj`
- UI 字符串 **英文**；Settings 页须含版本、数据统计、清空数据（带确认）、隐私说明

## 5.1 SwiftUI Animation

- 默认使用 `.animation(_:value:)`；`value` 必须是实际驱动动画的具体属性。
- 用户明确触发的一次局部 mutation 可用 `withAnimation`；不同曲线 / 时序的属性拆开 mutation、View subtree 或 animation scope。
- `if` 控制的 View 要有入场 / 出场动画时，必须同时验证 insertion 和 removal；用 `transition` 描述 View 的出现 / 消失。
- `transition` 解决 identity insertion/removal；`.animation(value:)` 解决已存在 View 的属性变化；不要混为一谈。
- `if` 的 transition 不要只写入场效果。需要不同规则时使用 `.asymmetric(insertion:removal:)`。
- `.animation` 放在能覆盖 insertion/removal 的正确 subtree / container 上；避免 child 被移除后父布局直接硬切。
- 禁止用 `.id(UUID())`、延迟、重复 `withAnimation`、额外 opacity workaround 修复动画。
- `transaction` 不是默认动画 API。仅当已确认 state mutation、identity、transition、animation scope 均正确，但某 subtree 被祖先 transaction 错误联动时使用。
- `transaction` 必须尽量缩小作用域，并注明要阻断 / 覆盖的动画联动；禁止页面根节点无差别关闭动画。
- 动画修改后必须检查：入场、出场、快速连续触发、不同曲线联动、异步状态更新期间是否出现硬切或旧状态覆盖。

```swift
ZStack {
  content

  if presenter.showsChrome {
    ChromeView()
      .transition(.move(edge: .top).combined(with: .opacity))
  }
}
.animation(.easeInOut, value: presenter.showsChrome)
```

## 6. 日志（必须完善）

每个 App **必须**有 `Common/Utils/<AppName>Log.swift`，**不得省略或留空实现**。

- `#if DEBUG` + `print`，Release 全部空实现（no-op）；**禁止** `os.Logger`、`NSLog`、Release 刷屏
- 统一格式：`[AppName][LEVEL][Category] File:Line 中文消息`；`LEVEL`：`DEBUG` / `INFO` / `WARN` / `ERROR`；按领域分 `Category` 嵌套类型（如 `network`、`cache`、`store`、`ui`）

```swift
#if DEBUG
enum MyAppLog {
  enum Level: String { case debug = "DEBUG", info = "INFO", warn = "WARN", error = "ERROR" }
  static func log(_ level: Level, category: String, _ message: String,
                  file: String = #file, line: Int = #line) {
    let name = (file as NSString).lastPathComponent
    print("[MyApp][\(level.rawValue)][\(category)] \(name):\(line) \(message)")
  }
  enum network {
    static func debug(_ msg: String, file: String = #file, line: Int = #line) {
      log(.debug, category: "Network", msg, file: file, line: line) }
    static func error(_ msg: String, file: String = #file, line: Int = #line) {
      log(.error, category: "Network", msg, file: file, line: line) }
  }
}
#else
// 同结构空实现（no-op）
#endif
```

### 必须打日志的场景

| 场景 | 级别 | 要求 |
|------|------|------|
| 网络请求发起 / 响应 / 失败 | DEBUG / ERROR | 含 URL 或端点标识、状态码或错误原因 |
| 持久化读写 / 迁移 / 清空 | DEBUG / ERROR | 含关键路径或条数 |
| Repository 聚合 / 缓存命中与失效 | DEBUG | 含数据源与结果概要 |
| 权限拒绝 / 系统能力不可用 | WARN / ERROR | 含权限类型 |
| 用户操作触发的业务失败（保存、导入、解析） | ERROR | 含可定位的中文原因 |
| 非预期分支（nil、空数据、解码失败） | WARN / ERROR | 不得静默吞掉 |

### 编写要求

- 新增或修改 `Service` / `Store` / `Repository` / 复杂 `Presenter` 时，**同步补充**对应日志
- 日志正文用**中文**；不记录密钥、Token、用户隐私原文
- 用户可见错误仍用 Toast / Alert / 内联 `errorMessage`；日志作开发侧补充，二者不互相替代
- `catch` 块不得空实现；至少 `MyAppLog.*.error(...)` + 向上抛出或转为 Toast / `errorMessage`

## 6.1 全局 Toast（每个 App 必须）

每个 iOS App **必须**提供全局轻提示。参考 PawTale `ToastCenter` overlay（不用额外 `UIWindow`，除非必须盖住系统面板）。

| 项 | 要求 |
|---|---|
| 位置 | `Common/Components/ToastCenter.swift`；**一 App 一份**，禁止跨项目 Package |
| 状态 | iOS 17+：`@Observable` + `@Environment`；iOS 15/16：`ObservableObject` |
| 挂载 | `*App` 创建实例 → `RootView` `.environment` + `.toastOverlay` |
| 用途 | 导入成功、保存失败、口令错误等 **短句**；破坏性确认用 `confirmationDialog`，隐私长文案用独立页 / Alert |
| 禁止 | 把密码、Token、账本原文打进 Toast 或日志 |

```swift
@MainActor @Observable
final class ToastCenter {
  private(set) var message: String?
  func show(_ message: String, duration: TimeInterval = 2.0) { … }
}
// *App：.environment(toastCenter) + .toastOverlay(toastCenter)
```

## 6.2 SwiftUI Agent Review

修改 SwiftUI 后自动检查，不向开发者重复询问：

- [ ] ownership / `@State` / `@Bindable` 正确
- [ ] Observable dependency 足够细，无 parent[index]
- [ ] `ForEach` identity 稳定，无 index / 随机 `.id()`
- [ ] body 无副作用 / heavy computation
- [ ] `.task` / `.task(id:)` 生命周期正确，Task 可取消
- [ ] UI mutation 在 `@MainActor`
- [ ] `if` insertion / removal 均验证动画
- [ ] transaction 仅用于已定位的 animation propagation 问题
- [ ] 未用 workaround 掩盖 Observation / identity / lifecycle 问题

## 7. 工程边界

- **禁止**跨子项目 Shared Swift Package；每个 App 独立工程
- 第三方依赖：优先子项目内已 vendored 的 `ThirdParty/` / `Vendor/`；不随意升 major
- 历史归档目录默认只读，改动前须与用户确认
- 删除代码前全局搜索确认无引用；清理未使用 Assets 与旧 Bundle 名残留

## 8. 验收（每次 Swift 改动）

```bash
xcodebuild -project <path>/<App>.xcodeproj -scheme <App> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.5' build
```

- 编译通过 → 模拟器冷启动 → 主流程 + Settings → 空态 / 错误态 / 权限弹窗
