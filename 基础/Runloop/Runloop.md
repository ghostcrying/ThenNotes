# Runloop



#### 概念

>  运行循环(do-while循环), 一个Runloop就是用于处理既定工作和接受到外来事件的事件处理循环
>
>  作用:
>
>   - 保持程序的持续运行
>   - 处理APP中各种事件(Timer Touch Selector等事件)
>   - 节省CPU资源 ,提高程序性能. (处理任务时执行, 无任务时释放资源休眠)



##### Main函数

```
int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"开始");
        int re = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        NSLog(@"结束");
        return re;
    }
}
# 运行程序，打印开始，并不会打印结束，说明在UIApplicationMain函数中，开启了一个和主线程相关的RunLoop，导致UIApplicationMain不会返回，一直在运行中，也就保证了程序的持续运行.
```



#### 源码

```
struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;          // locked for accessing mode list，每次读取mode list 要加锁
    __CFPort _wakeUpPort;           // used for CFRunLoopWakeUp
    Boolean _unused;
    volatile _per_run_data *_perRunData; // reset for runs of the run loop
    pthread_t _pthread;                  // 与该runLoop 关联的线程
    uint32_t _winthread;
    CFMutableSetRef _commonModes;        // set 中保存的就是 NSRunLoopCommonModes表示的mode，我们也可以将自定义的mode 添加到这个set 里。
    CFMutableSetRef _commonModeItems;    // 添加到NSRunLoopCommonModes中的source/timer等item 都会被添加到这个set里，这在应用场景一中有打印出来。
    CFRunLoopModeRef _currentMode;       // RunLoop 当前执行的是哪个mode
    CFMutableSetRef _modes;              // 该runLoop 中所有的mode
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFAbsoluteTime _runTime;
    CFAbsoluteTime _sleepTime;
    CFTypeRef _counterpart;
};

# RunLoop 运行模式，只能选择一种，在不同模式中做不同的操作
typedef struct __CFRunLoopMode *CFRunLoopModeRef;
struct __CFRunLoopMode {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;  // must have the run loop locked before locking this
    CFStringRef _name;
    Boolean _stopped;
    char _padding[3];
    CFMutableSetRef _sources0; // 非基于Port: 触摸点击事件，PerformSelectors
    CFMutableSetRef _sources1; // 基于Port
    CFMutableArrayRef _observers; // 监听Runloop状态
    CFMutableArrayRef _timers; // 定时器
    CFMutableDictionaryRef _portToV1SourceMap;
    __CFPortSet _portSet;
    CFIndex _observerMask;
    #if USE_DISPATCH_SOURCE_FOR_TIMERS
    dispatch_source_t _timerSource;
    dispatch_queue_t _queue;
    Boolean _timerFired; // set to true by the source when a timer has fired
    Boolean _dispatchTimerArmed;
    #endif
    #if USE_MK_TIMER_TOO
    mach_port_t _timerPort;
    Boolean _mkTimerArmed;
    #endif
    #if DEPLOYMENT_TARGET_WINDOWS
    DWORD _msgQMask;
    void (*_msgPump)(void);
    #endif
    uint64_t _timerSoftDeadline; // TSR
    uint64_t _timerHardDeadline; // TSR
};

typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};
```

[![RunLoop_0](https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_0.png)](https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_0.png)

##### 概述

> - 一个Runloop包含若干个Mode, 每个Mode包含若干个source timer observe
>    - 每个mode至少包含一个以上source/timer/observe
>    
> - 每次Runloop启动时, 只能指定一个mode, 即currentmode, 切换mode则需要先退出当前loop, 重新指定mode进入
>    - 这是需要分隔开不同组的source/timer/observe, 让其不相互影响
>    
> - 当Runloop中没有任何source/timer/observe时, Runloop就会立即退出
>
> - **mode **(系统默认注册了5个)
>    - kCFRunloopDefaultMode: APP的默认运行模式,通常主线程执行在该模式
>    - UITrackingRunLoopMode: 界面跟踪mode(用户ScrollView追踪触摸滑动, 保持界面滑动时不受其他mode影响)
>    - UIInitializationRunLoopMode: 在刚启动APP时进入的第一个mode, 启动完成后不再使用,会切换到kCFRunLoopDefaultMode下
>    - GSEventReceiveRunloopMode: 接收系统内部事件(一般用不到)
>    - KCFRunLoopCommonModes: 占位模式, 作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用
>    
> - **Source**
>    
>    - source0: 可以理解为正常的输入事件(比如UIButton点击)
>    - source1: 基于port, 通过内核和其他线程通信, 接受/分发系统事件
>    
>    input source/timer source
>    
>    - Port-Based Sources，系统底层的 Port 事件，例如 CFSocketRef ，在应用层基本用不到
>    - Custom Input Sources，用户手动创建的 Source;
>    - Cocoa Perform Selector Sources， Cocoa 提供的 performSelector 系列方法，也是一种事件源;
>    - Timer Source指定时器事件，该事件的优先级是最低的
>    
> - **observe**:
>    - kCFRunLoopEntry = (1UL << 0),                 // 即将进入loop
>    - kCFRunLoopBeforeTimers = (1UL << 1),  // 即将处理Timer
>    - kCFRunLoopBeforeSources = (1UL << 2), // 即将处理Source
>    - kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
>    - kCFRunLoopAfterWaiting = (1UL << 6),    // 即将结束休眠
>    - kCFRunLoopExit = (1UL << 7),                    // 退出loop
>    - kCFRunLoopAllActivities = 0x0FFFFFFFU  // 监听全部状态改变



##### 运行流程

[![RunLoop_1](https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_1.png)](https://blog.ibireme.com/wp-content/uploads/2015/05/RunLoop_1.png)





#### 应用

##### 线程

> - 每一条线程都有一个唯一对应的Runloop对象, Runloop以key-value形式全局保存
> - 主线程默认创建, 子线程需要手动处理
> - Runloop在第一次获取时创建, 线程结束时销毁

##### AutorealeasePool

> App启动后默认注册两个Observer (回调是_wrapWithAutoreleasePoolHandle())
>
> - 监听kCFRunLoopEntry, 内部回调调用`_objc_autoreleasePoolPush()`创建自动释放池子, 优先级最高
> - 第二个Observer: 
>   - 监听kCFRunLoopBeforeWaiting内部回调调用 `_objc_autorelasePoolPop()` 释放旧`_objc_autoreleasePoolPush()` 创建新池;
>   - 监听kCFRunLoopExit内部回调调用`_objc_autoreleasePoolPop()`, 释放自动释放池, 优先级最低, 保证其释放池子发生在其他所有回调之后

##### 事件响应

> - 苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为 __IOHIDEventSystemClientQueueCallback()。
> - 当发生一个硬件事件时，会生成 IOHIDEvent 对象并注册一个source0
>   当Runloop被唤醒后处理 Source0，此时回调 __handleHIDEventFetcherDrain() 再转调 __handleEventQueueInternal() 到 __dispatchPreprocessedEventFromEventQueue，来处理并包装成 UIEvent 进行处理和分发
>
> - _UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的

##### 手势识别

> - 在UIApplicationHandleEventQuene()之后, 识别到手势, 会调用cancel打断touchesBegin/move/ended, 随后系统把对应的UIGestureRecognize标记为待处理
>
> - 在beforeWaiting的Observer回调中,调用_UIGestureRecognzieUpdateObserver(), 内部获取所有待处理的GestureRecognizer, 并执行gesture的回调
>   - 当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理

##### 界面更新

> 当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去
>
> 页面渲染
>
> - 调用uiview.setNeedsDisplay, 会调用view.layer.setNeedsDisplay
>   - 此时给layer标记, 此时并没有开始绘制, 会等待runloop beforeWaiting时开始绘制
> - 调用calayer.display开始绘制
>   - calayer判定CALayerDelegate的displaylayer方法是否实现, 未实现则会继续执行系统绘制流程
>   - 判断是否有CALayerDelegate
>     - 有的
>       - layer.delegate.drawLayer:inContext, 并返回给uiview.drawRect回调, 此处自定义
>     - 没有
>       - 调用calayer.drawInContext:

```
异步绘制
- 就是可以在子线程中把需要绘制的图形提前在子线程处理好.将准备好的图像数据直接返回给主线程使用, 降低主线程压力
- 过程
  - 通过view.delegate.displayLayer:实现异步绘制
  - CALayerDelegate代理负责生成bitmap
  - 设置bitmap为layer.contents的值
```



##### Timer

> - 自身带有触发的容忍度, 也就是可能会被系统修改触发的事件节点, 因此并不准确
> - Timer默认default模式下, 在页面滚动过程中会被系统主动修改mode->UITrackingRunloopMode, 会导致失效.
>   - 可以设定CommonMode(占位模式), 就是给Timer打上UITracking/Default标签
>   - 也可以在子线程中创建于处理Timer时间, 然后回调到主线程执行UI
> - CADisplayLink 是一个和屏幕刷新率一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去（和 NSTimer 相似），造成界面卡顿的感觉

##### PerformSelector

```
- [NSObject performSelector:@selector(...) withObject: afterDelay:]
  - 实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效(就是子线程如果没有runloop会失效)
  - 可以用在当在页面滚动的时候使图片不加载, 滑动结束后开始加载的需求
  - 该方法的Mode默认是Default

- [NSObject performSelector:onThread:]
  - 实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效
  - 可以直接指定线程, 方便些
  - 该方法的Mode默认是Default

- 若是需要滑动也加载
  - [self performSelector:@selector(loadImage) withObject:nil afterDelay:1 inModes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]]
  - 进行占位模式设定
```

##### 常驻线程

> - 子线程频繁的操作(下载/音频等), 浪费资源
>
> - 适合开启常驻Thread, 设定Source