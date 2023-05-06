# AutoreleasePool



#### autorelease

> autorelease会将对象放到一个自动释放池中，当自动释放池被销毁时，会对池子里面的所有对象做一次release操作。也就是调用后不是马上计数-1，而是在自动释放池销毁时再-1

#### 创建/释放

> 其实对象的释放是由AutoreleasePool来做的，而这个pool会在RunLoop进入的时候创建，在它即将进入休眠的时候对pool里面所有的对象做release操作，最后再创建一个新的pool



#### 源码

```
A thread's autorelease pool is a stack of pointers.
Each pointer is either an object to release, or POOL_BOUNDARY which is
an autorelease pool boundary.
A pool token is a pointer to the POOL_BOUNDARY for that pool. When
the pool is popped, every object hotter than the sentinel is released.
The stack is divided into a doubly-linked list of pages. Pages are added
and deleted as necessary.
Thread-local storage points to the hot page, where newly autoreleased
objects are stored.

- 线程的自动释放池是指针的堆栈
- 每个指针都是要释放的对象，或者是POOL_BOUNDARY，它是自动释放池的边界。
- 池令牌是指向该池的POOL_BOUNDARY的指针。弹出池后，将释放比哨点更热的每个对象。
- 堆栈分为两个双向链接的页面列表。根据需要添加和删除页面。
- 线程本地存储指向热页面，该页面存储新自动释放的对象
```



##### Push/Pop

```
# push
void *objc_autoreleasePoolPush(void) {
    return AutoreleasePoolPage::push();
}
static inline void *push() {
   return autoreleaseFast(POOL_SENTINEL);
}
static inline id *autoreleaseFast(id obj)
{
   AutoreleasePoolPage *page = hotPage(); // 获取聚焦页
   if (page && !page->full()) { // page存在且未满, 压栈
       return page->add(obj);
   } else if (page) {
       return autoreleaseFullPage(obj, page); 
   } else {
       return autoreleaseNoPage(obj);
   }
}
/// 通过一个do while循环查找子页面，并判断子页面是否也是满的: 如果满就继续循环，如果没有子页面，就创建个新页面
static __attribute__((noinline))
id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
{
    // The hot page is full. 
    // Step to the next non-full page, adding a new page if necessary.
    // Then add the object to that page.
    ASSERT(page == hotPage());
    ASSERT(page->full()  ||  DebugPoolAllocation);

    do {
        if (page->child) page = page->child;
        else page = new AutoreleasePoolPage(page);
    } while (page->full());

    setHotPage(page);
    return page->add(obj);
}

# pop
void objc_autoreleasePoolPop(void *ctxt) {
    AutoreleasePoolPage::pop(ctxt);
}
static inline void pop(void *token) {
    AutoreleasePoolPage *page = pageForPointer(token);
    id *stop = (id *)token;

    page->releaseUntil(stop);

    if (page->child) {
        if (page->lessThanHalfFull()) {
            page->child->kill();
        } else if (page->child->child) {
            page->child->child->kill();
        }
    }
}
```

##### 核心Page

```
class AutoreleasePoolPage {
    magic_t const magic; // page完整性校验
    id *next; // next指向的是栈顶对象的下一个位置，这样再放入新的对象的时候就知道放到哪个地址了，放入以后会更新next指向，让它指到新的空位。如果AutoreleasePoolPage空间被占满时，会创建一个AutoreleasePoolPage连接链表，后来的对象也会在新的page加入
    pthread_t const thread; // 当前所在线程
    AutoreleasePoolPage * const parent;
    AutoreleasePoolPage *child;
    uint32_t const depth;
    uint32_t hiwat;
};
```



#### 原理

- 自动释放池AutoreleasePool是以一个个AutoreleasePoolPage组成，而AutoreleasePoolPage以双链表形成的自动释放池

- 每进行一次objc_autoreleasePoolPush调用时，runtime就会将当前的AutoreleasePoolPage加入一个哨兵对象, objc_autoreleasePoolPop的时候，根据传入的哨兵位置找到哨兵所对应的page
  将晚于哨兵对象插入的autorelease对象都发送一个release消息，并移动next指针到正确的位置。
  objc_autoreleasePoolPush返回值也就是哨兵对象的地址，被objc_autoreleasePoolPop作为参数

- @autoreleasepool{} 就是先push一下得到哨兵地址，然后把包裹的创建的变量一个个放入AutoreleasePoolPage，最后pop将哨兵地址之后的变量都拿出来一个个执行release。所以@autoreleasepool和AutoreleasePool不是一个含义哦！

![img](https://upload-images.jianshu.io/upload_images/2440780-c5619cdeaf3dc20c.png?imageMogr2/auto-orient/strip|imageView2/2/w/1046)

![img](https://upload-images.jianshu.io/upload_images/3275978-b5cf9e3a33d5af39.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



#### 应用

##### 1. 循环优化

##### 2. 子线程释放

- 子线程在使用autorelease对象时，如果没有autoreleasepool会在autoreleaseNoPage中懒加载一个出来。
- 在runloop的run:beforeDate，以及一些source的callback中，有autoreleasepool的push和pop操作，总结就是系统在很多地方都有autorelease的管理操作。
- 就算插入没有pop也没关系，在线程exit的时候会释放资源。

- 子线程默认没有runloop，而autoreleasepool依赖于runloop，那么子线程没有autoreleasepool么？它的变量如何释放呢？
  - 并不清除系统会如何, 因此最好自己创建一个

##### 3. Runloop

- App启动

  ```
     App启动之后，系统启动主线程并创建了RunLoop，在main thread中注册了两个observer, 回调都是_wrapRunLoopWithAutoreleasePoolHandler()
     第一个Observer监视事件: 
     即将进入Loop（kCFRunLoopEntry），其回调内会调用 _objc_autoreleasePoolPush() 创建自动释放池。其order是-2147483647，优先级最高，保证创建释放池发生在其他所有回调之前。
     第二个Observer监视了两个事件:
     准备进入休眠（kCFRunLoopBeforeWaiting），此时调用 _objc_autoreleasePoolPop() 和 _objc_autoreleasePoolPush() 来释放旧的池并创建新的池。
     即将退出Loop（kCFRunLoopExit）此时调用 _objc_autoreleasePoolPop()释放自动释放池。这个 Observer的order是2147483647，确保池子释放在所有回调之后。
  ```

- 线程

  - 主线程中: Runloop开启,自动释放池会自动创建,Runloop休息之前,会释放掉自动释放,然后创建一个新的自动释放池子.
  - NSThread和NSOperationQueue开辟子线程需要手动创建 autoreleasepool,GCD开辟子线程不需要手动创建autoreleasepool, 因为GCD的每个队列都会自行创建autoreleasepool



#### 问题

- 通常非alloc、new、copy、mutableCopy出来的对象都是autorelease的，比如[UIImage imageNamed:]、[NSString stringWithFormat]、[NSMutableArray array]等。（会加入到最近的autorelease pool）

  - 因此不是autoreleasepool可以自动监测对象的创建，而是你对象创建的时候被ARC默认加了`return [obj autorelease]`，就被放进AutoReleasePage啦



##### [参考](https://www.jianshu.com/p/22a5f405fe5b)