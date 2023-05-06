# Flutter性能优化



## 渲染原理

#### Flutter渲染原理简介

Flutter视图树包含了三颗树：Widget、Element、RenderObject

- Widget: 存放渲染内容、它只是一个配置数据结构，创建是非常轻量的，在页面刷新的过程中随时会重建
- Element: 同时持有Widget和RenderObject，存放上下文信息，通过它来遍历视图树，支撑UI结构
- RenderObject: 根据Widget的布局属性进行layout，paint ，负责真正的渲染

从创建到渲染的大体流程是：根据Widget生成Element，然后创建相应的RenderObject并关联到Element.renderObject属性上，最后再通过RenderObject来完成布局排列和绘制。

例如下面这段布局代码

```
Container(
  color: Colors.blue,
  child: Row(
    children: <Widget>[
      Image.asset('image'),
      Text('text'),
    ],
  ),
);
```

对应三棵树的结构如下图:

![](https://pic3.zhimg.com/80/v2-871d65414702552fd3daf3e9ed468632_1440w.jpg)

了解了这三棵树，我们再来看下页面刷新的时候具体做了哪些操作

当需要更新UI的时候，Framework通知Engine，Engine会等到下个Vsync信号到达的时候，会通知Framework进行animate, build，layout，paint，最后生成layer提交给Engine。Engine会把layer进行组合，生成纹理，最后通过Open Gl接口提交数据给GPU， GPU经过处理后在显示器上面显示，如下图：



![img](https://pic2.zhimg.com/80/v2-1e5b51ac70061f9c36c5be080968e881_1440w.jpg)



结合前面的例子，如果text文本或者image内容发生变化会触发哪些操作呢？

Widget是不可改变，需要重新创建一颗新树，build开始，然后对上一帧的element树做遍历，调用他的updateChild，看子节点类型跟之前是不是一样，不一样的话就把子节点扔掉，创造一个新的，一样的话就做内容更新，对renderObject做updateRenderObject操作，updateRenderObject内部实现会判断现在的节点跟上一帧是不是有改动，有改动才会别标记dirty，重新layout、paint，再生成新的layer交给GPU，流程如下图：



![img](https://pic4.zhimg.com/80/v2-f76f7b02b7e2818a6ec32f1399f8dde3_1440w.jpg)



到这里大家对Flutter在渲染方面有基本的理解，作为后面优化部分内容理解的基础



## 工具

### 性能分析工具及方法

下面来看下性能分析工具，注意，统计性能数据一定要在真机+profile模式下运行，拿到最接近真实的体验数据。

### performance overlay

平时常用的性能分析工具有performance overlay，通过他可以直观看到当前帧的耗时，但是他是UI线程和GPU线程分开展示的，UI Task Runner是Flutter Engine用于执行Dart root isolate代码，GPU Task Runner被用于执行设备GPU的相关调用。绿色的线表示当前帧，出现红色则表示耗时超过16.6ms，也就是发生丢帧现象



![img](https://pic2.zhimg.com/80/v2-c7f72ec1facf96a953f447ea414f8be1_1440w.jpg)



### Dart DevTool

另一个工具是Dart DevTool ，就是早期的Observatory，官方提供的性能检测工具。它的 timeline 界面可以让逐帧分析应用的 UI 性能。但是目前还是预览版，存在一些问题。

profile模式下运行起来，点击android studio底部的菜单按钮，会弹出一个网页

![img](https://pic3.zhimg.com/80/v2-e13af00a4fdb29dc51fed89c4f629642_1440w.jpg)

终端运行也可:

```
flutter run --profile

如果出现多设备: 
Multiple devices found:
Joy 11 (mobile)    • 00008030-000C6D281E50802E            • ios • iOS 15.1 19B74
iPhone Xs (mobile) • 2E108F78-321A-4FC1-9A36-91B5140075A7 • ios • com.apple.CoreSimulator.SimRuntime.iOS-15-2 (simulator)
[1]: Joy 11 (00008030-000C6D281E50802E)
[2]: iPhone Xs (2E108F78-321A-4FC1-9A36-91B5140075A7)
Please choose one (To quit, press "q/Q"):
直接输入你的选择即可1或者2, 也可以退出
```

点击顶部的Timeline菜单

![img](https://pic3.zhimg.com/80/v2-3c9361ddec4bc12116ac2b55eb123d5a_1440w.jpg)



这个时候滑动页面，每一帧的耗时会以柱形bar的形式显示在页面上，每条bar代表一个frame，同时用不同颜色区分UI/GPU线程耗时，这个时候我们要分析卡顿的场景就需要选中一条红色的bar（总耗时超过16.6ms），中间区域的Frame events chart显示了当前选中的frame的事件跟踪，UI和GPU事件是独立的事件流，但它们共享一个公共的时间轴。

选中Frame events chart中的某个事件，以上图为例Layout耗时最长，我们选中它，会在底部Flame chart区域显示一个自顶向下的堆栈跟踪，每个堆栈帧的宽度表示它消耗CPU的时长，消耗大量CPU时长的堆栈是我们首要分析的重点，后面就是具体分析堆栈，定位卡顿问题。



## 优化

> 在性能优化之前，我们需要知道Flutter重构的逻辑。
> 在Android中我们知道绘制需要的三个步骤是 measure、layout、draw。
> 而Flutter对应的是build、layout、paint。
> 他的重构是基于一种标脏和重新创建的方式进行的，所以我们的性能影响一般来自于一个复杂界面的不断重建。可能你只需要修改一个很小的部分，也就是很小的一个子树需要进行修改，那么在代码没有规范的情况下，可能会出现整个界面的刷新，这样我们的性能可能就要下降了数倍.

#### 合理使用`const`关键词

> `const` 您可以通过将其附加到Widget的构造函数来抑制Widget的重建（它与Widget缓存时的状态相同）。
>
> 构建组件时使用 `const` 关键词，可以抑制 widget 的重建。
>
> 使用 const 也需要注意如下几点：
>
> - 当`const` 修饰类的构造函数时，它要求该类的所有成员都必须是`final`的。
> - `const` 变量只能在定义的时候初始化。

#### 合理使用组件

##### setState

> *判定重建的必要性, 进行组件(自定义)代码的模块化重建
>
> Example: 
>
> 如果只是刷新复杂视图中的小的组件, 那么完全可以单独将该组件抽出来, 独立处理重建逻辑.

##### saveLayer

> Flutter 实现的一些效果背后可能会使用 `saveLayer()` 这个代价很大的方法

```
* 为什么 saveLayer 代价很大？
* 调用 saveLayer() 会开辟一片离屏缓冲区。将内容绘制到离屏缓冲区可能会触发渲染目标切换，这些切换在较早期的 GPU 中特别慢。
—— From: flutter.cn，https://flutter.cn/docs/testing/best-practices
```

> 如下这几个组件，底层都会触发 saveLayer() 的调用，同样也都会导致性能的损耗：
>
> - ShaderMask
>
> - ColorFilter
>
> - Chip，当 disabledColorAlpha != 0xff 的时候，会调用 saveLayer()。
>
> - Text，如果有 overflowShader，可能调用 saveLayer() ，

##### 官方优化点:

> - 由于 Opacity 会使用屏幕外缓冲区直接使目标组件中不透明，因此能不用 Opacity Widget，就尽量不要用。有关将透明度直接应用于图像的示例，请参见 Transparent image，比使用 Opacity widget 更快，性能更好。
>
> - 要在图像中实现淡入淡出，请考虑使用 FadeInImage 小部件，该小部件使用 GPU 的片段着色器应用渐变不透明度。
>
> - 很多场景下，我们确实没必要直接使用 Opacity 改变透明度，如要作用于一个图片的时候可以直接使用透明的图片，或者直接使用 Container：Container(color: Color.fromRGBO(255, 0, 0, 0.5))
>
> - Clipping 不会调用 saveLayer()（除非明确使用 Clip.antiAliasWithSaveLayer），因此这些操作没有 Opacity 那么耗时，但仍然很耗时，所以请谨慎使用。
>
> - 要创建带圆角的矩形，而不是应用剪切矩形，请考虑使用很多 widget 都提供的 borderRadius属性

##### 管理着色器编译垃圾

> 有时候，应用中的动画首次运行时会看起来非常卡顿，但是运行多次之后便可以正常运行，这可能就是由于着色器编译混乱导致的。
>
> 在图形渲染，着色器相当于是在 GPU 运行的一组代码。想要达到 60fps，需要在 16 毫秒内绘制一个平滑的帧，但是在编译着色器时，它花费的时间可能比应该花费的时间更多，可能会接近几百毫秒，并且会导致丢失数十个帧，将 fps 从 60 降至 6。
>
> ###### 解决方法:
>
> Flutter 1.20 之后，Flutter 为开发者提供了非常方便的一组命令行工具，由此开发人员可以使用 Skia Shader Language 格式收集最终用户可能需要的着色器， 一旦将 SkSL 着色器打包到应用程序中，当用户打开应用程序时，就会自动进行预编译。
>
> 运行应用，添加 --cache-sksl 参数捕获 SkSL 中的着色器：
>
> ```
> flutter run --profile --cache-sksl
> ```
>
> 如果该应用已经运行，且没有带有 --cache-sksl 参数，则还需要 --purge-persistent-cache：
>
> ```
> flutter run --profile --cache-sksl --purge-persistent-cache
> ```
>
> 该参数可能会删除 SkSL 着色器捕获的较旧的非 SkSL着色器缓存，因此只能在第一次运行时使用 --cache-sksl。

```
# 在不同平台上，可以执行以下命令，使用 SkSL 预热功能构建应用程序：
# 安卓
flutter build apk — bundle-sksl-path flutter_01.sksl.json

#ios
flutter build ios --bundle-sksl-path flutter_01.sksl.json
```



## 应用混淆

参考: https://mp.weixin.qq.com/s/cg-mjpBIcelTGZSOzMWwhw