---
description: SwiftUI / Observation 代码规范。全分支始终生效。
alwaysApply: true
---

# 代码规范

默认中文回复；路径、API、类型名、UI 字符串留英文。

## 架构

```text
View → Observer → API → Provider → Model
```

- View 不直接拼网络层；Observer 不持有无关 Feature 的 View
- 跨模块状态集中放 Shared / 单例，禁止在 View.init 新建长生命周期对象
- 定位、鉴权等全局能力统一走 Coordinator / Shared

## 命名与状态

- 一文件一主类型，**文件名 = 主类型名**
- 拆文件用语义后缀：+Observer / +Fetch / +Projection / +Chrome / +Sheets…
- 复杂页：@Observable Observer；View 里 @State var observe = …（仅拥有方），body 内 @Bindable；**禁止**@StateObject / @ObservedObject
- raw wire / Task / 回调标 @ObservationIgnored，视图只读投影属性

## 文件头 / 注释

文件头留 Xcode 模板，Created by 下一行中文职责一句；已有文件不改作者。新建日期用当天。

Swift

```
//
//  ExampleView.swift
//  ModuleName
//
//  Created by Author on 2026/1/12.
//  页面职责一句话
//
```

- // MARK: - 中文；主文件只留 body / 状态 / init
- 单文件过长再拆，不必硬卡行数
- /// 中文；**UI / API 字段英文**；日志正文中文；TODO 写清原因与恢复条件

## SwiftUI

- 统一 Toast 成功 / 失败提示
- 远端图用封装组件；生产不用 AsyncImage
- 每个新建的 struct ...: View 必须有可运行的 #Preview；多状态补代表性 Preview，且不请求真实 API
- body 不写加载/错误/刷新（放 Observer）
- .refreshable 挂 ScrollView；空态也要能滚
- 进页打埋点 + 导航日志

## SwiftUI · Observation

- 复杂页：@Observable Observer；View 里 @State var observe = …（仅拥有方），body 内 @Bindable；**禁止**@StateObject / @ObservedObject
- 非拥有方：普通 let / @Bindable / @Environment(Type.self)，**禁止**再套 @State
- 嵌套 class 每一层必须 @Observable；struct 不需要
- 数组元素是 class：item 自身 @Observable，子视图直接收 item 实例；**禁止**下标读父数组
- 动画优先声明式：.animation(value: vm.showsChrome)，value / onChange(of:) 必须传具体属性
  - @Observable 属性尽量少用 withAnimation { vm.xxx = … }（细粒度失效与事务时序可能错位，偶现硬切无动画）
  - 多属性不同曲线：拆视图层级或拆多次 withAnimation，规避 transaction 冲突
- 异步改模型必须 @MainActor（Observer 建议整体标 @MainActor）
- raw wire / Task / 回调标 @ObservationIgnored，视图只读投影属性
- 刷新异常优先 Self._printChanges() 看 keyPath

## 协作

先按用户当前消息分型，模式互斥，不把分析拖进实现：

| 用户口令             | 行为                                                 |
| -------------------- | ---------------------------------------------------- |
| 分析 / 先不改代码    | 只调查并给结论；零 diff                              |
| 实现 / 开始吧 / 继续 | 直接修改并编译，不重复方案讨论                       |
| 修 / 截图指出差异    | 只修列出的差异，未点名的已确认 UI 不动               |
| 查看我的修改         | 先读当前 diff 和文件；以用户代码为新基准，上一版作废 |
| 卡顿 / 性能问题      | 先查刷新与渲染证据，再决定局部修或重构               |
| 提交 / 分层提交      | 仅提交；按模块拆分，不夹带新实现                     |

- 修正前先列「对 / 缺 / 错」；效果紊乱 / 全部干掉 才允许整页重写
- 复杂 Bug 先用日志或运行证据定位；不得连续猜测式改代码
- 性能排查顺序：TimelineView / 每帧重建 → Observation 依赖范围 → ForEach 身份与动画继承 → 图片解码 / 数据量 / 算法
- 动画模型或数据流本身错误时给重构方案，不用 spacing、sleep、缓存继续打补丁
- 最小 diff；效果 ok 表示当前屏冻结，未经要求不再调整
- 未明确要求时不 commit / push、不新建散文档、不顺手重构邻模块

## Git

仅用户要求时才 commit。message 只写 why；禁止附加 Co-authored-by 类 trailer。用 HEREDOC 传 -m。