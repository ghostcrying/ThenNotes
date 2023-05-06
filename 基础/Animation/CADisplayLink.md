# CADisplayLink

### Source Code

```
open class CADisplayLink : NSObject {

    
    /* Create a new display link object for the main display. It will
     * invoke the method called 'sel' on 'target', the method has the
     * signature '(void)selector:(CADisplayLink *)sender'. */
     
    public /*not inherited*/ init(target: Any, selector sel: Selector)

   
    /* 定时器只有在Runloop中才可以运行
     * Adds the receiver to the given run-loop and mode. Unless paused, it
     * will fire every vsync until removed. Each object may only be added
     * to a single run-loop, but it may be added in multiple modes at once.
     * While added to a run-loop it will implicitly be retained. */
    
    open func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)

    
    /* 从loop中移除该定时器, 若是最后一个Mode, 则loop释放
     * Removes the receiver from the given mode of the runloop. This will
     * implicitly release it when removed from the last mode it has been
     * registered for. */
    
    open func remove(from runloop: RunLoop, forMode mode: RunLoop.Mode)

    
    /* Removes the object from all runloop modes (releasing the receiver if
     * it has been implicitly retained) and releases the 'target' object. */
    
    open func invalidate()

    
    /* 当前时间戳
     * The current time, and duration of the display frame associated with
     * the most recent target invocation. Time is represented using the
     * normal Core Animation conventions, i.e. Mach host time converted to
     * seconds. */
    
    open var timestamp: CFTimeInterval { get }
    /// 距离上次执行的时间间隔
    open var duration: CFTimeInterval { get }

    
    /* 预计下次执行的时间戳. */
    
    @available(iOS 10.0, *)
    open var targetTimestamp: CFTimeInterval { get }

    
    /* When true the object is prevented from firing. Initial state is
     * false. */
    
    open var isPaused: Bool

    
    /* Defines how many display frames must pass between each time the
     * display link fires. Default value is one, which means the display
     * link will fire for every display frame. Setting the interval to two
     * will cause the display link to fire every other display frame, and
     * so on. The behavior when using values less than one is undefined.
     * DEPRECATED - use preferredFramesPerSecond. */
    
    @available(iOS, introduced: 3.1, deprecated: 10.0, message: "preferredFramesPerSecond")
    open var frameInterval: Int

    
    /* 每秒执行帧数, 例如1, 则1s执行一次
     * Defines the desired callback rate in frames-per-second for this display
     * link. If set to zero, the default value, the display link will fire at the
     * native cadence of the display hardware. The display link will make a
     * best-effort attempt at issuing callbacks at the requested rate. */
    
    @available(iOS, introduced: 10.0, deprecated: 100000)
    open var preferredFramesPerSecond: Int

    
    /* Defines the range of desired callback rate in frames-per-second for this
       display link. If the range contains the same minimum and maximum frame rate,
       this property is identical as preferredFramesPerSecond. Otherwise, the actual
       callback rate will be dynamically adjusted to better align with other
       animation sources. */
    
    @available(iOS 15.0, *)
    open var preferredFrameRateRange: CAFrameRateRange
}
```

### Explain

#### timestamp 时间戳

这个属性用来返回上一次屏幕刷新的时间戳.如果视频播放的应用,可以通过时间戳来获取上一帧的具体时间,来计算下一帧.

#### duration属性

- duration属性提供了每帧之间的时间，也就是屏幕每次刷新之间的的时间。我们可以使用这个时间来计算出下一帧要显示的UI的数值。但是 duration只是个大概的时间，如果CPU忙于其它计算，就没法保证以相同的频率执行屏幕的绘制操作，这样会跳过几次调用回调方法的机会。

#### frameInterval属性

- frameInterval属性是可读可写的NSInteger型值，标识间隔多少帧调用一次selector 方法，默认值是1，即每帧都调用一次。如果每帧都调用一次的话，对于iOS设备来说那刷新频率就是60HZ也就是每秒60次，如果将 frameInterval 设为2 那么就会两帧调用一次，也就是变成了每秒刷新30次。
- 我们通过pause属性开控制CADisplayLink的运行。当我们想结束一个CADisplayLink的时候，应该调用-(void)invalidate
- 从runloop中删除并删除之前绑定的 target跟selector
- 另外CADisplayLink 不能被继承。

#### 修改帧率

如果在特定帧率内无法提供对象的操作,可以通过降低帧率解决.一个拥有持续稳定但是较慢帧率的应用要比跳帧的应用顺滑的多.
可以通过preferredFramesPerSecond来设置每秒刷新次数.preferredFramesPerSecond默认值为屏幕最大帧率(maximumFramesPerSecond),目前是60.
实际的屏幕帧率会和preferredFramesPerSecond有一定的出入,结果是由设置的值和屏幕最大帧率(maximumFramesPerSecond)相互影响产生的.规则大概如下:

如果屏幕最大帧率(preferredFramesPerSecond)是60,实际帧率只能是15, 20, 30, 60中的一种.如果设置大于60的值,屏幕实际帧率为60.如果设置的是26~35之间的值,实际帧率是30.如果设置为0,会使用最高帧率.

#### CADisplayLink 与 NSTimer 有什么不同

- iOS设备的屏幕刷新频率是固定的，CADisplayLink在正常情况下会在每次刷新结束都被调用，精确度相当高。
- NSTimer的精确度就显得低了点，比如NSTimer的触发时间到的时候，runloop如果在阻塞状态，触发时间就会推迟到下一个runloop周期。并且 NSTimer新增了tolerance属性，让用户可以设置可以容忍的触发的时间的延迟范围。
- CADisplayLink使用场合相对专一，适合做UI的不停重绘，比如自定义动画引擎或者视频播放的渲染。NSTimer的使用范围要广泛的多，各种需要单次或者循环定时处理的任务都可以使用。在UI相关的动画或者显示内容使用 CADisplayLink比起用NSTimer的好处就是我们不需要在格外关心屏幕的刷新频率了，因为它本身就是跟屏幕刷新同步的。

> 通常来讲：iOS设备的刷新频率事60HZ也就是每秒60次。那么每一次刷新的时间就是1/60秒 大概16.7毫秒。当我们的frameInterval值为1的时候我们需要保证的是 CADisplayLink调用的｀target｀的函数计算时间不应该大于 16.7否则就会出现严重的丢帧现象。



### Example

```swift
func initlink() {
    link = CADisplayLink(target: self, selector: #selector(linkMethod))
    link.add(to: RunLoop.current, forMode: .common)
}

@objc func linkMethod() {
    animateBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 240).concatenating(animateBtn.transform)
}
```



