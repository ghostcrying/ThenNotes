

## Widget



## 状态

##### StatelessWidget

> 用于不需要维护状态的场景

##### StatefulWidget

> 用于维护状态场景
>
> - createState()用于创建和 StatefulWidget 相关的状态State

##### State

> 一个 StatefulWidget 类会对应一个 State 类，State表示与其对应的 StatefulWidget 要维护的状态，State 中的保存的状态信息可以：
>
> 1. 在 widget 构建时可以被同步读取。
> 2. 在 widget 生命周期中可以被改变，当State被改变时，可以手动调用其`setState()`方法通知Flutter 框架状态发生改变，Flutter 框架在收到消息后，会重新调用其`build`方法重新构建 widget 树，从而达到更新UI的目的。
>
> State 中有两个常用属性：
>
> 1. `widget`，它表示与该 State 实例关联的 widget 实例，由Flutter 框架动态设置。注意，这种关联并非永久的，因为在应用生命周期中，UI树上的某一个节点的 widget 实例在重新构建时可能会变化，但State实例只会在第一次插入到树中时被创建，当在重新构建时，如果 widget 被修改了，Flutter 框架会动态设置State. widget 为新的 widget 实例。
> 2. `context`。StatefulWidget对应的 BuildContext，作用同StatelessWidget 的BuildContext。

###### 生命周期

![](https://github.com/HyEnjoys/Skills/blob/main/Assets/Flutter/lifeStyle.png?raw=true)

- initState

  ```
  当 widget 第一次插入到 widget 树时会被调用，对于每一个State对象，Flutter 框架只会调用一次该回调，所以，通常在该回调中做一些一次性的操作，如状态初始化、订阅子树的事件通知等。不能在该回调中调用BuildContext.dependOnInheritedWidgetOfExactType（该方法用于在 widget 树上获取离当前 widget 最近的一个父级InheritedWidget，关于InheritedWidget我们将在后面章节介绍），原因是在初始化完成后， widget 树中的InheritFrom widget也可能会发生变化，所以正确的做法应该在在build（）方法或didChangeDependencies()中调用它
  ```

- didChangeDependencies

  ```
  当State对象的依赖发生变化时会被调用；例如：在之前build() 中包含了一个InheritedWidget （第七章介绍），然后在之后的build() 中Inherited widget发生了变化，那么此时InheritedWidget的子 widget 的didChangeDependencies()回调都会被调用。典型的场景是当系统语言 Locale 或应用主题改变时，Flutter 框架会通知 widget 调用此回调。需要注意，组件第一次被创建后挂载的时候（包括重创建）对应的didChangeDependencies也会被调用
  ```

- build

  ```
  它主要是用于构建 widget 子树的, 调用场景:
  1. 在调用initState()之后。
  2. 在调用didUpdateWidget()之后。
  3. 在调用setState()之后。
  4. 在调用didChangeDependencies()之后。
  5. 在State对象从树中一个位置移除后（会调用deactivate）又重新插入到树的其它位置之后
  ```

- reassemble

  ```
  此回调是专门为了开发调试而提供的，在热重载(hot reload)时会被调用，此回调在Release模式下永远不会被调用
  ```

- didUpdateWidget

  ```
  在 widget 重新构建时，Flutter 框架会调用widget.canUpdate来检测 widget 树中同一位置的新旧节点，然后决定是否需要更新，如果widget.canUpdate返回true则会调用此回调。正如之前所述，widget.canUpdate会在新旧 widget 的 key 和 runtimeType 同时相等时会返回true，也就是说在在新旧 widget 的key和runtimeType同时相等时didUpdateWidget()就会被调用
  ```

- deactivate

  ```
  当 State 对象从树中被移除时，会调用此回调。在一些场景下，Flutter 框架会将 State 对象重新插到树中，如包含此 State 对象的子树在树的一个位置移动到另一个位置时（可以通过GlobalKey 来实现）。如果移除后没有重新插入到树中则紧接着会调用dispose()方法
  ```

- dispose

  ```
  当 State 对象从树中被永久移除时调用；通常在此回调中释放资源
  ```

![2-5.a59bef97.jpg](https://book.flutterchina.club/assets/img/2-5.a59bef97.jpg)

## 约束

```
BoxConstraints
- BoxConstraints 是盒模型布局过程中父渲染对象传递给子渲染对象的约束信息，包含最大宽高信息，子组件大小需要在约束的范围内
  const BoxConstraints({
    this.minWidth = 0.0, // 最小宽度
    this.maxWidth = double.infinity, // 最大宽度
    this.minHeight = 0.0, // 最小高度
    this.maxHeight = double.infinity // 最大高度
  })

ConstrainedBox
- ConstrainedBox用于对子组件添加额外的约束。例如，如果你想让子组件的最小高度是80像素，你可以使用const BoxConstraints(minHeight: 80.0)作为子组件的约束
  ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: double.infinity, //宽度尽可能大
      minHeight: 50.0 //最小高度为50像素
    ),
    child: Container(
      height: 5.0, // 这个子Widget的5像素高度被ConstrainedBox的minHeight修改了
      child: redBox ,
    ),
  )

SizedBox
- 用于给子元素指定固定的宽高

ConstrainedBox多重限制
- 对于minWidth和minHeight来说，是取父子中相应数值较大的。实际上，只有这样才能保证父限制与子限制不冲突
```



## 布局

##### 线性布局

```
Row
- 横向布局
Column
- 纵向布局
```

##### 弹性布局

```
Flex
- Flex组件可以沿着水平或垂直方向排列子组件，如果你知道主轴方向，使用Row或Column会方便一些，因为Row和Column都继承自Flex，参数基本相同，所以能使用Flex的地方基本上都可以使用Row或Column。Flex本身功能是很强大的，它也可以和Expanded组件配合实现弹性布局

Expanded
- Expanded 只能作为 Flex 的孩子（否则会报错），它可以按比例“扩伸”Flex子组件所占用的空间。因为 Row和Column 都继承自 Flex，所以 Expanded 也可以作为它们的孩子
- flex参数为弹性系数，如果为 0 或null，则child是没有弹性的
Example:
  Flex(
    direction: Axis.horizontal,
    children: <Widget>[
      Expanded(
        flex: 1, // 一倍
        child: Container(
          height: 30.0,
          color: Colors.red,
        ),
      ),
      Expanded(
        flex: 2, // 两倍
        child: Container(
          height: 30.0,
          color: Colors.green,
        ),
      ),
    ],
  ),
```



##### 流式布局

```
Wrap
- spacing：主轴方向子widget的间距
- runSpacing：纵轴方向的间距
- runAlignment：纵轴方向的对齐方式
- Exmaple:
  Wrap(
     spacing: 8.0, // 主轴(水平)方向间距
     runSpacing: 4.0, // 纵轴（垂直）方向间距
     alignment: WrapAlignment.center, //沿主轴方向居中
     children: <Widget>[
       Chip(
         avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('A')),
         label: Text('Hamilton'),
       ),
       Chip(
         avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('M')),
         label: Text('Lafayette'),
       ),
       Chip(
         avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('H')),
         label: Text('Mulligan'),
       ),
       Chip(
         avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('J')),
         label: Text('Laurens'),
       ),
     ],
  )

Flow
- 暂未使用
```



##### 层叠布局

```
Stack\Positioned
- Stack允许子组件堆叠，而Positioned用于根据Stack的四个角来确定子组件的位置
```

##### 对齐与相对定位

```
Align
- alignment : 需要一个AlignmentGeometry类型的值，表示子组件在父组件中的起始位置。AlignmentGeometry 是一个抽象类，它有两个常用的子类：Alignment和 FractionalOffset，我们将在下面的示例中详细介绍。
- widthFactor和heightFactor是用于确定Align 组件本身宽高的属性；它们是两个缩放因子，会分别乘以子元素的宽、高，最终的结果就是Align 组件的宽高。如果值为null，则组件的宽高将会占用尽可能多的空间
Center
- Center继承自Align，它比Align只少了一个alignment 参数；由于Align的构造函数中alignment 值为Alignment.center，所以，我们可以认为Center组件其实是对齐方式确定（Alignment.center）了的Align
```

##### layout



## 填充

> ##### 通用: Container / Padding / DecoratedBox /

##### Clip

```
裁剪
ClipOval	子组件为正方形时剪裁成内贴圆形；为矩形时，剪裁成内贴椭圆
ClipRRect	将子组件剪裁为圆角矩形
ClipRect	默认剪裁掉子组件布局空间之外的绘制内容（溢出部分剪裁）
ClipPath	按照自定义的路径剪裁
```

##### 变换

```
平移
DecoratedBox(
  decoration: BoxDecoration(color: Colors.red),
  //默认原点为左上角，左移20像素，向上平移5像素  
  child: Transform.translate(
    offset: Offset(-20.0, -5.0),
    child: Text("Hello world"),
  ),
)
旋转
DecoratedBox(
  decoration: BoxDecoration(color: Colors.red),
  child: Transform.rotate(
    //旋转90度
    angle:math.pi/2 ,
    child: Text("Hello world"),
  ),
)
缩放
DecoratedBox(
  decoration:BoxDecoration(color: Colors.red),
  child: Transform.scale(
    scale: 1.5, //放大到1.5倍
    child: Text("Hello world")
  )
);

RotatedBox
- RotatedBox和Transform.rotate功能相似，它们都可以对子组件进行旋转变换，但是有一点不同：RotatedBox的变换是在layout阶段，会影响在子组件的位置和大小
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    DecoratedBox(
      decoration: BoxDecoration(color: Colors.red),
      //将Transform.rotate换成RotatedBox  
      child: RotatedBox(
        quarterTurns: 1, //旋转90度(1/4圈)
        child: Text("Hello world"),
      ),
    ),
    Text("你好", style: TextStyle(color: Colors.green, fontSize: 18.0),)
  ],
),
由于RotatedBox是作用于layout阶段，所以子组件会旋转90度（而不只是绘制的内容），decoration会作用到子组件所占用的实际空间上
```



## 滚动

- shrinkWrap

  ```
  ListView继承自ScrollView, 拿ListView举例：
  shrinkWrap默认为false
  如果滚动视图设置的是false,那么内容会在滚动方向上尺寸延伸到最大，如果在滚动方向上没有边界约束，那么shrinkWrap必须设置为true
  ```



#### 基础滚动

```
Sliver: 按需加载列表布局
- 只有当 Sliver 出现在视口中时才会去构建它，这种模型也称为“基于Sliver的列表按需加载模型”。可滚动组件中有很多都支持基于Sliver的按需加载模型，如ListView、GridView，但是也有不支持该模型的，如SingleChildScrollView

Scrollable
- 用于处理滑动手势，确定滑动偏移，滑动偏移变化时构建 Viewport

Scrollbar
- 可以主动控制滚动条显示

SingleChildScrollView (单独拉出来讲)
- 通常SingleChildScrollView只应在期望的内容不会超过屏幕太多时使用，这是因为SingleChildScrollView不支持基于 Sliver 的延迟加载模型，所以如果预计视口可能包含超出屏幕尺寸太多的内容时，那么使用SingleChildScrollView将会非常昂贵（性能差），此时应该使用一些支持Sliver延迟加载的可滚动组件，如ListView
- offset：可滚动组件当前的滚动位置。
- jumpTo(double offset)、animateTo(double offset,...)：这两个方法用于跳转到指定的位置，它们不同之处在于，后者在跳转时会执行一个动画，而前者不会
- 监听: 
  ScrollController _controller = ScrollController();
  _controller.addListener(() {
    print(_controller.offset); // 打印滚动位置
  });
- 滚动位置恢复
  - 当一个路由中包含多个可滚动组件时，如果你发现在进行一些跳转或切换操作后，滚动位置不能正确恢复，这时你可以通过显式指定PageStorageKey来分别跟踪不同的可滚动组件的位置(不同的PageStorageKey，需要不同的值，这样才可以为不同可滚动组件保存其滚动位置)
  ListView(key: PageStorageKey(1), ... );
  - Example: 一个典型的场景是在使用TabBarView时，在Tab发生切换时，Tab页中的可滚动组件的State就会销毁，这时如果想恢复滚动位置就需要指定PageStorageKey
- ScrollPosition  
  - 保存可滚动组件的滚动位置的。一个ScrollController对象可以同时被多个可滚动组件使用，ScrollController会为每一个可滚动组件创建一个ScrollPosition对象，这些ScrollPosition保存在ScrollController的positions属性中（List<ScrollPosition>）。ScrollPosition是真正保存滑动位置信息的对象，offset只是一个便捷属性
  - 一个ScrollController虽然可以对应多个可滚动组件，但是有一些操作，如读取滚动位置offset，则需要一对一！但是我们仍然可以在一对多的情况下，通过其它方法读取滚动位置，举个例子，假设一个ScrollController同时被两个可滚动组件使用(controller.positions.elementAt(0).pixels)
    - 我们可以通过controller.positions.length来确定controller被几个可滚动组件使用
```



#### 集成滚动

```
ListView
- 横/纵向滚动: scrollDirection: Axis.horizontal
- ListView.builder
  - 按需动态构建
- ListView.separated
  - 比着builder多了一条分割线

AnimatedList
- AnimatedList 和 ListView 的功能大体相似，不同的是， AnimatedList 可以在列表中插入或删除节点时执行一个动画，在需要添加或删除列表项的场景中会提高用户体验
- StatefulWidget

GridView
- 二维网格视图
- GridView
  - 默认构造
  GridView(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,     // 横轴三个子widget
        childAspectRatio: 1.0, // 宽高比为1时，子widget
        mainAxisSpacing: 1.0,  // 主轴方向的间距
        crossAxisSpacing: 1.0, // 横轴方向子元素的间距
    ),
    children:<Widget>[
      Icon(Icons.ac_unit),
      Icon(Icons.airport_shuttle),
      Icon(Icons.all_inclusive),
      Icon(Icons.beach_access),
      Icon(Icons.cake),
      Icon(Icons.free_breakfast)
    ]
  );
- GridView.count
  - 横项固定crossAxisCount个数, 纵向布局.
  GridView.count(
    crossAxisCount: 3,
    childAspectRatio: 1.0,
    children: <Widget>[
      Icon(Icons.ac_unit),
      Icon(Icons.airport_shuttle),
      Icon(Icons.all_inclusive),
      Icon(Icons.beach_access),
      Icon(Icons.cake),
      Icon(Icons.free_breakfast),
    ],
  ),
- GridView.extent
  - 纵轴子元素固定最大长度maxCrossAxisExtent
  GridView.extent(
    maxCrossAxisExtent: 50.0,
    childAspectRatio: 2.0,
    children: <Widget>[
      Icon(Icons.ac_unit),
      Icon(Icons.airport_shuttle),
      Icon(Icons.all_inclusive),
      Icon(Icons.beach_access),
      Icon(Icons.cake),
      Icon(Icons.free_breakfast),
    ],
  ),
- GridView.builder
  - 适用于子元素多, 按需动态构建
  GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,     // 每行三列
      childAspectRatio: 1.0, // 显示区域宽高相等
    ),
    itemCount: 100,
    itemBuilder: (context, index) {
      return Icon(Icons.ac_unit);
    },
  )
  
PageView
- scrollDirection // 滑动方向
- pageSnapping // 每次滑动是否强制切换整个页面，如果为false，则会根据实际的滑动距离显示页面
- allowImplicitScrolling // 主要是配合辅助功能用的，测试只能缓存一页UI
- padEnds

缓存KeepAlive
- AutomaticKeepAlive
  - 按需自动标记
  - 重写: @override bool get wantKeepAlive => true; // 是否需要缓存

TabBarView
- 
```

###### 缓存封装

```
keepAlive:
- true:  后会缓存所有的列表项，列表项将不会销毁。
- false: 列表项滑出预加载区域后将会别销毁。
- 使用时一定要注意是否必要，因为对所有列表项都缓存的会导致更多的内存消耗
/// 通过KeepAliveWrapper包裹ChildWidget进行是否alive标记
class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    Key? key,
    this.keepAlive = true,
    required this.child,
  }) : super(key: key);
  final bool keepAlive;
  final Widget child;

  @override
  _KeepAliveWrapperState createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if(oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
```



#### 自定义滚动

```
CustomScrollView
- CustomScrollView 的主要功能是提供一个公共的的 Scrollable 和 Viewport，来组合多个 Sliver
  Widget buildTwoSliverList() {
    // SliverFixedExtentList 是一个 Sliver，它可以生成高度相同的列表项。
    // 再次提醒，如果列表项高度相同，我们应该优先使用SliverFixedExtentList 
    // 和 SliverPrototypeExtentList，如果不同，使用 SliverList.
    var listView = SliverFixedExtentList(
      itemExtent: 56, //列表项高度固定
      delegate: SliverChildBuilderDelegate(
        (_, index) => ListTile(title: Text('$index')),
        childCount: 10,
      ),
    );
    // 使用
    return CustomScrollView(
      slivers: [
        listView,
        listView,
      ],
    );
  }
常用Sliver  
- SliverList(ListView)
- SliverFixedExtentList(ListView: 指定itemExtent时)
- SliverAnimatedList(AnimatedList)
- SliverGrid(GridView)
- SliverPrototypeExtentList(ListView)
- SliverFillViewport(PageView)

SliverToBoxAdapter
- 实际布局中，我们通常需要往 CustomScrollView 中添加一些自定义的组件，而这些组件并非都有 Sliver 版本，为此 Flutter 提供了一个 SliverToBoxAdapter 组件，它是一个适配器：可以将 RenderBox 适配为 Sliver。比如我们想在列表顶部添加一个可以横向滑动的 PageView，可以使用 SliverToBoxAdapter 来配置
```

