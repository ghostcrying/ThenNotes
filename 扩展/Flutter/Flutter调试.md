# Flutter调试



## 调试应用层

#### Widget层

> 转存Widget库状态需调用debugDumpApp()。 
>
> 只要应用程序已经构建了至少一次（即在调用build()之后的任何时间），您可以在应用程序未处于构建阶段（即，不在build()方法内调用 ）的任何时间调用此方法（在调用runApp()之后）
>
> 若是编写自己的widget，则可以通过覆盖`debugFillProperties()`来添加信息。 将`DiagnosticsProperty`对象作为方法参数，并调用父类方法。 该函数是该`toString`方法用来填充小部件描述信息的

###### Example

```
import'package:flutter/rendering.dart';
...
Container(
  margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
  height: 100,
  color: Color(0xff1fbfbf),
  child: TextButton(
      onPressed: () {
        debugDumpApp();
        // debugFillProperties()
        // debugDumpRenderTree()
        // debugDumpLayerTree()
        // debugDumpSemanticsTree()
      },
      child: Text("DebugClick")),
),
```

#### 渲染层

> 如果您尝试调试布局问题，那么Widgets层的树可能不够详细。在这种情况下，您可以通过调用`debugDumpRenderTree()`转储渲染树。 正如`debugDumpApp()`，除布局或绘制阶段外，您可以随时调用此函数。作为一般规则，从frame 回调 或事件处理器中调用它是最佳解决方案。

#### 层

> 如果您尝试调试合成问题，则可以使用`debugDumpLayerTree()`。
>
> 这是根`Layer`的`toStringDeep`输出的。
>
> 根部的变换是应用设备像素比的变换; 在这种情况下，每个逻辑像素代表3.5个设备像素。
>
> `RepaintBoundary` widget在渲染树的层中创建了一个`RenderRepaintBoundary`。这用于减少需要重绘的需求量。

```
I/flutter : TransformLayer
I/flutter :  │ creator: [root]
I/flutter :  │ offset: Offset(0.0, 0.0)
I/flutter :  │ transform:
I/flutter :  │   [0] 3.5,0.0,0.0,0.0
I/flutter :  │   [1] 0.0,3.5,0.0,0.0
I/flutter :  │   [2] 0.0,0.0,1.0,0.0
I/flutter :  │   [3] 0.0,0.0,0.0,1.0
I/flutter :  │
I/flutter :  ├─child 1: OffsetLayer
I/flutter :  │ │ creator: RepaintBoundary ← _FocusScope ← Semantics ← Focus-[GlobalObjectKey MaterialPageRoute(560156430)] ← _ModalScope-[GlobalKey 328026813] ← _OverlayEntry-[GlobalKey 388965355] ← Stack ← Overlay-[GlobalKey 625702218] ← Navigator-[GlobalObjectKey _MaterialAppState(859106034)] ← Title ← ⋯
I/flutter :  │ │ offset: Offset(0.0, 0.0)
I/flutter :  │ │
I/flutter :  │ └─child 1: PictureLayer
I/flutter :  │
I/flutter :  └─child 2: PictureLayer
```

#### 语义

> 您还可以调用`debugDumpSemanticsTree()`获取语义树（呈现给系统可访问性API的树）的转储。 要使用此功能，必须首先启用辅助功能，例如启用系统辅助工具或`SemanticsDebugger` （下面讨论）。

对于上面的例子，它会输出:

```
I/flutter : SemanticsNode(0; Rect.fromLTRB(0.0, 0.0, 411.4, 683.4))
I/flutter :  ├SemanticsNode(1; Rect.fromLTRB(0.0, 0.0, 411.4, 683.4))
I/flutter :  │ └SemanticsNode(2; Rect.fromLTRB(0.0, 0.0, 411.4, 683.4); canBeTapped)
I/flutter :  └SemanticsNode(3; Rect.fromLTRB(0.0, 0.0, 411.4, 683.4))
I/flutter :    └SemanticsNode(4; Rect.fromLTRB(0.0, 0.0, 82.0, 36.0); canBeTapped; "Dump App")
```

#### 调度

> 要找出相对于帧的开始/结束事件发生的位置，可以切换`debugPrintBeginFrameBanner`和`debugPrintEndFrameBanner`布尔值以将帧的开始和结束打印到控制台。
>
> `debugPrintScheduleFrameStacks`还可以用来打印导致当前帧被调度的调用堆栈。

###### Example:

```
I/flutter : ▄▄▄▄▄▄▄▄ Frame 12         30s 437.086ms ▄▄▄▄▄▄▄▄
I/flutter : Debug print: Am I performing this work more than once per frame?
I/flutter : Debug print: Am I performing this work more than once per frame?
I/flutter : ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
```



## 可视化调试

#### 调试参数

###### debugPaintSizeEnabled: 

> 启用时，所有的盒子都会得到一个明亮的深青色边框，padding（来自widget如Padding）显示为浅蓝色，子widget周围有一个深蓝色框， 对齐方式（来自widget如Center和Align）显示为黄色箭头. 空白（如没有任何子节点的Container）以灰色显示

###### debugPaintBaselinesEnabled

> 做了类似的事情，但对于具有基线的对象，文字基线以绿色显示，表意(ideographic)基线以橙色显示

###### debugPaintPointersEnabled

> 标志打开一个特殊模式，任何正在点击的对象都会以深青色突出显示。 这可以帮助您确定某个对象是否以某种不正确地方式进行hit测试（Flutter检测点击的位置是否有能响应用户操作的widget）,例如，如果它实际上超出了其父项的范围，首先不会考虑通过hit测试。

###### debugPaintLayerBordersEnabled / debugRepaintRainbowEnabled

> 如果您尝试调试合成图层，例如以确定是否以及在何处添加`RepaintBoundary` widget，则可以使用`debugPaintLayerBordersEnabled` 标志， 该标志用橙色或轮廓线标出每个层的边界，或者使用`debugRepaintRainbowEnabled`标志， 只要他们重绘时，这会使该层被一组旋转色所覆盖

###### debugPrintMarkNeedsLayoutStacks / debugPrintMarkNeedsPaintStacks

> 要了解您的应用程序导致重新布局或重新绘制的原因，您可以分别设置`debugPrintMarkNeedsLayoutStacks`和 `debugPrintMarkNeedsPaintStacks`标志。 每当渲染盒被要求重新布局和重新绘制时，这些都会将堆栈跟踪记录到控制台。如果这种方法对您有用，您可以使用`services`库中的`debugPrintStack()`方法按需打印堆栈痕迹

###### Example: 

```
// 导入
import 'package:flutter/rendering.dart';
// 直接设定
void main() {
  ///
  debugPaintSizeEnabled = true;
  debugPaintPointersEnabled = true;
  debugPaintLayerBordersEnabled = true;
  debugRepaintRainbowEnabled = true;
  return runApp(MyApp());
}
```

#### 调试动画

> 调试动画最简单的方法是减慢它们的速度。为此，请将`timeDilation`变量（在scheduler库中）设置为大于1.0的数字，例如50.0。 最好在应用程序启动时只设置一次。如果您在运行中更改它，尤其是在动画运行时将其值减小，则框架的观察时可能会倒退，这可能会导致断言并且通常会干扰您的工作

```
Widget build(BuildContext context) {
    timeDilation = 60.0;
    ...
}
```



#### 调试性能问题

> 要了解您的应用程序导致重新布局或重新绘制的原因，您可以分别设置`debugPrintMarkNeedsLayoutStacks`和 `debugPrintMarkNeedsPaintStacks`÷标志。 每当渲染盒被要求重新布局和重新绘制时，这些都会将堆栈跟踪记录到控制台。如果这种方法对您有用，您可以使用`services`库中的`debugPrintStack()`方法按需打印堆栈痕迹

#### 启动时间

> 要收集有关Flutter应用程序启动所需时间的详细信息，可以在运行`flutter run`时使用`trace-startup`和`profile`选项。

```
flutter run --trace-startup --profile

输出为 build/start_up_info.json
{
  // 进入Flutter引擎
  "engineEnterTimestampMicros": 96025565262,
  // 展示应用第一帧
  "timeToFirstFrameMicros": 2171978,
  // 初始化Flutter框架时
  "timeToFrameworkInitMicros": 514585,
  // 完成Flutter框架初始化时
  "timeAfterFrameworkInitMicros": 1657393
}
```

#### 代码块性能

```
Timeline.startSync('interesting function');
// iWonderHowLongThisTakes();
Timeline.finishSync();
```

> 然后打开你应用程序的Observatory timeline页面，在”Recorded Streams”中选择’Dart’复选框，并执行你想测量的功能。
>
> 刷新页面将在Chrome的`跟踪工具`中显示应用按时间顺序排列的timeline记录。
>
> 请确保运行`flutter run`时带有`--profile`标志，以确保运行时性能特征与您的最终产品差异最小

#### Performance Overlay

> 要获得应用程序性能图，请将`MaterialApp`构造函数的`showPerformanceOverlay`参数设置为true。 `WidgetsApp`构造函数也有类似的参数（如果你没有使用`MaterialApp`或者`WidgetsApp`，你可以通过将你的应用程序包装在一个stack中， 并将一个widget放在通过`new PerformanceOverlay.allEnabled()`创建的stack上来获得相同的效果）。
>
> 这将显示两个图表。第一个是GPU线程花费的时间，最后一个是CPU线程花费的时间。 图中的白线以16ms增量沿纵轴显示; 如果图中超过这三条线之一，那么您的运行频率低于60Hz。横轴代表帧。 该图仅在应用程序绘制时更新，因此如果它处于空闲状态，该图将停止移动。
>
> 这应该始终在发布模式（release mode）下测试，因为在调试模式下，故意牺牲性能来换取有助于开发调试的功能，如assert声明，这些都是非常耗时的，因此结果将会产生误导。

#### Material grid

> 在开发实现`Material Design`的应用程序时， 将`Material Design基线网格`覆盖在应用程序上可能有助于验证对齐。 为此，`MaterialApp` 构造函数有一个`debugShowMaterialGrid`参数， 当在调试模式设置为true时，它将覆盖这样一个网格。
>
> ```
> return MaterialApp(
>   debugShowMaterialGrid: true, /// 显示网格
>   home: xxx);
> ```
>
> 您也可以直接使用`GridPaper`widget将这种网格覆盖在非Material应用程序上 。

#### Flutter Inspector

```
运行flutter run --debug可以进行UI调试

*--debug, --release, --profile三者只能选择其一
*Only one of "--debug", "--profile", "--jit-release", or "--release" can be specified.
```

> - Debug模式可以在真机和模拟器上同时运行：会打开所有的断言，包括debugging信息、debugger aids（比如observatory）和服务扩展。优化了快速develop/run循环，但是没有优化执行速度、二进制大小和部署
> - Release模式只能在真机上运行，不能在模拟器上运行：会关闭所有断言和debugging信息，关闭所有debugger工具。优化了快速启动、快速执行和减小包体积。禁用所有的debugging aids和服务扩展。这个模式是为了部署给最终的用户使用
> - Profile模式只能在真机上运行，不能在模拟器上运行：基本和Release模式一致，除了启用了服务扩展和tracing，以及一些为了最低限度支持tracing运行的东西
> - headless test模式只能在桌面上运行：基本和Debug模式一致，除了是headless的而且你能在桌面运行



## 单元测试

在test/widget_test.dart中进行代码测试

```
testWidgets('tree test example', (WidgetTester tester) async {
  // 加载MyApp类, 若不加载后面代码运行无承载
  await tester.pumpWidget(const MyApp());
  
  // findsOneWidget 表示没有文字为「0」找到 Widget
  expect(find.text('0'), findsNothing);
  
  // 读取当前App  
  await tester.pumpWidget(const MyApp());
  // 进行页面元素获取
  expect(find.text('debugDumpApp'), findsOneWidget);
  await tester.tap(find.byType(TextButton));
  /// 此处find.by...可以找到多重样式UI
  
  // 找到图标, 触发图标自身的tap事件
  await tester.tap(find.byIcon(Icons.add));
  // tester 「抽身逃走」
  await tester.pump();
  // tester 已经「跑路」了，所以tap不会执行，但也不会报错
  await tester.tap(find.byIcon(Icons.add));
});
```



## 参考: [Flutter中文网](https://flutterchina.club/inspector/)

