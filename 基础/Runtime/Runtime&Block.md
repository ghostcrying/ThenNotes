# Block



#### 本质

> 本质也是OC对象, 有ISA指针
>
> 是将函数及其执行上下文封装起来的一个对象;



#### 类型

> 其中栈Block存储在栈(stack)区，堆Block存储在堆(heap)区，全局Block存储在已初始化数据(.data)区

- _NSConcreteGlobalBlock

  > 不使用外部变量的Block是全局Block

  ```
  NSLog(@"%@",[^{
      NSLog(@"globalBlock");
  } class]); 
  /// 输出: __NSGlobalBlock__
  ```

- _NSConcreteStackBlock

  > 使用外部变量并且未进行copy操作的block是栈block

  ```
  NSInteger num = 10;
  NSLog(@"%@",[^{
      NSLog(@"stackBlock:%zd",num);
  } class]);
  /// 输出: __NSStackBlock__
  ```

- _NSConcreteMallocBlock

  > - 对栈block进行copy操作，就是堆block，而对全局block进行copy，仍是全局block
  >
  > - 即如果对栈Block进行copy，将会copy到堆区，对堆Block进行copy，将会增加引用计数，对全局Block进行copy，因为是已经初始化的，所以什么也不做

  ```
  # 对全局block拷贝依旧是全局block 
  void (^globalBlock)(void) = ^{
      NSLog(@"globalBlock");
  };
  NSLog(@"%@",[globalBlock class]);
  /// 输出: __NSGlobalBlock__
  
  
  # 对栈block赋值之后改为堆Block, 调用就会进行赋值
  NSInteger num = 10;
  void (^mallocBlock)(void) = ^{
      NSLog(@"stackBlock:%zd",num);
  };
  NSLog(@"%@", [mallocBlock class]);
  NSLog(@"%@", mallocBlock);
  /// 输出: __NSMallocBlock__
  
  
  # 对栈block copy之后，并不代表着栈block就消失了，左边的mallock是堆block，右边被copy的仍是栈block
  - (void)testWithBlock:(dispatch_block_t)block {
      // block();
      dispatch_block_t tempBlock = block;    
      NSLog(@"%@,%@", [block class], [tempBlock class]);
  }
  [self testWithBlock:^{ NSLog(@"%@", self); }];
  /// 输出: __NSStackBlock__, __NSMallocBlock__
  ```

  

#### 用copy修饰

> 1. 一般情况下对于Block不需要自行调用copy, 只有Block区域外会自动调用copy.
>2. ARC下使用copy与strong同等效果, 因为block的retain就是copy实现的.
> 3. ARC下编译器默认声明的block都是全局block或者堆block
>   1. 使用copy可以理解为防止指针拷贝导致被外部改变**(此处有疑问?)**



#### 变量截获

- 局部变量

  ```
  # 值截获
  NSInteger num = 3;
  NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
      return n*num;
  };
  num = 1;
  NSLog(@"%zd",block(2)); /// 输出6
  ```

  > 对于局部变量, 可以使用__block进行变量修饰, 进而解决无法指针捕获的问题

  ```
  __block NSInteger num = 3; 
  NSLog(@"%p", &num); // 0x7ff7bfeff2f8
  void(^block)(void) = ^{
      NSLog(@"%p", &num); // 0x1012070b8
      NSLog(@"%zd", num);
  };
  NSLog(@"%p", &num); // 0x1012070b8
  num = 1;
  block();
  
  /// 通过clang -rewrite-objc xxx.m, 可以发现num属性转换为了
  struct __Block_byref_num_0 {
    void *__isa;
    __Block_byref_num_0 *__forwarding; // 指向自身
    int __flags;
    int __size;
    NSInteger num;
  };
  
  __attribute__((__blocks__(byref))) __Block_byref_num_0 num = {(void*)0,(__Block_byref_num_0 *)&num, 0, sizeof(__Block_byref_num_0), 30000};
  static void __block_func_0(struct __block_impl_0 *__cself) {
    __Block_byref_num_0 *num = __cself->num; // bound by ref
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_td_xblvxc8n2tg8ctnqqq454yl80000gp_T_main_840146_mi_0, (num->__forwarding->num));
  }
  // 栈num -> 栈num的__forwarding -> 堆num
  (num.__forwarding->num) = 1;
  ```

  > 分析: 使用`__block`修饰之后, 局部变量改为结构体, 有`isa`, `__forwarding`指针
  >
  > - __block变量未copy前, 存在栈上, `__forwarding`指针指向其自身
  > - copy后, 变量会被拷贝到堆, 原始存在栈上`__block`变量的`__forwarding`指针指向copy后的堆变量, 而堆变量的`__forwarding`指针指向其自身
  > - 此时无论最终__block变量在栈上还是堆上, 通过`num.__forwarding->num` 都可以精准的访问到变量并进行修改.

  ![](https://segmentfault.com/img/remote/1460000018779730)

- 局部静态变量

  ```
  # 指针截获
  static NSInteger num = 3;
  NSInteger(^block)(NSInteger) = ^NSInteger(NSInteger n){
      return n*num;
  };
  num = 1;
  NSLog(@"%zd",block(2)); /// 输出2
  ```

- 全局静态变量 + 全局变量

  ```
  # 指针截获
  static NSInteger num1 = 300; /// 直接取值
  NSInteger num2 = 3000;       /// 直接取值
  
  - (void)testGlobalBlockCatch {
    void (^block)(NSInteger) = ^void(NSInteger n){
       NSLog(@"%zd -- %zd", n * num1, n * num2); 
    };
    num1 = 1;
    num2 = 1;
    NSLog(@"%zd", block(2)); /// 输出2 -- 2
  }
  ```

  

#### `__block` & `__weak`

> - __block不管是ARC还是MRC都可使用, 可以修饰对象与基本数据类型
> - __weak只能在ARC下使用,  只能修改对象
> - __block修饰的对象可以在block中重新赋值, weak修饰的对象不可以.



#### 循环引用

> block的循环引用为自循环引用
>
> 部分系统层级的Block并不会引起循环引用: UIAnimate, GCD...
>
> 同样Masonry中的Block是栈Block, 并不构成循环引用的条件

```
案例：常见的循环引用 self持有block block持有self
self.name = @"ycx";
self.block = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", self.name);
    });
};
```

> 多个对象相互之间有强引用，不能释放让系统回收

##### 解决方案

###### 方案一

```
# 强弱共舞，通过__weak和__strong，从而达到改变引用关系，同时改变作用域，使得只有在block内容执行完毕后，才可以释放self
__weak typeof(self) weakSelf = self;
self.myBlock = ^() {
  __strong typeof(self) strongSelf = weakSelf;
  [strongSelf test];
};
# 因为weakSelf和self是两个内容, test有可能就直接对self自身引用计数减到0了.
  所以在[weakSelf test]的时候,你很难控制这里self是否就会被释放了.weakSelf只能看着.
# __strong __typeof在编译的时候,实际是对weakSelf的强引用.
  指针连带关系self的引用计数还会增加. 但是你这个是在block里面,生命周期也只在当前block的作用域.
  所以, 当这个block结束, strongSelf随之也就被释放了. 同时也不会影响block外部的self的生命周期
```

###### 方案二

```
# 通过__block修饰临时变量vc去引用self, 只有当block里面执行完毕且VC置空才可以正常释放self
__block ViewController *vc = self;
self.block = ^(void){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", vc.name);
        vc = nil;
    });
};
self.block();
```

###### 方案三

```
# 通过传参的方式: 参数vc的作用域就是block代码块的范围, 执行完毕后, VC置空自然可以释放self
self.block = ^(ViewController *vc){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", vc.name);
    });
};
self.block(self);
```



##### 相互循环引用

- delegate
  - 使用assign修饰的话需要手动处理生命周期,  因此使用weak更加便利
- timer
  - 适当位置invalide且置为nil