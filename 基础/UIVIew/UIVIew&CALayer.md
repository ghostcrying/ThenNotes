# CALayer



#### UIView&CALayer

```
open class UIVIew: UIResponder, CALayerDelegate {
    open var layer: CALayer { get }
}

open class CALayer: NSObject {
    public init()
    public init(layer: Any)
    
    open var bounds: CGRect
    open var position: CGPoint
    open var anchorPoint: CGPoint
    open var transform: CATransform3D
    
    /* An object providing the contents of the layer, typically a CGImageRef,
     * but may be something else. (For example, NSImage objects are
     * supported on Mac OS X 10.6 and later.) Default value is nil.
     * Animatable. */
    /** Layer content properties and methods. **/
    open var contents: Any?
}
```

> - `UIView`都是有一个底层的`CALayer`驱动, 保持着紧密联系
>   - `UIView`直接从`layer`中获取绝大多数它需要的属性, `CALayer`侧重于图形的显示, `UIView`相当于`CALayer`的管理者, `UIView`遵循`CALayerDelegate`
> - 在创建`UIVIew`对象时,  `UIVIew`内部会创建一个图层(`CALayer`对象), 而当`UIVIew`对象需要显示道屏幕上时, 会调用 `drawRect:`进行绘制, 然后把内容绘制到图层上, 绘制完毕系统会将图层展示在屏幕上.
> - 总的来说, `UIVIew`并不具备显示功能, 是它内部的层来完成显示工作, 但`UIVIew`有响应事件功能



##### 响应事件

`UIView`继承于`UIResponse`, `CALayer`继承于`NSObject`, 因此`UIVIew`可以参与响应链响应事件, `CALayer`不可以.

##### 初始化

`CALayer`的`frame`由`anchorPoint`、`position`、`bounds`、`transform`共同决定, 但是`UIView`的`frame`只是单纯的返回`CALayer`的`frame`, `UIView`的`center`和`bounds`只是单纯的返回`CALayer`对应的`position`和`bounds`

##### 内容管理和绘制

`UIView`主要是针对显示内容的管理, `CALayer`主要是对内容的绘制

##### 隐式动画

每个`UIVIew`都有一个`layer`，但是也有一些不依附`UIView`单独存在的`layer`，如`CAShapelayer`不需要附加到`UIView`上就可以在屏幕上显示内容

`CALayer`的属性改变都会触发隐式动画, 但改变`UIView`的`layer`属性时隐式动画不起作用.

> 解析: `UIView`默认禁止`CALayer`动画, 但可以在`animation block`中启用, 是因`UIView`的任何可动画的`layer`属性改变时, `layer`都会查找并运行合适的`CAAction`实行这个改变
>
> - `layer`通过`delegate的action(for layer: CALayer, forKey event: String)`来查找对应改变的action(三种方式)
> - 返回动作对象, 直接使用
> - 返回nil, layer继续查找
> - 返回NSNull, 通知`layer`此处不需要动作, `layer`停止查找.



#### 应用

- `CALayer`修改视图的阴影, 边框, 圆角...
- `UIImageView`添加圆角边框时, 效果实现了, 但是未进行切割, 只有设置`layer.masksToBounds = true`才进行切割, 但是`UIVIew`的设置并不需要该属性
  - 区别在于设置对`UIVIew`设置圆角作用在`layer`层, `image`展示是以`CGImage`的形式存储在`layer.contents`属性上, `layer.maskstoBounds = true`是为了去除`UIView`的根层边界外的内容.
- shouldRasterize
  - 光栅栏: 将图转化为一个个栅格组成的图象
    - 特点: 每个元素对应帧缓冲区中的一像素
    - 优势: `shouldRasterize = true`在其他属性触发离屏渲染的同时，会将光栅化后的内容缓存起来，如果对应的layer及其sublayers没有发生改变，在下一帧的时候可以直接复用。shouldRasterize = true，这将隐式的创建一个位图，各种阴影遮罩等效果也会保存到位图中并缓存起来，从而减少渲染的频度（不是矢量图）
    - 对于经常变动的内容, 这个属性不要开启, 否则会造成性能的浪费
  - 当`shouldRasterize = true`时, `layer`被渲染成一个`bitmap`并缓存起来, 等下次使用时不会再重新去渲染了.
    - 实现圆角本身就是在做颜色混合(`blending`), 如果每次页面出来时都`blending`消耗太大. 这时`shouldRasterize = true`, 下次就只是简单的从渲染引擎的`cache`里读取那张`bitmap`节约系统资源.
- `UIView`与`CALayer`的选择
  - `CALayer`是定义在`QuartzCore`框架中的, `CGImageRef`,`CGColorRef`这两种数据类型是定义在`CoreGraphics`框架中的, 而`UIImage`和`UIColor`是定义在UIKit框架的
  - `QuartzCore`框架和`CoreGraphics`框架是可以跨平台使用的, 在IOS和Mac OS X上都可以使用，但是UIKit只能在IOS中使用
  - `CALayer`可以做出跟UIView一样的效果, 但是由于`UIVIew`继承于`UIResponder`, 可以处理事件的响应, 而`CALayer`不可以

 - 为什么不直接使用`CALayer+UIVIew`合并呢
   - 解耦合
   - 业务分离

#### 总结

> - 每个UIView内部都有一个CALayer提供内容的绘制和显示, 并且UIView的尺寸样式都由内部的CALayer提供, 两者内部都有树状层级结构, layer内部有sublayers, UIView内部有subviews, 但是CALayer比UIView多一个anchorPoint(锚点)
> - 在UIView显示时, UIView作为CALayer的CALayerDelegate, UIView的现实内容取决于内部的CALayer的display.
> - CALayer是默认修改属性支持隐式动画的, 在给UIView的Layer做动画的时候, View作为layer的代理, layer通过actionForLayer:forKey: 向View请求相应的action（动画行为)
> - CALayer内部维护者三份CALayer Tree, 在动画的时候我们修改动画的属性其实是修改presentLayer的属性值, 而最终展示在界面上的其实是提供UIView的modelLayer
>   - presentLayer Tree(动画树)
>   - modelLayer Tree(模型树)
>   - Render Tree(渲染树)
> - 最明显区别: UIView可响应事件, CALayer不可以.



#### 渲染

**GPU渲染机制：**

CPU 计算好显示内容提交到 GPU，GPU 渲染完成后将渲染结果放入帧缓冲区，随后视频控制器会按照 VSync 信号逐行读取帧缓冲区的数据，经过可能的数模转换传递给显示器显示。

##### 方式

- On-Screen Rendering
  - 意为当前屏幕渲染，指的是GPU的渲染操作是在当前用于显示的屏幕缓冲区中进行。

- Off-Screen Rendering

  - 意为离屏渲染，指的是GPU在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作。

  - 离屏渲染触发

    - shouldRasterize（光栅化）

    - masks（遮罩）

    - shadows（阴影）

    - edge antialiasing（抗锯齿）

    - group opacity（不透明）

    - 复杂形状设置圆角等

    - 渐变

##### 使用

当使用圆角，阴影，遮罩的时候，图层属性的混合体被指定为在未预合成之前不能直接在屏幕中绘制，所以就需要屏幕外渲染被唤起。

屏幕外渲染并不意味着软件绘制，但是它意味着图层必须在被显示之前在一个屏幕外上下文中被渲染（不论CPU还是GPU）。

所以当使用离屏渲染的时候会很容易造成性能消耗，因为在OPENGL里离屏渲染会单独在内存中创建一个屏幕外缓冲区并进行渲染，而屏幕外缓冲区跟当前屏幕缓冲区上下文切换是很耗性能的。
