# Runtime-KVO&KVC

### KVC

#### 原理

- 键值编码, 使用字符串直接访问对象属性

- [官方文档](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/SearchImplementation.html#//apple_ref/doc/uid/20000955-CJBBBFFA)

- get原理

  1. 调用getter方法: get<Key>` -> `<key>` -> `is<Key>` -> `_<key>, 有则返回

  2. ```
     If no simple accessor method is found, search the instance for methods whose names match the patterns countOf<Key> and objectIn<Key>AtIndex: (corresponding to the primitive methods defined by the NSArray class) and <key>AtIndexes: (corresponding to the NSArray method objectsAtIndexes:).
     If the first of these and at least one of the other two is found, create a collection proxy object that responds to all NSArray methods and return that. Otherwise, proceed to step 3.
     The proxy object subsequently converts any NSArray messages it receives to some combination of countOf<Key>, objectIn<Key>AtIndex:, and <key>AtIndexes: messages to the key-value coding compliant object that created it. If the original object also implements an optional method with a name like get<Key>:range:, the proxy object uses that as well, when appropriate. In effect, the proxy object working together with the key-value coding compliant object allows the underlying property to behave as if it were an NSArray, even if it is not.
     ```

  3. ```
     If no simple accessor method or group of array access methods is found, look for a triple of methods named countOf<Key>, enumeratorOf<Key>, and memberOf<Key>: (corresponding to the primitive methods defined by the NSSet class).
     If all three methods are found, create a collection proxy object that responds to all NSSet methods and return that. Otherwise, proceed to step 4.
     This proxy object subsequently converts any NSSet message it receives into some combination of countOf<Key>, enumeratorOf<Key>, and memberOf<Key>: messages to the object that created it. In effect, the proxy object working together with the key-value coding compliant object allows the underlying property to behave as if it were an NSSet, even if it is not.
     ```

  4. 若accessInstanceVariablesDirectly(直接访问实例变量)返回true, 顺序查找`_<key>`、`_is<Key>`、`<key>`或`is<Key>`的成员变量, 有则返回

  5. 如果getter方法或者成员变量都未找到, 调用valueForUndefineKey抛出异常

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/Runtime/kvc_get.png?raw=true)

- set原理

  1. 顺序查找名为`set<Key>:`或`_set<Key>`的方法, 有则调用
  2. 若accessInstanceVariablesDirectly返回true, 则顺序查找`_<key>`、`_is<Key>`、`<key>`或`is<Key>`的实例变量, 有则赋值
  3. 如果setter方法 或者 实例变量都没有找到, 调用setValue:forUndefineKey默认抛出异常
  
  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/Runtime/kvc_set.png?raw=true)

#### 应用

###### setValue/setObject: forkey:

- setValue:forKey:

  > 这是KVC（键－值编码）提供的方法, 旨在通过key去修改一个obj的属性，如果是字典的话，则修改key对应的value，如果是数组或者集合，则会向每个对象发送此消息，去修改元素的key对应的property
  >
  > 注解: Send -setObject:forKey: to the receiver, unless the value is nil, in which case send -removeObjectForKey
  >
  > - 也就是给消息接受者发送-setObject:forKey: 消息，如果value为nil，则给消息接受者发送-removeObjectForKey:消息(也就是移除键值对)
  >
  > - 如果向一个对象a发送-setValue: forKey:消息，除非能确保a包含key对应的property（即key和A的某个property名字相同），否则必须实现类A或者其父类的-setValue: forUndefinedKey:方法，否则会导致crash。

- setObject:(ObjectType)... forKey:...

  > 这是NSMutableDictionary的对象方法，旨在修改字典中key对应的value，如果key不存在，则添加此key－value对
  >
  > - 调用-setObject: forKey:时，务必对object进行判空，只有当object不为nil时方可调用该方法，否则会导致程序crash。

###### 实例

```
# 1. 简单赋值
Person *p = [[Person alloc] init];
// p.name = @"jack";
// p.money = 22.2;
# 使用setValue: forKey:方法能够给属性赋值,等价于直接给属性赋值
[p setValue:@"rose" forKey:@"name"];
[p setValue:@"22.2" forKey:@"money"];

// 给Person添加Dog属性
Person *p = [[Person alloc] init];
p.dog = [[Dog alloc] init];
p.dog.name = @"阿黄";

# 2. 复杂赋值
1) setValue: forKeyPath: 方法的使用
# 修改p.dog 的name 属性
[p.dog setValue:@"wangcai" forKeyPath:@"name"];
[p setValue:@"阿花" forKeyPath:@"dog.name"];

# 2) setValue: forKey: *错误用法*
[p setValue:@"阿花" forKey:@"dog.name"];
NSLog(@"%@", p.dog.name);

# 3) 直接修改私有成员变量
[p setValue:@"旺财" forKeyPath:@"_name"];

# 3. 添加私有成员变量
[p setValue:@"22" forKeyPath:@"_age"];
抛出异常: Error: this class is not key value coding-compliant for the key _age.'
```



### KVO

```
- 键值观察
- 底层实现:
  - 当A类添加KVO时, Runtime动态生成子类NSKVONotifying_A, 让A的isa指向NSKVONotifying_A, 重写class方法, 隐藏对象真实类信息
  - 重新监听属性的setter方法, 调用Foundation中的_NSSetObjectValueAndNotify函数
  - 在_NSSetObjectValueAndNotify内部:
    - 先调用willChangeValueForKey
    - 然后给属性赋值
    - 调用didChangeValueForKey
    - 调用observe的observeValueForKeyPath去告诉监听器属性值发生了改变
  - 重写dealloc, 做一些KVO内存释放
- 手动触发:
  - 主动调用willChange和didChange方法(必须都要调用)
  - willChange会记录旧值,改变之后会调用didChange...,继而调动observeValueForKeyPath
- 直接修改成员变量无法触发KVO
   - 是因为没有触发setVar方法
* 因此: 代理的效率高于KVO，因为代理不存在动态生成派生类，也不会在内存里面增加派生类，直接拿到代理进行调用，而 KVO 还需要在运行时动态生成派生类   
```

```
# 打印KVO前后: objc_getClassName()不一致: Person -> NSKVONotifying_Person
# 调试断点set方法, 前面会看到
#3	0x00007fff207a6660 in _NSSetObjectValueAndNotify ()
#1	0x00007fff207ad133 in -[NSObject(NSKeyValueObservingPrivate) _changeValueForKeys:count:maybeOldValuesDict:maybeNewValuesDict:usingBlock:] ()
```

```
po [NSKVONotifying_Person _shortMethodDescription]
register read ...
```



#### 步骤

> 1. 通过`addObserver:forKeyPath:options:context:`方法注册观察者，观察者可以接收`keyPath`属性的变化事件回调。
>
> 2. 在观察者中实现`observeValueForKeyPath:ofObject:change:context:`方法，当`keyPath`属性发生改变后，`KVO`会回调这个方法来通知观察者。
>
> 3. 当观察者不需要监听时，可以调用`removeObserver:forKeyPath:`方法将`KVO`移除。需要注意的是，调用`removeObserver`需要在观察者消失之前，否则会导致`Crash`

#### 触发

> 调用KVO属性对象时，不仅可以通过点语法和set语法进行调用，KVO兼容很多种调用方式

```
// 直接调用set方法，或者通过属性的点语法间接调用
[account setName:@"Savings"];

// 使用KVC的setValue:forKey:方法
[account setValue:@"Savings" forKey:@"name"];

// 使用KVC的setValue:forKeyPath:方法
[document setValue:@"Savings" forKeyPath:@"account.name"];

// 通过mutableArrayValueForKey:方法获取到代理对象，并使用代理对象进行操作
Transaction *newTransaction = <#Create a new transaction for the account#>;
NSMutableArray *transactions = [account mutableArrayValueForKey:@"transactions"];
[transactions addObject:newTransaction];
```

#### 主动触发

> 在属性发生改变之前调用`willChangeValueForKey:`方法，在发生改变之后调用`didChangeValueForKey:`方法。但是，如果不调用`willChangeValueForKey`，直接调用`didChangeValueForKey`是不生效的，二者有先后顺序并且需要成对出现。

```
- (void)setName:(NSString *)name {
    if (name != _name) {
        [self willChangeValueForKey:@"name"];
        _name = name;
        [self didChangeValueForKey:@"name"];
    }
}
```



#### 禁用KVO

> 如果想禁止某个属性的`KVO`，例如关键信息不想被三方`SDK`通过`KVO`的方式获取，可以通过`automaticallyNotifiesObserversForKey`方法返回`NO`来禁止其他地方对这个属性进行`KVO`。方法返回`YES`则表示可以调用，如果返回`NO`则表示不可以调用。此方法是一个类方法，可以在方法内部判断`keyPath`，来选择这个属性是否允许被`KVO`

```
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    if ([theKey isEqualToString:@"name"]) {
        return NO;;
    }
    return [super automaticallyNotifiesObserversForKey:theKey];;
}
```



###### 示例

```
class Person: NSObject {
    /// 告诉编译器使用动态分发而不是静态分发
    /// 标记为dynamic的变量/函数会隐式的加上@objc关键字，它会使用OC的runtime机制
    @objc dynamic var name: String = ""
}

# 调用方式一
self.person.addObserver(self, forKeyPath: "name", options: [.new, .old], context: nil)
override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    print("\(keyPath!) change to \(change![.newKey] as! String)")
}
deinit { self.person.removeObserver(self, forKeyPath: "name") }

# 调用方式二
var ob : NSKeyValueObservation?
self.ob = self.person.observe(\Person.name) { p, change in
    print(change)
}

# 触发
self.person.name = "change"
```

