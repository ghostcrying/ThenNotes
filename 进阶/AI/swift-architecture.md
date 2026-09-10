---
description: ThenObfuscation 全局 Swift 代码 / 文件 / 项目架构规范
alwaysApply: true
---

# Swift 架构与代码规范

ThenObfuscation 仓库内所有 iOS 子项目统一遵守。已有代码风格不一致时，**新文件与新模块**按本规范执行，不顺手大规模重命名旧代码。

## 1. 目录结构

每个 App 独立 `.xcodeproj`，源码根固定七目录（真实磁盘目录，不用 Xcode 虚拟 Group）：

```
<App>/
├── App/          # *App.swift、*Container、*Router、AppSecrets、AppIntents/、启动装配
├── Core/         # 业务大脑，与 UI 无关
│   ├── Entities/     # @Model / @Observable 实体、跨功能 DTO
│   ├── UseCases/     # 按需，无则不建
│   ├── Services/     # *Store / *Service / *Client + 业务加工
│   └── BusinessEnums/
├── Vendor/       # 第三方/系统面板二次封装，禁止业务逻辑
├── Common/       # 无业务含义
│   ├── Utils/        # 工具、<AppName>Log、Formatting
│   └── Components/   # Toast、Theme、通用 UI
├── Extensions/   # 系统类型扩展（按需）
├── Features/     # 按功能拆分，内部平铺
└── Resources/    # Assets、*.xcstrings、LaunchScreen 等
```

工程级配置（`*.entitlements`、`PrivacyInfo.xcprivacy`）留源码根。

### 依赖方向（禁止反向）

```
Features / App → Core、Common、Vendor、Extensions
Core → 仅系统 SDK + Common/Utils；❌ Features / Common/Components / Vendor
Common ❌ 禁止依赖 Core
Vendor ❌ 禁止依赖业务层
```

- Feature 之间禁止互相依赖（跨功能共享页面归领域主功能，其他功能仅单向引用）
- View 不发起网络/持久化；Service/Store 不持有 View 或 SwiftUI 状态
- 页面 Presenter/ViewModel 永远在 `Features/<Feature>/`，❌ 不进 Core
- `@Model`/`@Observable` 业务实体 → `Core/Entities/`；Model 不得依赖 SwiftUI/UIKit，不做 I/O/网络

### 边界四问

| 问题 | 判定 |
|------|------|
| Common vs Core | 拿掉 App 还能复用 → Common；与业务强绑定 → Core |
| Vendor vs Core | 只包装 SDK/系统面板 → Vendor；经业务加工 → Core |
| Extension vs Utils | 系统类型语法增强 → Extensions；成套工具 → Common/Utils |
| 页面模型 | 单 Feature 私有 → 随功能放；多 Feature 共享 → Core/Entities |

硬性：❌ 业务方法写进系统 Extension；❌ 为对称建空目录（首个文件出现时再建）；小项目允许 Core 子层合并。

## 2. 命名与文件

一文件 = 一主类型，文件名与主类型名一致。

| 类型 | 后缀 | 示例 |
|------|------|------|
| 页面 | `*View.swift` | `HomeView.swift` |
| 状态编排 | `*Presenter.swift` / `*ViewModel.swift` | `HomeView+Presenter.swift` |
| 网络/能力 | `*Service.swift` / `*Client.swift` | `APIClient.swift` |
| 持久化 | `*Store.swift` | `LibraryStore.swift` |
| 聚合 | `*Repository.swift` | `FeedRepository.swift` |
| 解析 | `*Parser.swift` | `HTMLParser.swift` |
| 路由/主题 | `*Router.swift` / `*Theme.swift` | `AppRouter.swift` |
| 复用组件 | `*Cell/Card/Bar.swift` | `StickerCell.swift` |

视图拆分统一用 `<主View名>+<子模块>.swift`：

```
HomeView.swift
HomeView+Presenter.swift
HomeView+Sections.swift
HomeView+Toolbar.swift
```

- 状态类嵌套在主视图命名空间：`extension HomeView { @Observable final class Presenter {…} }`
- 禁止「杂项组件袋」；独立子屏幕在 Feature 内开子目录
- 仅多 Feature 复用的组件才放 `Common/Components/`，用独立类型名
- 同规则适用于其他主类型（`APIClient+Feed.swift` 等）

类型名/文件名/UI文案/API字段：**英文**；注释/`// MARK:`/日志正文：**中文**。

## 3. 状态管理与 Observation

以 Deployment Target 选型，同一 App 不混用。

### Ownership

| 语义 | iOS 17+ | iOS 15/16 |
|------|---------|-----------|
| Owner | `@Observable` + `@State` | `ObservableObject` + `@StateObject` |
| 只读 | `let` / 普通属性 | `@ObservedObject` |
| Binding | `@Bindable` | `@ObservedObject` / Binding |
| 跨层级 | `@Environment(Type.self)` | `@EnvironmentObject` |

- `@State` = ownership，仅真正拥有方使用
- `@Bindable` 仅在需要 Binding 的最小作用域
- 非拥有方禁止再套 `@State`/`@StateObject`，禁止复制模型“解决刷新”
- 禁止在 `View.init` 创建长生命周期业务状态
- `@Environment` 不替代明确的局部 input

### Observable 规则

```swift
@MainActor
@Observable
final class HomePresenter {
  var items: [FeedItem] = []
  var isLoading = false
}
```

- 状态类统一 `@MainActor`；新代码优先 `*Presenter`
- 嵌套 `class` 每层必须 `@Observable`；`struct` 不需要
- 只保存 UI/domain state；Task/callback/network/raw wire 标 `@ObservationIgnored`
- 禁止人工 `objectWillChange`；刷新异常优先 `Self._printChanges()`

### Collection / Item

数组元素为 `class` 时自身必须 `@Observable`，子 View **直接接收 item**：

```swift
struct ItemView: View {
  let item: FeedItem
  var body: some View { Text(item.title) }
}
```

禁止 `presenter.items[index].title`。

### Identity

- `ForEach` 优先稳定业务语义 `Identifiable.ID`
- 禁止 index 作长期 identity、无理由 `id: \.self`、`.id(UUID())` / 随机 ID 强制刷新
- `.id(...)` 仅在明确需要重建生命周期时使用
- Identity 表示“是谁”，不是“排第几个”

### State / Body / Lifecycle

- 业务/页面状态 → `@Observable` Presenter
- 局部短生命周期 → `@State`
- 廉价派生 → computed；昂贵计算 → 预计算/缓存
- `body` 必须纯粹：禁止 I/O、网络、解码、明显昂贵 `filter/sort/map`
- 异步优先 `.task` / `.task(id:)`；禁止默认 `.onAppear { Task {…} }`
- 每个非结构化 `Task` 必须有明确 owner；必须正确处理 cancellation
- UI 状态提交在 `@MainActor`；不为规避并发滥用 `Task.detached`/`nonisolated`/`MainActor.run`

## 4. 文件头与组织

每个新建 Swift 文件必须带：

```swift
//
//  FileName.swift
//  <AppName>
//
//  Created by <AppName> on YYYY-MM-DD.
//
```

- 职责用类型上方中文注释或 `// MARK:`，不替代 Created 行
- 修改已有文件不改作者、不强制补 Created
- `#Preview` 放文件末尾；新建 `*View` 及独立组件必须有可运行 Preview（不请求真实 API）
- 单文件建议 ≤300 行，超出按 §2 拆分

## 5. 编码约定

- 新 UI 用 SwiftUI；UIKit 仅必要桥接，封装放 `Vendor/`
- **Sheet 单字段驱动**：必须用单一 `Identifiable?` + `.sheet(item:)`，禁止 `isPresented` + 另存数据双字段；系统面板 API 可用原生 Bool
- 并发：`async/await`；UI 更新 `@MainActor`
- 错误：面向用户用 `LocalizedError`；短提示用全局 Toast；破坏性操作用 `confirmationDialog`；长文案才用 Alert
- `.refreshable` 挂 `ScrollView`/`List`；生产不用 `AsyncImage`
- 颜色/图标进 Assets；主题色走 `*Theme`，禁止魔法数
- `Info.plist` 仅声明实际用到的键；禁止 `NSAllowsArbitraryLoads`
- 新建文件必须加入 `.xcodeproj`
- UI 字符串英文；Settings 必须含版本、数据统计、清空数据（带确认）、隐私说明

### 5.1 动画

- 默认 `.animation(_:value:)`，`value` 必须是实际驱动属性
- 用户明确触发可用局部 `withAnimation`
- `if` 控制的 View 需要动画时，insertion 与 removal 必须同时验证，用 `transition`（需要不同规则时用 `.asymmetric`）
- `.animation` 放在能覆盖 insertion/removal 的正确 subtree
- 禁止 `.id(UUID())`、延迟、重复 `withAnimation`、额外 opacity 修动画
- `transaction` 仅当 state/identity/transition/animation scope 均正确，但某 subtree 被祖先错误联动时使用；必须缩小作用域并注释原因；禁止根节点无差别关闭动画

推荐：

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

## 6. 日志（必须）

每个 App 必须有 `Common/Utils/<AppName>Log.swift`：

- `#if DEBUG` + `print`，Release 全部 no-op；禁止 `os.Logger`/`NSLog`
- 格式：`[AppName][LEVEL][Category] File:Line 中文消息`
- LEVEL：DEBUG / INFO / WARN / ERROR；按领域嵌套 Category（network/cache/store/ui）

必须打日志：网络请求/响应/失败、持久化读写/迁移/清空、Repository 聚合/缓存、权限拒绝、用户操作业务失败、非预期分支（nil/空数据/解码失败）。`catch` 不得空实现。

日志正文中文；不记录密钥/Token/隐私原文。用户可见错误仍用 Toast/Alert。

### 6.1 全局 Toast（必须）

位置：`Common/Components/ToastCenter.swift`（一 App 一份）

- iOS 17+：`@Observable` + `@Environment`
- 挂载：`*App` 创建 → RootView `.environment` + `.toastOverlay`
- 用途：短句提示；禁止把密码/Token/账本原文打进 Toast 或日志

```swift
@MainActor @Observable
final class ToastCenter {
  private(set) var message: String?
  func show(_ message: String, duration: TimeInterval = 2.0) { … }
}
```

### 6.2 Agent Review（修改 SwiftUI 后自动检查）

- ownership / `@State` / `@Bindable` 正确
- Observable dependency 足够细，无 parent[index]
- `ForEach` identity 稳定，无 index / 随机 `.id()`
- body 无副作用 / heavy computation
- `.task` / `.task(id:)` 生命周期正确，Task 可取消
- UI mutation 在 `@MainActor`
- `if` insertion/removal 均验证动画
- transaction 仅用于已定位的 animation propagation 问题
- 未用 workaround 掩盖 Observation/identity/lifecycle 问题

## 7. 工程边界

- 禁止跨子项目 Shared Swift Package；每个 App 独立工程
- 第三方优先已 vendored；不随意升 major
- 历史归档默认只读，改动前确认
- 删除前全局搜索无引用；清理未使用 Assets 与旧 Bundle 名

## 8. 验收

```bash
xcodebuild -project <path>/<App>.xcodeproj -scheme <App> \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.5' build
```

编译通过 → 模拟器冷启动 → 主流程 + Settings → 空态/错误态/权限弹窗
