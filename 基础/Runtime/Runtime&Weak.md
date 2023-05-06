# Runtime&Weak



```
## weak实现
 - runtime维护了一个weak的hash表， 用于存储指向对象的所有weak指针, 其中key是所指对象的指针, value是weak指针的地址
 - initWeak
   - objc_storeWeak
   - 声明新旧散列表SideTable
   - 根据location获取对应的SideTable
   - 对SideTable进行加锁,防止线程冲突
   - 进行线程冲突处理预判断
   - 判断isa是否为空, 否则进行初始化
   - 存在旧值, 则weak_unregister_no_lock清理
   - 存储新值, weak_register_no_lock
   - 对新旧散列表解锁, 返回第二参数
 - release
   - objc_release
   - dealloc -> objc_rootDealloc -> objc_dispose
   - 最终调用clearDeallocing -> weak_clear_no_lock清除引用信息
```

