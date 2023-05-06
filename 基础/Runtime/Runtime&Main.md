# Runtime&Main



#### Main之前

##### 启动时间

> 在Product->Scheme->Edit Scheme->Environment Variables修改DYLD_PRINT_STATISTICS值为${DEBUG_ACTIVITY_MODE}或者1
>
> DYLD_PRINT_STATISTICS_DETAILS可看到更详细信息
>
> 在使用这种方式时，需要注意两个地方：
>
> - iOS 15 以上的真机不再支持打印相关耗时数据。
> - 在 Debug 环境下拿到的数据会有`debugger pause time`的影响，我们可以将`scheme`中的`debug executable`进行关闭来去除该影响因素。

###### 打印

> - Total pre-main time
>   - 总耗时 (如果大于20s会被系统watch dog杀掉。)
> - dylib loading
>   - 加载可执行文件（App 的.o 文件的集合）， App所需的所有动态链接库都在这个阶段加载
> - rebase/binding time
>   - 对动态链接库进行 rebase 指针调整和 bind 符号绑定
> - Objc setup
>   - OC runtime运行时的初始处理，包括 Objc 相关类的注册、category 注册、selector 唯一性检查等
> - initializer
>   - 包括了执行 +load() 方法、attribute((constructor)) 修饰的函数的调用、创建 C++ 静态全局变量
> - slowest intializers
>   - 会列出加载最慢的几个dylib文件
>   - 例如libSystem.B.dylib



#### 解析

> dyld: 动态链接库 libsystem_blocks, libsystem_c, libdispatch
>
> - 代码公用: 多个程序都会链接lib,但是在内存和磁盘中只有一份
> - 易于维护: lib只有程序运行才link, 容易更新
> - 减少可执行文件的体积: 相比静态链接,动态链接不需要再编译时打进去, 所以可执行文件会比较小
>
> ImageLoader
>
> - Image: 二进制可执行文件: 编译过的代码`符号
>
> - ImageLoader作用是将这些文件加载进内存,且每一个文件对应一个ImageLoader实例在负责加载



#### Main之后

> 主要是指main()函数执行开始，到`Appdelegate`的`didFinishLaunchingWithOptions`方法里首屏渲染相关方法的执行
>
> - 首屏初始化所需要配置文件的读写操作
> - 首屏列表大数据的读取
> - 首屏渲染的大量计算

##### 首屏渲染完成

> 从渲染完成时开始，到 `didFinishLaunchingWithOptions` 方法作用域结束时结束



#### 启动优化

###### 启动流程

> - 加载可执行文件（`mach-o文件`）
> - 加载动态链接库，进行`rebase`指针调整和`bind`符号绑定
> - Objc运行时的初始化处理，包括Objc相关类的`注册`、`category注册`、`selector`唯一性检查
> - 初始化，包括执行了`+load()`方法、`attribute((constructor))`修饰的函数调用、创建C++静态全局变量

###### Pre Main优化

> - 减少动态库加载
>   - 每个库本身都有依赖关系，苹果公司建议使用更少的动态库，并且建议在使用动态库的数量较多时，尽量将多个动态库进行合并。数量上，苹果公司建议最多使用 6 个非系统动态库
> - 减少加载启动后不回去使用的类或者方法
> - `+load()`方法里面内容可以放到首屏渲染完成后执行, 或者使用`+initlialize()`替换
>   - 因为，在一个`+load()` 方法里，进行运行时方法替换操作会带来 4 毫秒的消耗。不要小看这 4 毫秒，积少成多，执行 +load() 方法对启动速度的影响会越来越大
> - 控制`c++`全局变量的数量

###### Main优化

> - 从功能上梳理出哪些是首屏渲染必要的初始化功能，哪些是 App 启动必要的初始化功能，而哪些是只需要在对应功能开始使用时才需要初始化的。梳理完之后，将这些初始化功能分别放到合适的阶段进行。
> - 首屏渲染优化
>   - **功能级别优化** 
>     main() 函数开始执行后到首屏渲染完成前只处理首屏相关的业务，其他非首屏业务的初始化、监听注册、配置文件读取等都放到首屏渲染完成后去做
>   - **方法级别去优化** 
>     我们需要进一步做的，是检查首屏渲染完成前主线程上有哪些耗时方法，将没必要的耗时方法滞后或者异步执行。通常情况下，耗时较长的方法主要发生在计算大量数据的情况下，具体的表现就是加载、编辑、存储图片和文件等资源
