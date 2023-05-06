# Timer释放



#### 分析

###### 源码注释

```
Creates a timer and schedules it on the current run loop in the default mode.
Declaration

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
Discussion

After ti seconds have elapsed, the timer fires, sending the message aSelector to target.
Parameters
- ti  
  - The number of seconds between firings of the timer. If ti is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
- target  
  - The object to which to send the message specified by aSelector when the timer fires. The timer maintains a strong reference to target until it (the timer) is invalidated.
- aSelector   
  - The message to send to target when the timer fires.
  - The selector should have the following signature: timerFireMethod: (including a colon to indicate that the method takes an argument). The timer passes itself as the argument, thus the method would adopt the following pattern:
- (void)timerFireMethod:(NSTimer *)timer

- userInfo    
  - The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
repeats 
  - If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
- Returns
  - A new NSTimer object, configured according to the specified parameters.
```

###### 结论

> 1. 定时器对target是强引用(直到invalidate)
>
> 2. 创建定时器与invalidate定时器要配套使用

###### 根源

> timer强持有target
>
> runloop强持有timer
>
> repeat的timer只有在调用了invalidate之后才会被runloop释放
>
> 为了timer和target的生命周期一致，我们在target的dealloc中invalidate timer
>
> - target被强持有了，不会走dealloc，就内存泄漏了



#### 解决

###### 1. 适当地方手动调用invalidate

```
/// 更加合理
- (void)didMoveToParentViewController:(UIViewController *)parent{
    // 无论push 进来 还是 pop 出去 正常跑
    // 就算继续push 到下一层 pop 回去还是继续
    if (parent == nil) {
       [self.timer invalidate];
        self.timer = nil;
    }
}

/// 页面切换后停止定时器就废了
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}
```



###### 2. 分类解决

> 1. 创建一个NSTimer类的Category（BlockTimer），自定义一个类方法，传递timer需要的参数以及一个block回调。这个block的参数是NSTimer，后面有用。
> 2. 通过把NSTimer类作为target，而类对象本身就是单利，不怕强持有；
> 3. 实现一个类方法handler:处理timer的回调；
> 4. 通过userInfo传递外部block，在handler: 中把block读取出来调用，同时把timer传回target

```
@implementation NSTimer (BlockTimer)

+ (NSTimer *)bt_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(NSTimer *timer))block
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(handler:) userInfo:[block copy] repeats:repeats];
}

+ (void)handler:(NSTimer *)timer 
{   
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}
@end

调用:
__weak typeof(self) weakSelf = self;
self.timer = [NSTimer bt_timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (strongSelf) {
        [strongSelf timerAction];
    } else {
        [timer invalidate];
    }
}];
解析: 这里虽然解决了self被NSTimer强引用的问题，self也能正常被释放掉，但是由于timer还没被释放掉，所以block会一直被执行，所以这里判断self为空时调用释放timer.
另外也可以在dealloc中释放
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"%@-%s", [self class], __func__);
}
```



###### 3. 自定义对象

```
@interface CustomTimer ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) id target; // 不是timer的target，而是外面真正实现业务的对象, 而且不再强引用

@end

@implementation CustomTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                                   target:(id)target
                                 selector:(SEL)selector
                                  repeats:(BOOL)repeat
{
    if (self = [super init]) {
    
        NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
        // 用于外部真正target的方法调用，invocation通过userInfo参数传递
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = selector;
        invocation.target = target;
        
        self.target = target;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(handler:) userInfo:invocation repeats:repeat];
    }
    return self;
}

- (void)handler:(NSTimer *)timer
{
    NSInvocation *invocation = [timer userInfo];
    /// 不为空则通过invocation调用target方法，如果为空则释放timer
    if (self.target) {
        [invocation invoke];
    } else {
        [self invalidate];
    }
}

- (void)invalidate
{
    [self.timer invalidate];
    self.timer = nil;
}

@end

Example:
self.customTimer = [[CustomTimer alloc] initWithTimeInterval:1 target:self selector:@selector(timerAction) repeats:YES];
/// handle中释放, 则不需要在dealloc中继续释放了
- (void)dealloc {
    [self.customTimer invalidate];
}
```



###### 4. 使用NSProxy对象

> NSProxy是虚拟基类，通过实现NSProxy子类，实现消息转发

```
@interface CustomProxy ()
@property(nonatomic, weak) id target;
@end

@implementation CustomProxy

+ (instancetype)proxyWithTarget: (id)target {
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget: (id)target {
    _target = target;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self.target];
    }
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

@end

Example:
- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[CustomProxy proxyWithTarget:self] selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"%@-%s", [self class], __func__);
}
```



###### NSProxy简析

> - NSProxy是和NSObject同级的一个类，可以说它是一个虚拟类，它只是实现了<NSObject>的协议；
> - OC是单继承的语言，但是基于运行时的机制，却有一种方法让它来实现一下"伪多继承"，就是利用NSProxy这个类；
> - OC中的NSProxy类，填补了"多继承"这个空白；
> - 通过继承NSProxy，并重写这两个方法以实现消息转发到另一个实例



###### 5.调用iOS10的Timer block方法

```
__weak typeof(self) weakSelf = self;
[NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) { 
    __strong typeof(weakSelf) strongSelf = weakSelf;
}];
```

