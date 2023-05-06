# RunTime

#### 简析

> 运行时系统充当Objc的操作系统, 它使语言能够工作。
>
> 将尽可能多的决策从编译时、链接时推迟到运行时。

###### 特性

- 编写的代码具有运行时、动态特性
- OC语言函数调用为消息发送, 属于动态调用, 在编译阶段并不能决定真正调用哪个函数(编译阶段OC可以调用任何声明过的函数, 而C语言只有声明且实现才可以调用), 只有运行时才会根据函数名找到对应函数调用
  - 动态类型
    - 只有在运行期间才会确定对象类型

  - 动态绑定
    - 通过消息机制将函数调用推迟到运行阶段

  - 动态加载
    - 根据需求加载所需资源

- 可以从派发机制来理解

  - 直接派发

  - 消息派发

    


#### 运用

###### **Runtime在Object-C的使用**

> Objective-C程序在三个不同的层次上与运行时系统交互
>
> - 通过Object-C源代码进行交互
> - 通过NSObject类中定义的方法进行交互
> - 通过直接调用运行时函数

###### 基本作用

> - 程序运行过程中： 动态的创建类，动态添加修改这个类的属性和方法。
>
> - 遍历一个类中的所有成员变量、属性以及所有方法
>
> - 消息传递、转发

###### 具体运用

> - 系统分类添加方法、属性
> - 方法交换
>
> - 获取对象的属性、私有属性
> - 字典转模型
> - KVO / KVC
> - 归档（编码、解码）
> - 映射（NSClassFromString class<->String）
> - block
> - 类的自我检测
> - NSTimer循环打破
> - ...



#### 定义

###### 源码

```
@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}

/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class. 实例
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY; // isa指针指向类
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;

以上可知： 
- OC中的类是由Class类型来表示的，它实际是一指向objc_class结构体的指针。
- Class是类， id是指向objc_object的一个指针，而objc_object有个isa指向objc_class的指针。
  - 因此无论是Class还是id， 最终都指向objc_class这个结构体

# objc_class结构体源码
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */
```

###### isa

> `Class`对象， 指向`objc_class`结构体的指针， 也就是这个`Class`的`MetaClass`（元类）
>
> - 类的实例对象的 `isa` 指向该类; 该类的` isa` 指向该类的 `MetaClass`
> - `MetaClass`的isa对象指向`RootMetaClass`
>
> **super_class** Class对象指向父类对象
>
> - 如果该类的对象已经是RootClass，那么这个`super_class`指向nil
>
> - `MetaClass`的`SuperClass`指向父类的`MetaClass`
>
> - `MetaClass`是`RootMetaClass`，那么该`MetaClass`的`SuperClass`指向该对象的`RootClass `
> - 元类(MetaClass): 类对象的isa指向元类, super_class指向父类的类对象, 而元类的super_class指向了父类的元类, 元类的isa指向自己(形成闭环)

![](https://upload-images.jianshu.io/upload_images/7980283-2d02894c178d3582.png?imageMogr2/auto-orient/strip|imageView2/2/w/651)

###### 消息发送过程

> 主线：
>
> - 实例 --(isa)--> 类 --(super_class)--> 父类  --(super_class)--> ...  --(super_class)--> 根类(NSObject) --(super_class)--> nil
> - **可以说：isa指针建立起了实例与他所属的类之间的关系，super_class指针建立起了类与其父类之间的关系。**
> - objc_msgSend(receiver, selector, arg1, arg2, ...)
>   - receiver: 消息接收者
>   - selector: 方法名
>   - arg1/arg2...: 方法参数
>
>
> 具体过程：
>
> - 检测selector是否需要忽略（macOS的垃圾回收机制可以忽略retain release函数）
> - 检测target是否为nil， oc对nil对象发送消息会被忽略
> - 查找selector：
>   - cache中查找
>   - methodLists查找
>   - 父类 -> 超类
>
> - 消息转发
>   - 动态解析resolveInstanceMethod/resolveClassMethod， 制定新的IMP（未处理继续向下执行）
>   - 备用接受者： forwardingTargetForSelector， 指定新的接受者（返回nil， 继续向下执行）
>   - 完整消息转发： methodSignatureForSelector:返回一个方法签名，forwardInvocation:处理消息执行
>     - methodSignatureForSelector如果返回nil 直接crash
>     - methodSignatureForSelector返回只要是非nil且是NSMethodSignature类型的任何值都ok，
>     - forwardInvocation的参数anInvocation中的signature即为上一步返回的方法签名，
>     - forwardInvocation的参数anInvocation中的selector为导致crash的方法，target为导致crash的对象
>     - forwardInvocation方法可以啥都不处理，或者做任何不会出问题的事，至此本次消息转发结束，也不会crash。
>   - 抛出异常: - (void)doesNotRecognizeSelector:(SEL)aSelector
>     - 错误为: unrecognized selector sent to instance
> - 最终发送
>   - objc_msgSend("对象","SEL","参数"...)
>   - objc_msgSend( id self, SEL op, ... )

###### 消息转发

```
@interface Property: NSObject
@end
@implementation Property
- (void)eat {
    NSLog(@"Property eat");
}
@end
```

![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/Runtime/msg_forward.png?raw=true)

###### 动态解析

```
void eatMethod(id obj, SEL _cmd) {
   NSLog(@"Doing foo"); // 新的foo函数
}
+ (BOOL)resolveInstanceMethod:(SEL)sel {
  if (sel == @selector(eat:)) {
    // 动态解析, 指定新的IMP
    class_addMethod([self class], sel, (IMP)eatMethod, "V@:");
    return YES;
  }

  return [super resolveInstanceMethod:sel];
}
```

###### 备用接受者

```
+ (BOOL)resolveInstanceMethod:(SEL)sel {
  return [super resolveInstanceMethod:sel]; // NO
}
/// 备用接收者, 指定Person为消息接受者
- (id)forwardingTargetForSelector:(SEL)aSelector {
  if (aSelector == @selector(eat)) {
    return [Person new];
  }
  return [super forwardingTargetForSelector:aSelector];
}
```

###### 消息重定向

```
- (id)forwardingTargetForSelector:(SEL)aSelector {
   return [super forwardingTargetForSelector:aSelector]; // nil
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
   if ([NSStringFromSelector(aSelector) isEqualToString:@"eat"]) {
       return [NSMethodSignature signatureWithObjCTypes:"v@:"]; // 签名，进入forwardInvocation
   }
   return [super methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
   SEL selector = anInvocation.selector;
   Person *p = [[Person alloc] init];
   if ([p respondsToSelector:selector]) {
       [anInvocation invokeWithTarget:p];
   } else {
       // 消息处理异常
       [self doesNotRecognizeSelector:selector];
   }
}
```



#### 应用

###### isKindOfClass 与 isMemberOfClass

```
// 源码
+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

/// 可以看到self会继续遍历， 但是cls是固定的，因此只需要针对闭环查找self的最终isa是否与cls相同即可。
+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->super_class) {
        if(tcls == cls) return YES;
    }
    return NO；
}
-（BOOL)isKindOfClass:(Class)cls {
    for(Class tcls = [self class]; tcls; tcls = tcls->super_class) {
        if(tcls == cls) return YES;
    }
    return NO;
}
```

>  解析: 说白了就是判定isa指针指向是否相等
>
> - isKind: 检测当前对象是否属于某个类或者派生类 (可以检测根类)
>
> - isMember: 检测当前对象是否是当前类的实例
>
> - isMember: 不能检测任何类都是基于NSObject这一事实,但是isKindk可以
>
> - 对于类簇的判定要谨慎: 使用iskind of, 但是isMember可能得不到正确结果

```
举例: 判定指针
- [(id)[s class]] isKindOfClass:[Student class]]
  - [s class] 的isa指向Student的metaClass
  - 后者指向Class

- [(id)[Student class] isKindOfClass:[Student class]]
  - 后者不变, 指向Class
  - 前者本身为Class, isa指向metaClass, 逐层遍历, 是查找不到的, 所以NO

- [(id)[Student class] isMemberOfClass:[Student class]]
  - 同上, 直接判定第一层即可, 所以NO

- [(id)[NSObject class] isMemberOfClass:[NSObject class]]
  - 这个判定, 不会逐层便利, 所以同上NO
 
- [(id)[NSObject class] isKindOfClass:[NSObject class]]
  - 这个判定, 逐层遍历, 最终指向自身, 所以YES
  - 实例化后, student1的isa指针指向Class, 以此来进行判定

isKindOf： 调用者A，传入参数B，A可以继续向上遍历找到合适的isa，但是B不会的.
```

###### self&super

> - self调用自身方法, super调用父类方法
> - self是类, super是预编译指令
> - self = [super init] 是为了保证超类初始化ok, 防止返回不同的对象

```
// self
// id objc_msgSend(id theReceiver, SEL theSelector, ...)
// super
// id objc_msgSendSuper(struct objc_super, SEL op, ...)
struct objc_super {
  id receiver;
  Class superClass;
}
// 由上面可知: 最终消息接收者都是receiver, 都是self, 因此打印相同
```



###### 关联对象

```
extension UIView {
   filePrivate static var isShowKey = "isShowKey"
   var isShow: Bool {
      get {
          return objc_getAssociatedObject(self, &isShowKey) as? Bool ?? false
      }
      set {
          objc_setAssociatedObject(self, &isShowKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
}
```



###### 黑魔法

```
# Swift版本中黑魔法与OC不太一致
import UIKit
class Person {
    dynamic func play() {
        print("play")
    }
}
extension Person {
    @_dynamicReplacement(for: play())
    func play1() {
        print("play 1")
        play()
    }
}
extension Person {
    @_dynamicReplacement(for: play())
    func play2() {
        print("play 2")
        play()
    }
}

Person().play()
// play 2
// play
// 在Build Settings -> Other Swift Flags中添加 -Xfrontend -enable-dynamic-replacement-chaining
// 最终打印 play2, play1, play
```

- OC中一般在load中进行黑魔法交换处理

  > load是只要类所在的文件被引用就会被调用，而initialize是在类或者其子类的第一个方法被调用前调用。所以如果类没有被引用进项目，就不会调用load方法，即使类文件被引用进来，如果没有使用，那么initialize不会被调用。
  >
  > - load调用
  >   - 子类load在父类load之后执行, 分类的load会在主类load之后执行
  > - initialize调用
  >   - 走消息发送机制, 子类未实现则走父类, 子类实现则先父类后子类, 多个Category都实现了, 则只走Compile Sources列表中的最后一个Category进行覆盖
  > - 确保执行一次
  >   - load和initialize可能会调用多次，所以在这两个方法里面做的初始化操作需要dispatch_once来保证只初始化一次



###### 防崩溃处理

> 针对动态解析->备用接收者->消息重定向这个逻辑可以指定自定义的异常拦截.
>
> OC中的防崩溃处理可以参照AvoidCrash三方库
>
> - KVC/NSArray/NSMutableArray/NSDictionary/NSMutableDictionary/NSString/NSMutableString/NSAttributeString/NSMutableAttributedString
> - Unrecognized selector send to instance
>
> AvoidCrash针对异常处理后会拦截Bugly异常, 可以监听avoidcrash异常进行bugly自定义上报

###### 测试: 入参崩溃拦截

> hook方案更加方便, 但是有损性能
> 安全接口需要业务统一调用安全API, 更加轻量, 可进行编码规范

- hook

  ```
  @implementation NSMutableArray (Safe)
  + (void)load {
      [self swizzMethodOriginalSelector:@selector(addObject:)
                       swizzledSelector:@selector(safe_addObject:)];
  }
  
  + (void)swizzMethodOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
      Method originalMethod = class_getInstanceMethod(self.class, originalSelector);
      Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);
      BOOL didAddMethod = class_addMethod(self.class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
      if (didAddMethod) {
          class_replaceMethod(self.class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
      } else {
          method_exchangeImplementations(originalMethod, swizzledMethod);
      }
  }
  - (void)safe_addObject:(id)anObject {
      if (anObject) { [self safe_addObject:anObject]; }
  }
  @end
  ```

- 安全接口

  ```
  @implementation NSMutableArray (safe)
  - (void)safe_AddObject:(id)anObject {
      if (anObject) { [self addObject:anObject]; }
  }
  @end
  ```

###### Swift中数组越界预处理 (也是安全接口)

```
public protocol ArraySafeProtocol {
    
    associatedtype Element
    
    var anyOne: Element? { get }
    
    var reduction: [Element] { get }
    
    func randomAll() -> [Element]
    
    subscript (safe index: Int) -> Element? { get set }
    
    mutating func safeAppend(_ object: Element?) -> Array<Element>
    mutating func safeInsert(_ object: Element?, at index: Int) -> Array<Element>
    mutating func safeRemove(at index: Int) -> Array<Element>
    mutating func safeRemoveFirst() -> Element?
    mutating func safeRemoveLast() -> Element?
}

extension Array: ArraySafeProtocol {
    
    public var anyOne: Element? {
        guard count > 0 else { return nil }
        return self[Int.random(in: indices)]
    }
    
    public var reduction: [Element] {
        return reduce(into: []) {
            if let tmp = $1 as? [Element] {
                $0.append(contentsOf: tmp.reduction)
            } else {
                $0.append($1)
            }
        }
    }
    
    public func randomAll() -> [Element] {
        return sorted { (_, _) in Bool.random() }
    }
    
    /// index如果超出范围则返回nil
    public subscript (safe index: Int) -> Element? {
        get { return indices ~= index ? self[index] : nil }
        set {
            guard indices ~= index else { return }
            guard let v = newValue else {
                remove(at: index)
                return
            }
            insert(v, at: index)
            remove(at: index + 1)
        }
    }
    
    /// object为nil则什么都不做并返回self
    @discardableResult
    public mutating func safeAppend(_ object: Element?) -> Array<Element> {
        guard let obj = object else { return self }
        append(obj)
        return self
    }
    
    /// object为nil或者index超出范围则什么都不做并返回self
    @discardableResult
    public mutating func safeInsert(_ object: Element?, at index: Int) -> Array<Element> {
        if index >= 0, index < Int(count), let obj = object { insert(obj, at: index) }
        return self
    }
    
    /// index如果超出范围则什么都不做并返回self
    @discardableResult
    public mutating func safeRemove(at index: Int) -> Array<Element> {
        if index >= 0, index < Int(count) { remove(at: index) }
        return self
    }
    
    @discardableResult
    public mutating func safeRemoveFirst() -> Element? {
        if isEmpty { return nil }
        return removeFirst()
    }
    
    @discardableResult
    public mutating func safeRemoveLast() -> Element? {
        if isEmpty { return nil }
        return removeLast()
    }
}
```

