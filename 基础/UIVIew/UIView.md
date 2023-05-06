## UIView

### Super

- addSubview:
  - 添加一个子视图到接收者并让它在最上面显示出来。
  
- bringSubviewToFront:
  - 把指定的子视图移动到顶层
  
- convertPoint:fromView:
  - 把一个点从一个坐标系转换到接收者的坐标系
  
- convertPoint:toView:
  - 转换一个点从接收者坐标系到给定的视图坐标系
  
- convertRect:fromView:
  - 转换一个矩形从其他视图坐标系到接收者坐标系。
  
- convertRect:toView:
  - 转换接收者坐标系中的矩形到其他视图
  
- drawRect:
  - 绘制
  
- sizeToFit
  
  - sizeToFit会自动调用sizeThatFits方法；
  - sizeToFit不应该在子类中被重写，应该重写sizeThatFits
  - sizeToFit可以被手动直接调用
  - sizeToFit和sizeThatFits方法都没有递归，对subviews也不负责，只负责自己
  
- sizeThatFits

  - sizeThatFits传入的参数是receiver当前的size，返回一个适合的size

  ```
  override func sizeToFit() {
  ​    var bound = self.frame
  ​    bound.size = self.sizeThatFits(bound.size)
  ​    self.frame = curSize
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
  ​    var bound = self.bounds
  ​    ...
  ​    return bound.size
  }
  ```

  

- exchangeSubviewAtIndex:withSubviewAtIndex:
  - 交换接收者的子视图和给定的索引视图

- hitTest:withEvent:
  - 返回接收者视图层次中最远的派生（包括它本身）的特定的点。
  - 这个方法贯穿视图的层次发送pointInside:withEvent: 消息到每一个子视图用来决定那个子视图需要接收触摸事件。如果pointInside:withEvent: 返回YES，那么视图的层次全部贯穿；否则视图层次的分支是被否定的。你不太需要调用这个方法，但是你需要重写它用来隐藏子视图的触摸事件。
    如果视图是隐藏的，禁止用户交互的或者透明值小于0.01那么这个方法不可用

- awakeFromNib
  - 从xib或者storyboard加载完毕就会调用

- initWithCoder：
  - 使用文件加载的对象调用（如从xib或stroyboard中创建）
  - 只要对象是从文件解析来的，就会调用
  - 如果awakeFromNib与initWithCoder同时存在，会先调用initWithCoder

- initWithFrame:
  - 使用代码加载的对象调用（使用纯代码创建）
  - 初始化并返回一个新的拥有特定帧矩形的视图对象

- insertSubview:aboveSubview:
  - 在视图层次顶层插入一个视图

- insertSubview:atIndex:
  - 插入视图到指定的索引

- insertSubview:belowSubview:
  - 插入视图到显示链的底层

- isDescendantOfView:
  - 返回一个布尔值指出接收者是否是给定视图的子视图或者指向那个视图

- layoutIfNeeded
  - 排列子视图如果需要的话

- layoutSubviews
  - 排列子视图

- pointInside:withEvent:
  - 返回一个布尔值指出接收者是否包含特定的点

- removeFromSuperview
  - 把接收者从它的父视图或者窗口移除，并在响应链中移除。

- sendSubviewToBack:
  - 移动指定的子视图到它相邻视图的後面

- setNeedsDisplay
  - 控制接收者的边界矩形被标记为需要显示
  - 主动触发drawRect:

- setNeedsDisplayInRect:
  - 标记接收者中的特定的矩形区域为需要显示，或者添加接收者现有的其他无效区域

- setNeedsLayout
  - 设置当子视图显示的时候需要重新排列

- viewWithTag:
  - 返回视图的特定的标签



### 初始化

> 所以为了同时兼顾从文件和从代码解析的对象初始化，要同时在initWithCoder: 和 initWithFrame: 中进行初始化



### setNeedsDisplay

> 异步执行, 自动调用draw(_ rect)
>
> 方便处理动画

##### draw(_ rect)调用时机

> 1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect调用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的. 所以不用担心在控制器中, 这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
>
> 2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。
>
> 3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。
>
> 4、直接调用setNeedsDisplay在下一周期触发，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。
>
> * 以上1,2推荐；而3,4不提倡

##### draw(_ rect)调用事项

> 1、若使用UIView绘图，只能在drawRect：方法中获取相应的contextRef并绘图。如果在其他方法中获取将获取到一个invalidate的ref并且不能用于画图。drawRect：方法不能手动显示调用，必须通过调用setNeedsDisplay 或者 setNeedsDisplayInRect，让系统自动调该方法。
>
> 2、若使用calayer绘图，只能在drawInContext: 中（类似于drawRect）绘制，或者在delegate中的相应方法绘制。同样也是调用setNeedDisplay等间接调用以上方法
>
> 3、若要实时画图，不能使用gestureRecognizer，只能使用touchbegan等方法来掉用setNeedsDisplay实时刷新屏幕



### layoutIfNeeded

> 使用约束的时候, 调用可以立即更新效果， 它会从当前视图开始, 一直到完成所有子视图的布局, 不会触发layoutSubviews()



### setNeedsLayout

> 异步执行, 自动调用layoutSubViews, 但并不会立即更新约束效果（下一个布局周期才会触发更新）
>
> 方便处理视图

##### layoutSubviews调用时机

> 1、init初始化不会触发layoutSubviews。
>
> 2、addSubview会触发layoutSubviews。
>
> 3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。
>
> 4、滚动一个UIScrollView会触发layoutSubviews。
>
> 5、旋转Screen会触发父UIView上的layoutSubviews事件。
>
> 6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。
>
> 7、直接调用setLayoutSubviews



```
class Root: UIView {
    
    /** 所有视图的outlet和action都已经连接,但还未确定.
     *  可以进行无法在xib或者storyboard无法执行的设置
     *  例如: xib创建的UI的属性, 可以在这里进行重新设定
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#function)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print(#function)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(#function)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("Delay 02s, layoutIfNeeded ----")
            self.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
            print("Delay 04s, setNeedsLayout ----")
            self.setNeedsLayout()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
            print("Delay 06s, setNeedsDisplay ----")
            self.setNeedsDisplay()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8) {
            print("Delay 08s, setNeedsFocusUpdate ----")
            self.setNeedsFocusUpdate()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
            print("Delay 10s, layoutSubviews")
            self.layoutSubviews()
        }
    }
    /** 1. 直接调用setNeedsLayout()（这个在上面苹果官方文档里有说明）
     *  2. addSubview的时候。
     *  3. 当view的size发生改变的时候，前提是frame的值设置前后发生了变化。
     *  4. 滑动UIScrollView的时候。
     *  5. 旋转屏幕的会触发父UIView的layoutSubviews(没有验证成功)
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
    }
    // 绘制: 当视图初始化或者调用setNeedsDisplay()(下一周期)时, 触发
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print(#function)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
}

let view = Root(frame: CGRect(x: 0, y: 0, width: widths, height: height))
print("init view")
PlaygroundPage.current.liveView = view
print("add view")
```













