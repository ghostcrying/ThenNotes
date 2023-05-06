

# 基础



## 渲染原理

Flutter视图树包含了三颗树：Widget、Element、RenderObject
- Widget: 存放渲染内容、它只是一个配置数据结构，创建是非常轻量的，在页面刷新的过程中随时会重建
- Element: 同时持有Widget和RenderObject，存放上下文信息，通过它来遍历视图树，支撑UI结构
- RenderObject: 根据Widget的布局属性进行layout，paint，负责真正的渲染

**从创建到渲染的大体流程是：根据Widget生成Element，然后创建相应的RenderObject并关联到Element.renderObject属性上，最后再通过RenderObject来完成布局排列和绘制**

##### 更新渲染流程

- 由于Widget是不可改变，需要重新创建一颗新树，build开始，然后对上一帧的element树做遍历，调用他的updateChild，看子节点类型跟之前是不是一样，不一样的话就把子节点扔掉，创造一个新的，一样的话就做内容更新，对renderObject做updateRenderObject操作，updateRenderObject内部实现会判断现在的节点跟上一帧是不是有改动，有改动才会别标记dirty，重新layout、paint，再生成新的layer交给GPU

![img](https://pic4.zhimg.com/80/v2-f76f7b02b7e2818a6ec32f1399f8dde3_1440w.jpg)

## App生命周期

- **resumed**：该应用程序是可见的，并对用户的输入作出反应。也就是应用程序进入前台。

- **inactive**：应用程序处于非活动状态，没有接收用户的输入。在 iOS 上，这种状态对应的是应用程序或 Flutter 主机视图在前台非活动状态下运行。当处于电话呼叫、响应 TouchID 请求、进入应用切换器或控制中心时，或者当 UIViewController 托管的 Flutter 应用程序正在过渡。在 Android 上，这相当于应用程序或 Flutter 主机视图在前台非活动状态下运行。当另一个活动被关注时，如分屏应用、电话呼叫、画中画应用、系统对话框或其他窗口，应用会过渡到这种状态。也就是应用进入后台。

- **pause**：该应用程序目前对用户不可见，对用户的输入没有反应，并且在后台运行。当应用程序处于这种状态时，引擎将不会调用。也就是说应用进入非活动状态。

- **detached**：应用程序仍然被托管在flutter引擎上，但与任何主机视图分离。处于此状态的时机：引擎首次加载到附加到一个平台 View 的过程中，或者由于执行 Navigator pop，view 被销毁

##### Example:

```
# 监听示例:
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  print('didChangeAppLifecycleState');
  if (state == AppLifecycleState.resumed) {
    print('resumed：');
  } else if (state == AppLifecycleState.inactive) {
    print('inactive');
  } else if (state == AppLifecycleState.paused) {
    print('paused');
  } else if (state == AppLifecycleState.detached) {
    print('detached');
  }
}
```



### StatefulWidget

- **createState**：
  - 该函数为 StatefulWidget 中创建 State 的方法，当 StatefulWidget 被创建时会立即执行 createState。createState 函数执行完毕后表示当前组件已经在 Widget 树中，此时有一个非常重要的属性 mounted 被置为 true。

- **initState**：
  - 该函数为 State 初始化调用，只会被调用一次，因此，通常会在该回调中做一些一次性的操作，如执行 State 各变量的初始赋值、订阅子树的事件通知、与服务端交互，获取服务端数据后调用 setState 来设置 State。
- **didChangeDependencies**：
  - 该函数是在该组件依赖的 State 发生变化时会被调用。这里说的 State 为全局 State，例如系统语言 Locale 或者应用主题等，Flutter 框架会通知 widget 调用此回调。类似于前端 Redux 存储的 State。该方法调用后，组件的状态变为 dirty，立即调用 build 方法。
  - 初始化触发,  **setState**并不会触发
- **build**：
  - 主要是返回需要渲染的 Widget，由于 build 会被调用多次，因此在该函数中只能做返回 Widget 相关逻辑，避免因为执行多次而导致状态异常。
- **reassemble**：
  - 主要在开发阶段使用，在 debug 模式下，每次热重载都会调用该函数，因此在 debug 阶段可以在此期间增加一些 debug 代码，来检查代码问题。此回调在 release 模式下永远不会被调用。
- **didUpdateWidget**：
  - 该函数主要是在组件重新构建，比如说热重载，父组件发生 build 的情况下，子组件该方法才会被调用，其次该方法调用之后一定会再调用本组件中的 build 方法。
  - 父组件State变化触发, **setState**并不会触发

- **deactivate**：
  - 在组件被移除节点后会被调用，如果该组件被移除节点，然后未被插入到其他节点时，则会继续调用 dispose 永久移除。

- **dispose**：

  - 永久移除组件，并释放组件资源。调用完 dispose 后，mounted 属性被设置为 false，也代表组件生命周期的结束

  - **组件移除逻辑**:

    - **父组件移除，会先移除节点，然后子组件移除节点，子组件被永久移除，最后是父组件被永久移除**
    - 父组件触发deactivate, 子组件deactivate..., 子组件dispose, 父组件dispose

    

#### 状态

- **mounted**：
  - 是 State 中的一个重要属性，相当于一个标识，用来表示当前组件是否在树中。在 createState 后 initState 前，mounted 会被置为 true，表示当前组件已经在树中。调用 dispose 时，mounted 被置为 false，表示当前组件不在树中。

- **dirty**：
  - 表示当前组件为脏状态，下一帧时将会执行 build 函数，调用 setState 方法或者执行 didUpdateWidget 方法后，组件的状态为 dirty。

- **clean**：
  - 与 dirty 相对应，clean 表示组件当前的状态为干净状态，clean 状态下组件不会执行 build 函数。

![stateful_widget_lifecycle 生命周期流程图](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/533b6573ae124afca6104529b799f5e3~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image)



## 响应链

- 触摸事件:
  - PointerEvent及其子类PointerDownEvent、PointerMoveEvent、PointerCancelEvent、PointerUpEvent
- 响应:
  - 是指事件响应阶段RenderPointerListener/Listener通过onPointerDown、onPointerMove、onPointerUp、onPointerCancel四个方法来响应事件
  - 组件Widget: 是指那些仅仅起到包装其它Widget的作用、Flutter Framework并不会为它们创建对应的RenderObject的Widget
    - 继承自StatelessWidget/StatefulWidget: Container、Text、Image、ListView、GridView、PageView、自定义的Widget...
  - 渲染对象Widget: 是指那些Flutter Framework会为它们创建对应的RenderObject的Widget
    - SizedBox、Row、Column ...
- 第一响应者:
  - PointerDown事件发生后，就从根视图RenderView的hitTest方法开始，倒序递归调用子视图的hitTest方法，如果判断到触摸的点在某个视图内部，就把它放进响应者数组里，位于视图层级上方的视图会被优先放进响应者数组，最终响应者数组的第一个元素就会成为第一响应者
- 分发:
  - GestureBinding会遍历响应者数组里所有的响应者，按顺序把触摸事件分发给所有的响应者
- 响应
  - 因为是一次性给所有的响应者都分发了事件，所以只要是实现了四个方法的Listener都会响应事件，没实现的就不响应，不存在往下一个响应者传递这么一说，只不过是第一响应者会第一个响应、第二个响应者会第二个响应等等
- **优先级**
  - **原始指针事件和平移手势会同时触发, 但是手势的响应总是在原始指针事件的后面**
    - iOS里那样手势会具备更高的优先级
  - 最终响应者数组
    - 初始: [GestureDetector对应的Listener、Listener]
    - hitTest: [GestureDetector对应的Listener、Listener、GestureBinding]
    - 由此可以得知真实触发顺序
- **拦截**
  - 如果我们只想让原始指针事件和手势中的一个响应事件，那就换换它们的父子关系，给子视图外面套一个`IgnorePointer`或`AbsorbPointer`就行了，它俩分别有一个`bool`值属性叫`ignoring`、`absorbing`用来决定是否拦截事件，我们可以根据实际情况来改变这俩属性的值，其实这俩Widget拦截事件的本质就是拦截响应者不被添加进响应者数组里

