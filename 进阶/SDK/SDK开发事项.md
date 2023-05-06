# SDK



#### 区别

##### 静态库

- 链接时会被完整的复制到可执行文件中，被多次使用就有多分拷贝
- 加载 App 速度更快, 因为在编译时已经进行了链接, 因此启动时不需要进行二次查找启动

![img](https://upload-images.jianshu.io/upload_images/1802326-bf2014d90630e36d.png?imageMogr2/auto-orient/strip|imageView2/2/w/200)

##### 动态库

- 系统动态库：

  - 链接时不复制，程序运行时由系统动态加载到内存，系统只加载一次，多个程序共用，节省内存。

  ![img](https://upload-images.jianshu.io/upload_images/1802326-55c430d97b4cf28a.png?imageMogr2/auto-orient/strip|imageView2/2/w/200)

- 自定义动态库

  - 自定义动态库，则是在应用程序里的，但是与静态库不同，它不在可执行文件中

  ![img](https://upload-images.jianshu.io/upload_images/1802326-138e5dbcf2dd0ccf.png?imageMogr2/auto-orient/strip|imageView2/2/w/190)

  - 加载时机: 
    - App启动的时候通过dyld（动态链接器）根据依赖关系递归的加载到内存中，这样的方式称为**动态库自动加载**。但是如果动态库数量多了，会大大的拖慢应用的启动速度，因为dyld在`rebase`和`binding`阶段比较耗时。
    - 先根据配置的链接顺序加载，如有依赖的先递归式加载依赖
  - 优化
    - [手动加载](https://www.jianshu.com/p/08b0cb296278)

- 链接区分

  根据动态库的载入时间 (`load time`) 我们将动态库分为以下两种:

  - `动态链接库`: 在启动 app 时立刻将动态库进行加载 (随程序启动而启动)
  - `动态加载库`: 当需要的时候再使用 `dlopen` 等通过代码或者命令的方式来加载 (在程序启动之后)

##### 动静态库的混用

我们可以在一个项目中使用一部分动态库, 再使用一部分静态库, 如果涉及到第三方库与库之间的依赖关系时, 那么遵守如下原则:

- 静态库可以依赖静态库
- 动态库可以依赖动态库
- 动态库不能依赖静态库! 动态库不能依赖静态库是因为静态库不需要在运行时再次加载, 如果多个动态库依赖同一个静态库, 会出现多个静态库的拷贝, 而这些拷贝本身只是对于内存空间的消耗.

#### 兼容

###### Swift SDK Interface兼容

- BUILD_LIBRARY_FOR_DISTRIBUTION =》 YES



#### 组件化

[参考](https://juejin.cn/post/7067743813099323423)

- 方式

  - 基于路由 URL 的 UI 页面统跳管理（url-block)。

  - 基于反射的远程接口调用封装(target-action)。

  - 基于面向协议思想的服务注册方案（protocol-class)。

  - 基于通知的广播方案（NSNotification)。

    

#### 需求

- SDK大小
- 代码加密
  - 代码混淆
  - 三方库加密

- 日志
- 规范



#### 文档

- 环境配置
- 使用参考
  - 基础使用代码
  - Demo
- 版本记录
  - 发布
  - 修复

#### 安全

- 访问权限: 
  - swift直接用public防止override与继承
  - OC设定
    - 添加宏  不让子类集成
    - 设置单例 禁掉所有的初始化



#### 注意事项

- 所有类名都应该加前缀

  > sdk 是给别人用的，如果类名不加前缀很容易重名。重名可能导致有冲突的风险。

- 所有Category方法加前缀

  > category方法不加前缀有冲突的风险。

- 不要将第三方库打包进sdk

  - 三方库在引入项目中时, 最好使用General->Frameworks and Libraries->Embed选择do not embed, 否则三方库会被引入打出来的三方库.

  > 如果要将第三方库打包进sdk, 最好要将第三方库重命名，以避免冲突。

- 做基本的检查和测试

  > 应保证sdk中的代码没有编译错误，不应该有编译警告存在

- 文档完整并且准确

  > 文档书写应规范，正确没有错误



##### [参考](https://zhuanlan.zhihu.com/p/135315672)