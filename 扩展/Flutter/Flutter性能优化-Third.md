# Flutter性能优化

### 目录

- 一、检测手段
  - 1、Flutter Inspector
  - 2、性能图层
  - 3、Raster 线程问题
  - 4、UI 线程问题定位
  - 5、检查多视图叠加的视图渲染开关 checkerboardOffscreenLayers
  - 6、检查缓存的图像开关 checkerboardRasterCacheImages
- 二、关键优化指标
  - 1、页面异常率
  - 2、页面帧率
  - 3、页面加载时长
- 三、布局加载优化
  - 1、常规优化
  - 2、深入优化
- 四、启动速度优化
  - 1、引擎预加载
  - 2、Dart VM 预热
- 五、内存优化
  - 1、const 实例化
  - 2、识别出消耗多余内存的图片
  - 3、针对 ListView item 中有 image 的情况来优化内存
- 六、包体积优化
  - 1、图片优化
  - 2、移除冗余的二三库
  - 3、启用代码缩减和资源缩减
  - 4、构建单 ABI 架构的包
- 七、总结



# 前言

Flutter 作为目前最火爆的移动端跨平台框架，能够帮助开发者通过一套代码库高效地构建多平台的精美应用，并支持移动、Web、桌面和嵌入式平台。对于 Android 来说，Flutter 能够创作媲美原生的高性能应用，但是，在较为复杂的 App 中，使用 Flutter 开发也很难避免产生各种各样的性能问题。在这篇文章中，我将和你一起全方位地深入探索 Flutter 性能优化的疆域。



# 一、检测手段

### 准备

以 profile 模式启动应用，如果是混合 Flutter 应用，在 flutter/packages/flutter_tools/gradle/flutter.gradle 的 buildModeFor 方法中将 debug 模式改为 profile即可。

### 为什么要在分析模式下来调试应用性能？

分析模式在发布模式的基础之上，为分析工具提供了少量必要的应用追踪信息。

### 那，为什么要在发布模式的基础上来调试应用性能？

与调试代码可以在调试模式下检测 Bug 不同，性能问题需要在发布模式下使用真机进行检测。这是因为，相比发布模式而言，**调试模式增加了很多额外的检查（比如断言），这些检查可能会耗费很多资源，而更重要的是，调试模式使用 JIT 模式运行应用，代码执行效率较低。这就使得调试模式运行的应用，无法真实反映出它的性能问题**。

而另一方面，**模拟器使用的指令集为 x86，而真机使用的指令集是 ARM**。这两种方式的二进制代码执行行为完全不同，因此，模拟器与真机的性能差异较大，例如，针对一些 x86 指令集擅长的操作，模拟器会比真机快，而另一些操作则会比真机慢。这也同时意味着，你无法使用模拟器来评估真机才能出现的性能问题。

## 1、Flutter Inspector

Flutter Inspector有很多功能，但你应该把注意力花在更有用的功能学习上，例如：**“Select Widget Mode” 和 “Repaint Rainbow”**。

### Select Widget Mode

点击 “Select Widget Mode” 图标，可以在手机上查看当前页面的布局框架与容器类型。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8d3d4ce3dd9a4427aa4088a6618f10a9~tplv-k3u1fbpfcp-watermark.image)

#### 作用

**快速查看陌生页面的布局实现方式**。

### Repaint Rainbow

点击 “Repaint Rainbow” 图标，它会 **为所有 RenderBox 绘制一层外框，并在它们重绘时会改变颜色**。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73eaaf50a2a341ee878cacbcdfa56360~tplv-k3u1fbpfcp-watermark.image)

#### 作用

**帮你找到 App 中频繁重绘导致性能消耗过大的部分**。

例如：一个小动画可能会导致整个页面重绘，这个时候使用 RepaintBoundary Widget 包裹它，可以将重绘范围缩小至本身所占用的区域，这样就可以减少绘制消耗。

#### 使用场景

例如 **页面的进度条动画刷新时会导致整个布局频繁重绘**。

#### 缺点

**使用 RepaintBoundary Widget 会创建额外的绘制画布，这将会增加一定的内存消耗**。

## 2、性能图层

性能图层会在当前应用的最上层，以 Flutter 引擎自绘的方式展示 Raster 与 UI 线程的执行图表，而其中每一张图表都代表当前线程最近 300 帧的表现，如果 UI 产生了卡顿（跳帧），这些图表可以帮助你分析并找到原因。

**蓝色垂直的线条表示已执行的正常帧，绿色的线条代表的是当前帧，如果其中有一帧处理时间过长，就会导致界面卡顿，图表中就会展示出一个红色竖条**。

**如果红色竖条出现在 GPU 线程图表，意味着渲染的图形太复杂，导致无法快速渲染；而如果是出现在了 UI 线程图表，则表示 Dart 代码消耗了大量资源，需要优化代码的执行时间**。如下图所示：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d5bd073d42d48e5ab486e5186afabe9~tplv-k3u1fbpfcp-watermark.image)

## 3、Raster 线程问题定位

它定位的是 **渲染引擎底层渲染的异常**。

解决方案是 **把需要静态缓存的图像加入到 RepaintBoundary。而 RepaintBoundary 可以确定 Widget 树的重绘边界，如果图像足够复杂，Flutter 引擎会自动将其缓存，避免重复刷新。当然，因为缓存资源有限，如果引擎认为图像不够复杂，也可能会忽略 RepaintBoundary。**

## 4、UI 线程问题定位

### 问题场景

在视图构建时，在 build 方法中使用了一些复杂的运算，或是在主 Isolate 中进行了同步的 I/O 操作。

### 使用 Performance 进行检测

点击 Android Studio 底部工具栏中的 “Open DevTools” 按钮，然后在打开的 Dart DevTools 网页中将顶部的 tab 切换到 Performance。

与性能图层能够自动记录应用执行的情况不同，使用 Performance 来分析代码执行轨迹，你需要手动点击 “Record” 按钮去主动触发，在完成信息的抽样采集后，点击 “Stop” 按钮结束录制。这时，你就可以得到在这期间应用的执行情况了。

**使用 Performance 记录应用的执行情况，即 CPU 帧图，又被称为火焰图。火焰图是基于记录代码执行结果所产生的图片，用来展示 CPU 的调用栈，表示的是 CPU 的繁忙程度**。

其中：

- **y 轴**：表示调用栈，其每一层都是一个函数。**调用栈越深，火焰就越高，底部就是正在执行的函数，上方都是它的父函数**。
- **x 轴**：表示单位时间，一**个函数在 x 轴占据的宽度越宽，就表示它被采样到的次数越多，即执行时间越长**。

所以，我们要 **检测 CPU 耗时问题，皆可以查看火焰图底部的哪个函数占据的宽度最大。只要有 “平顶”，就表示该函数可能存在性能问题**。如下图所示：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/90fff91667f040a28535bf92bfe773a4~tplv-k3u1fbpfcp-watermark.image)

一般的耗时问题，我们通常可以 **使用 Isolate（或 compute）将这些耗时的操作挪到并发主 Isolate 之外去完成**。

> dart 的单线程执行异步任务是怎么实现的？

网络调用的执行是由操作系统提供的另外的底层线程做的，而在 event queue 里只会放一个网络调用的最终执行结果（成功或失败）和响应执行结果的处理回调。

## 5、使用 checkerboardOffscreenLayers 检查多视图叠加的视图渲染

只要在 MaterialApp 的初始化方法中，将 checkerboardOffscreenLayers 开关设置为 true，分析工具就会自动帮你检测多视图叠加的情况。

这时，使用了 saveLayer 的 Widget 会自动显示为棋盘格式，并随着页面刷新而闪烁。

而 saveLayer 一般会通过一些功能性 Widget，在涉及需要剪切或半透明蒙层的场景中间接地使用。

## 6、使用 checkerboardRasterCacheImages 检查缓存的图像

它也是用来检测在界面重绘时频繁闪烁的图像（即没有静态缓存）。解决方案是把需要静态缓存的图像加入到 RepaintBoundary。



# 二、关键优化指标

## 1、页面异常率

页面异常率，即 页**面渲染过程中出现异常的概率。**

它度量的是页面维度下功能不可用的情况，其统计公式为：

> 页面异常率 = 异常发生次数 / 整体页面 PV 数。

### 统计异常发生次数

利用 Zone 与 FlutterError 这两个方法，然后在异常拦截的方法中，去累计异常的发生次数。

### 统计整体页面 PV 数

继承自 NavigatorObserver 的观察者，并在其 didPush 方法中，去累加页面的打开次数。

## 2、页面帧率

Flutter 在全局 Window 对象上提供了帧回调机制。我们可以在 Window 对象上注册 onReportTimings 方法，将最近绘制帧耗费的时间（即 FrameTiming），以回调的形式告诉我们。

有了每一帧的绘制时间后，我们就可以计算 FPS 了。

为了让 FPS 的计算更加平滑，我们需要保留最近 25 个 FrameTiming 用于求和计算。

由于帧的渲染是依靠 VSync 信号驱动的，如果帧绘制的时间没有超过 16.67 ms，我们也需要把它当成 16.67 ms 来算，因为绘制完成的帧必须要等到下一次 VSync 信号来了之后才能渲染。而如果帧绘制时间超过了 16.67 ms，则会占用后续 VSync 的信号周期，从而打乱后续的绘制次序，产生卡顿现象。

那么，页面帧率的统计公式就是：

> FPS = 60 * 实际渲染的帧数 / 本来应该在这个时间内渲染完成的帧数。

首先，定义一个容量为 25 的列表，用于存储最近的帧绘制耗时 FrameTiming。

然后，在 FPS 的计算函数中，你再将列表中每帧绘制时间与 VSync 周期 frameInterval 进行比较，得出本来应该绘制的帧数。

最后，两者相除就得到了 FPS 指标。

## 3、页面加载时长

> 页面加载时长 = 页面可见的时间 - 页面创建的时间（包括网络加载时长）

### 统计页面可见的时间

**WidgetsBinding 提供了单次 Frame 回调的 addPostFrameCallback 方法，它会在当前 Frame 绘制完成之后进行回调，并且只会回调一次。一旦监听到 Frame 绘制完成回调后，我们就可以确认页面已经被渲染出来了**，因此我们可以借助这个方法去获取页面的渲染完成时间 endTime。

### 统计页面创建的时间

获取页面创建的时间比较容易，我们只需要在页面的初始化函数 initState() 里记录页面的创建时间 startTime。

最后，再将这两个时间做减法，你就能得到页面的加载时长。

需要注意的是，**正常的页面加载时长一般都不应该超过2秒。如果超过了，则意味着有严重的性能问题。**



# 三、布局加载优化

> Flutter 为什么要使用声明书 UI 的编写方式？

为了减轻开发人员的负担，无需编写如何在不同的 UI 状态之间进行切换的代码，Flutter 使用了声明式的 UI 编写方式，而不是 Android 和 iOS 中的命令式编写方式。

这样的话，**当用户界面发生变化时，Flutter 不会修改旧的 Widget 实例，而是会构造新的 Widget 实例**。

Fluter 框架使用 RenderObjects 管理传统 UI 对象的职责（比如维护布局的状态）。 RenderObjects 在帧之间保持不变， Flutter 的轻量级 Widget 通知框架在状态之间修改 RenderObjects， 而 Flutter Framework 则负责处理其余部分。

## 1、常规优化

常规优化即针对 build() 进行优化，build() 方法中的性能问题一般有两种：**耗时操作和 Widget 堆叠**。

### 1）、在 build() 方法中执行了耗时操作

我们应该尽量避免在 build() 中执行耗时操作，因为 build() 会被频繁地调用，尤其是当 Widget 重建的时候。

此外，我们不要在代码中进行阻塞式操作，可以将文件读取、数据库操作、网络请求等通过 Future 来转换成异步方式来完成。

最后，对于 CPU 计算频繁的操作，例如图片压缩，可以使用 isolate 来充分利用多核心 CPU。

**isolate 作为 Flutter 中的多线程实现方式，之所以被称之为 isolate（隔离），是因为每一个 isolate 都有一份单独的内存**。

**Flutter 会运行一个事件循环，它会从事件队列中取得最旧的事件，处理它，然后再返回下一个事件进行处理，依此类推，直到事件队列清空为止。每当动作中断时，线程就会等待下一个事件**。

实质上，不仅仅是 isolate，所有的高级 API 都能够应用于异步编程，例如 Futures、Streams、async 和 await，它们全部都是构建在这个简单的事件循环之上。

而，async 和 await 实际上只是使用 futures 和 streams 的替代语法，它将代码编写形式从异步变为同步，主要用来帮助你编写更清晰、简洁的代码。

此外，async 和 await 也能使用 try on catch finally 来进行异常处理，这能够帮助你处理一些数据解析方面的异常。

### 2). build() 方法中堆砌了大量的 Widget

这将会导致三个问题：

- 1、**代码可读性差**：画界面时需要一个 Widget 嵌套一个 Widget，但如果 Widget 嵌套太深，就会导致代码的可读性变差，也不利于后期的维护和扩展。
- 2、**复用难**：由于所有的代码都在一个 build()，会导致无法将公共的 UI 代码复用到其它的页面或模块。
- 3、**影响性能**：我们在 State 上调用 setState() 时，所有 build() 中的 Widget 都将被重建，因此 build() 中返回的 Widget 树越大，那么需要重建的 Widget 就越多，也就会对性能越不利。

所以，你需要 **控制 build 方法耗时，将 Widget 拆小，避免直接返回一个巨大的 Widget，这样 Widget 会享有更细粒度的重建和复用。**

### 3). 使用 Widget 而不是函数

如果一个函数可以做同样的事情，Flutter 就不会有 StatelessWidget ，使用 StatelessWidget 的最大好处在于：能尽量避免不必要的重建。总的来说，它的优势有：

- 1）、允许性能优化：const 构造函数，更细粒度的重建等等。
- 2）、确保在两个不同的布局之间切换时，能够正确地处理资源（因为函数可能重用某些先前的状态）。
- 3）、确保热重载正常工作，使用函数可能会破坏热重载。
- 4）、在 flutter 自带的 Widget 显示工具中能看到 Widget 的状态和参数。
- 5）、发生错误时，有更清晰的提示：此时，Flutter 框架将为你提供当前构建的 Widget 名称，更容易排查问题。
- 6）、可以定义 key 和方便使用 context 的 API。

### 4). 尽可能地使用 const

如果某一个实例已经用 const 定义好了，那么其它地方再次使用 const 定义时，则会直接从常量池里取，这样便能够节省 RAM。

### 5). 尽可能地使用 const 构造器

当构建你自己的 Widget 或者使用 Flutter 的 Widget 时，这将会帮助 Flutter 仅仅去 rebuild 那些应当被更新的 Widget。

因此，你应该尽量多用 const 组件，这样即使父组件更新了，子组件也不会重新进行 rebuild 操作。特别是针对一些长期不修改的组件，例如通用报错组件和通用 loading 组件等。

### 6). 使用 nil 去替代 Container() 和 SizedBox()

首先，你需要明白 **nil 仅仅是一个基础的 Widget 元素 ，它的构建成本几乎没有。**

在某些情况下，如果你不想显示任何内容，且不能返回 null 的时候，你可能会返回类似 const SizedBox/Container 的 Widget，但是 SizedBox 会创建 RenderObject，而渲染树中的 RenderObject 会带来多余的生命周期控制和额外的计算消耗，即便你没有给 SizedBox 指定任何的参数。

下面，是我平时使用 nil 的一套方式：

```
// BEST
text != null ? Text(text) : nil
or
if (text != null) Text(text)
text != null ? Text(text) : const Container()/SizedBox()
复制代码
```

### 7). 列表优化

在构建大型网格或列表的时候，我们要尽量避免使用 ListView(children: [],) 或 GridView(children: [],)。

因为，在这种场景下，不管列表内容是否可见，会导致列表中所有的数据都会被一次性绘制出来，这种用法类似于 Android 的 ScrollView。

如果我们列表数据比较大的时候，建议使用 ListView 和 GridView 的 builder 方法，它们只会绘制可见的列表内容，类似于 Android 的 RecyclerView。

其实，本质上，**就是对列表采用了懒加载而不是直接一次性创建所有的子 Widget，这样视图的初始化时间就减少了**。

### 8). 针对于长列表，记得在 ListView 中使用 itemExtent。

有时候当我们有一个很长的列表，想要用滚动条来大跳时，使用 itemExtent 就很重要了，**它会帮助 Flutter 去计算 ListView 的滚动位置而不是计算每一个 Widget 的高度，与此同时，它能够使滚动动画有更好的性能**。

### 9). 减少可折叠 ListView 的构建时间

**针对于可折叠的 ListView，未展开状态时，设置其 itemCount 为 0，这样 item 只会在展开状态下才进行构建，以减少页面第一次的打开构建时间**。

### 10). 尽量不要为 Widget 设置半透明效果

考虑用图片的形式代替，这样被遮挡的部分 Widget 区域就不需要绘制了。

除此之外，还有网络请求预加载优化、抽取文本 Theme 等常规的优化方式就不赘述了。

## 2、深入优化

### 1). 优化光栅线程

所有的 Flutter 应用至少都会运行在两个并行的线程上：**UI 线程和 Raster 线程**。

**UI 线程是你构建 Widgets 和运行应用逻辑的地方。 ** **Raster 线程是 Flutter 用来栅格化你的应用的。它从 UI 线程获取指令并将它们转换为可以发送到图形卡的内容。**

**在光栅线程中，会获取图片的字节，调整图像的大小，应用透明度、混合模式、模糊等等，直到产生最后的图形像素。然后，光栅线程会将其发送到图形卡，继而发送到屏幕上显示。**

使用 Flutter DevTools-Performance 进行检测，步骤如下：

- 1、在 Performance Overlay 中，查看光栅线程和 UI 线程哪个负载过重。
- 2、在 Timeline Events 中，找到那些耗费时间最长的事件，例如常见的 SkCanvas::Flush，它负责解决所有待处理的 GPU 操作。
- 3、找到对应的代码区域，通过删除 Widgets 或方法的方式来看对性能的影响。

### 2). 用 key 加速 Flutter 的性能优化光栅线程

一个 element 是由 Widget 内部创建的，它的主要目的是，**知道对应的 Widget 在 Widget 树中所处的位置。但是元素的创建是非常昂贵的，通过 Keys（ValueKeys 和 GlobalKeys），我们可以去重复使用它们。**

> GlobalKey 与 ValueKey 的区别？

**GlobalKey 是全局使用的 key，在跨小部件的场景时，你就可以使用它去刷新其它小部件。但，它是很昂贵的，如果你不需要访问 BuildContext、Element 和 State，应该尽量使用 LocalKey。**

而 ValueKey 和 ObjectKey、UniqueKey 一样都归属于局部使用的 LocalKey，无法跨容器使用，ValueKey 比较的是 Widget 的值，而 ObjectKey 比较的是对象的 key，UniqueKey 则每次都会生成一个不同的值。

#### 元素的生命周期

- **Mount**：挂载，当元素第一次被添加到树上的时候调用。
- **Active**：当需要激活之前失活的元素时被调用。
- **Update**：用新数据去更新 RenderObject。
- **Deactive**：当元素从 Widget 树中被移除或移动时被调用。如果一个元素在同一帧期间被移动了且它有 GlobalKey，那么它仍然能够被激活。
- **UnMount**：卸载，如果一个元素在一帧期间没有被激活，它将会被卸载，并且再也不会被复用。

#### 优化方式

**为了去改善性能，你需要去尽可能让 Widget 使用 Activie 和 Update 操作，并且尽量避免让 Widget触发 UnMount 和 Mount。**而使用 GlobayKeys 和 ValueKey 则能做到这一点：

```
/// 1、给 MaterialApp 指定 GlobalKeys
MaterialApp(key: global, home: child,);
/// 2、通过把 ValueKey 分配到正在被卸载的根 Widget，你就能够
/// 减少 Widget 的平均构建时间。
Widget build(BuildContext context) {
  return Column(
    children: [
      value
          ? const SizedBox(key: ValueKey('SizedBox'))
          : const Placeholder(key: ValueKey('Placeholder')),
      GestureDetector(
        key: ValueKey('GestureDetector'),
        onTap: () {
          setState(() {
            value = !value;
          });
        },
        child: Container(
          width: 100,
          height: 100,
          color: Colors.red,
        ),
      ),
      !value
          ? const SizedBox(key: ValueKey('SizedBox'))
          : const Placeholder(key: ValueKey('Placeholder')),
    ],
  );
}
复制代码
```

> 如何知道哪些 Widget 会被 Update，哪些 Widget会被 UnMount？

只有 build 直接 return 的那个根 Widget 会自动更新，其它都有可能被 UnMount，因此都需要给其分配 ValueKey。

> 为什么没有给 Container 分配 ValueKey？

因为 Container 是 GestureDetector 的一个子 Widget，所以当给 GestureDetector 使用 ValueKey 去实现复用更新时，Container 也能被自动更新。

#### 优化效果

优化前：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f07e8348c899446b88090d9d007f81f4~tplv-k3u1fbpfcp-watermark.image)

优化后：

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1238deeab6346d5a183a5ede5e03038~tplv-k3u1fbpfcp-watermark.image)

可以看到，平均构建时间 **由 5.5ms 减少到 1.6ms**，优化效果还是很明显的。

#### 优势

大幅度减少 Widget的平均构建时间。

#### 缺点

- **过多使用 ValueKey 会让你的代码变得更冗余。**
- **如果你的根 Widget 是 MaterialApp 时，则需要使用 GlobalKey，但当你去重复使用 GlobalKey 时可能会导致一些错误，所以一定要避免滥用 Key。**

注意📢：在大部分场景下，Flutter 的性能都是足够的，不需要这么细致的优化，只有当产生了视觉上的问题，例如卡顿时才需要去分析优化。



# 四、启动速度优化

## 1、Flutter 引擎预加载

使用它可以达到页面秒开的一个效果，具体实现为：

在 HIFlutterCacheManager 类中定义一个 preLoad 方法，**使用 Looper.myQueue().addIdleHandler 添加一个 idelHandler，当 CPU 空闲时会回调 queueIdle 方法，在这个方法里，你就可以去初始化 FlutterEngine，并把它缓存到集合中。**

预加载完成之后，你就可以通过 HIFlutterCacheManager 类的 getCachedFlutterEngine 方法从集合中获取到缓存好的引擎。

## 2、Dart VM 预热

对于 Native + Flutter 的混合场景，如果不想使用引擎预加载的方式，那么要提升 Flutter 的启动速度也可以通 过Dart VM 预热来完成，这种方式会提升一定的 Flutter 引擎加载速度，但整体对启动速度的提升没有预加载引擎提升的那么多。

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a8dae19b00cc4fcda79bf03b769cb47c~tplv-k3u1fbpfcp-watermark.image)

**无论是引擎预加载还是 Dart VM 预热都是有一定的内存成本的，如果 App 内存压力不大，并且预判用户接下来会访问 Flutter 业务，那么使用这个优化就能带来很好的价值；反之，则可能造成资源浪费，意义不大。**



# 五、内存优化

## 1、const 实例化

### 优势

**const 对象只会创建一个编译时的常量值。在代码被加载进 Dart Vm 时，在编译时会存储在一个特殊的查询表里，由于 flutter 采用了 AoT 编译，const + values 的方式会提供一些小的性能优势。**例如：const Color() 仅仅只分配一次内存给当前实例。

### 应用场景

Color()、GlobayKey() 等等。

## 2、识别出消耗多余内存的图片

Flutter Inspector：**点击 “Invert Oversized Images”，它会识别出那些解码大小超过展示大小的图片，并且系统会将其倒置，这些你就能更容易在 App 页面中找到它。**

![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f40b02b91214afeafe39ff2ac183c15~tplv-k3u1fbpfcp-watermark.image)

针对这些图片，你可以指定 cacheWidth 和 cacheHeight 为展示大小，这样可以让 flutter 引擎以指定大小解析图片，减少内存消耗。

## 3、针对 ListView item 中有 image 的情况来优化内存

ListView 不能够杀死那些在屏幕可视范围之外的那些 item，如果 item 使用了高分辨率的图片，那么它将会消耗非常多的内存。

换言之，ListView 在默认情况下会在整个滑动/不滑动的过程中让子 Widget 保持活动状态，这一点是通过 AutomaticKeepAlive 来保证，在默认情况下，每个子 Widget 都会被这个 Widget 包裹，以使被包裹的子 Widget 保持活跃。

其次，如果用户向后滚动，则不会再次重新绘制子 Widget，这一点是通过 RepaintBoundaries 来保证，在默认情况下，每个子 Widget 都会被这个 Widget 包裹，它会让被包裹的子 Widget 仅仅绘制一次，以此获得更高的性能。

但，这样的问题在于，如果加载大量的图片，则会消耗大量的内存，最终可能使 App 崩溃。

### 解决方案

**通过将这两个选项置为 false 来禁用它们，这样不可见的子元素就会被自动处理和 GC。**

```
ListView.builder(
  ...
  addAutomaticKeepAlives: false (true by default)
  addRepaintBoundaries: false (true by default)
);
复制代码
```

**由于重新绘制子元素和管理状态等操作会占用更多的 CPU 和 GPU 资源，但是它能够解决你 App 的内存问题，并且会得到一个高性能的视图列表。**



# 六、包体积优化

## 1、图片优化

对图片压缩或使用在线的网络图片。

## 2、移除冗余的库

随着业务的增加，项目中会引入越来越多的二三方库，其中有不少是功能重复的，甚至是已经不再使用的。移除不再使用的和将相同功能的库进行合并可以进一步减少包体积。

## 3、启用代码缩减和资源缩减

打开 minifyEnabled 和 shrinkResources，构建出来的 release 包会减少 10% 左右的大小，甚至更多。

## 4、构建单 ABI 架构的包

目前手机市场上，x86 / x86_64/armeabi/mips / mips6 的占有量很少，arm64-v8a 作为最新一代架构，是目前的主流，而 armeabi-v7a 只存在少部分的老旧手机中。

所以，**为了进一步优化包大小，你可以构建出单一架构的安装包，在 Flutter 中可以通过以下方式来构建出单一架构的安装包**：

```
cd <flutter应用的android目录>
flutter build apk --split-per-abi
复制代码
```

如果想进一步压缩包体积可将 so 进行动态下发，将 so 放在远端进行动态加载，不仅能进一步减少包体积也可以实现代码的热修复和动态加载。



# 七、总结

在本篇文章中，我主要从以下 六个方面 讲解了 Flutter 性能优化相关的知识：

1）、**检测手段**：Flutter Inspector、性能图层、Raster 和 UI 线程问题的定位 使用 checkerboardOffscreenLayers 检查多视图叠加的视图渲染 、使用 checkerboardRasterCacheImages 检查缓存的图像。 2）、**关键优化指标**：包括页面异常率、页面帧率、页面加载时长。 3）、**布局加载优化**：十大常规优化、优化光栅线程、用 key 加速 Flutter 的性能。 4）、**启动速度优化**：引擎预加载和 Dart VM 预热。 5）、**内存优化**：const 实例化、识别出消耗多余内存的图片、针对 ListView item 中有 image 的情况来优化内存。 6）、**包体积优化**：图片优化、移除冗余的二三库、启用代码缩减和资源缩减、构建单 ABI 架构的包。

在近一年实践 Flutter 的过程中，越发发现一个人真正应该具备的核心能力应该是你的思考能力。

思考能力，包括 **结构化思考/系统性思考/迁移思考/层级思考/逆向思考/多元思考** 等，使用这些思考能力分析问题时能快速地把握住问题的本质，在本质上做功夫，才是王道，才是真的 yyds。

### 参考链接

- 1、[Flutter官方文档-性能优化](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter%2Fraster-thread-performance-optimization-tips-e949b9dbcf06)
- 2、[Flutter youtube 频道](https://link.juejin.cn/?target=https%3A%2F%2Fwww.youtube.com%2Fc%2Fflutterdev%2Ffeatured)
- 3、[Raster thread performance optimization tips](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter%2Fraster-thread-performance-optimization-tips-e949b9dbcf06)
- 4、[Flutter Performance Tips](https://link.juejin.cn/?target=https%3A%2F%2Fitnext.io%2Fflutter-performance-tips-4580b2491da8)
- 5、[Flutter Performance Optimization](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.flutterdevs.com%2Fflutter-performance-optimization-17c99bb31553)
- 6、[Elements, Keys and Flutter’s performance](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter-community%2Felements-keys-and-flutters-performance-3ef15c90f607)
- 7、[如何检测并优化Flutter App的整体性能表现？](https://link.juejin.cn/?target=https%3A%2F%2Ftime.geekbang.org%2Fcolumn%2Farticle%2F138877)
- 8、[如何在命令式框架中修改 UI](https://link.juejin.cn/?target=https%3A%2F%2Fflutter.cn%2Fdocs%2Fget-started%2Fflutter-for%2Fdeclarative)
- 9、[Flutter Layout Cheat Sheet](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter-community%2Fflutter-layout-cheat-sheet-5363348d037e)
- 10、[Flutter: The Advanced Layout Rule Even Beginners Must Know](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter-community%2Fflutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2)
- 11、[Profiling Flutter Applications Using the Timeline](https://link.juejin.cn/?target=https%3A%2F%2Fmedium.com%2Fflutter%2Fprofiling-flutter-applications-using-the-timeline-a1a434964af3)
- 12、[说说Flutter中的RepaintBoundary](https://link.juejin.cn/?target=https%3A%2F%2Fweilu.blog.csdn.net%2Farticle%2Fdetails%2F103452637)
- 13、[说说Flutter中最熟悉的陌生人 —— Key](https://link.juejin.cn/?target=https%3A%2F%2Fweilu.blog.csdn.net%2Farticle%2Fdetails%2F104745624)
- 14、[Splitting widgets to methods is an antipattern](https://link.juejin.cn/?target=https%3A%2F%2Fiiro.dev%2Fsplitting-widgets-to-methods-performance-antipattern%2F)
- 15、[What is the difference between functions and classes to create reusable widgets?](https://link.juejin.cn/?target=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F53234825%2Fwhat-is-the-difference-between-functions-and-classes-to-create-reusable-widgets)
- 16、[How to improve the performance of your Flutter app](https://link.juejin.cn/?target=https%3A%2F%2Fblog.codemagic.io%2Fhow-to-improve-the-performance-of-your-flutter-app.%2F%23dont-split-your-widgets-into-methods)
- 17、[nil: ^1.1.1](https://link.juejin.cn/?target=https%3A%2F%2Fpub.dev%2Fpackages%2Fnil)
- 18、[How to improve the performance of your Flutter app](https://link.juejin.cn/?target=https%3A%2F%2Fblog.codemagic.io%2Fhow-to-improve-the-performance-of-your-flutter-app.%2F%23use-itemextent-in-listview-for-long-lists)
- 19、[Flutter memory optimization series](https://link.juejin.cn/?target=https%3A%2F%2Fdevmuaz.medium.com%2Fflutter-memory-optimization-series-8c4a73f3ea81)