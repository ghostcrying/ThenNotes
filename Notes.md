# Notes



```
fno-objc-arc
```



#### 分享

```
- 微信分享SDK不审不需要校验Universal link, 即使link不通过也可分享成功, 但是友盟分享集成微信分享后会校验link, 只有link ok后才可以进行完整的分享流程
- QQ分享需要QQ互联设置
- apple-app-site-association文件格式必须跟苹果要求的保持一致(下面是范例)
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "C6SC3439YS.com.putao.block",
                "paths": [ "/applinks/buluke/appstore/*" ]
            },
            {
                "appID": "SMZF8K86LM.com.bloks.block",
                "paths": [ "/applinks/bloks/appstore/*", "/qq_conn/1112158918/*" ]
            },
            {
                "appID": "W395RC57B2.com.putao.block.inhouse",
                "paths": [ "/applinks/buluke/appstore/*" ]
            }
        ]
    }
}
```



#### Swift版本

```
参考链接:
- https://www.huntsbot.com/qa/om3O
- https://developer.apple.com/support/xcode/

Xcode 15     : Swift version 5.9
Xcode 14.3.1 : Swift version 5.8.1
Xcode 14.3   : Swift version 5.8
Xcode 14.0   : Swift version 5.7
Xcode 13.3   : Swift version 5.6
Xcode 13.2   : Swift version 5.5.2
Xcode 12.5   : Swift version 5.4.2
Xcode 12.3   : Swift version 5.3.2
Xcode 12.2   : Swift version 5.3.1
Xcode 11.6   : Swift version 5.2.4
Xcode 11.5   : Swift version 5.2.4
Xcode 11.4   : Swift version 5.2
Xcode 11.3   : Swift version 5.1.3
Xcode 11.2.1 : Swift version 5.1.2
Xcode 11.1   : Swift version 5.1
Xcode 11.0   : Swift version 5.0
Xcode 10.0   : Swift version 4.2
Xcode 9.0    : Swift version 4.0
# 
# 当前大部分Xcode都是11版本以上, 因此代码适配可以只参照swift4.2与swift5做出区别即可
# 最新Xcode 14.xxx

#if swift(>=5.1)
    print("hello, Swift 5.1")
#elseif swift(>=5.0)
    print("hello, Swift 5.0")
#elseif swift(>=4.2)
    print("hello, Swift 4.2")
#elseif swift(>=4.0)
    print("hello, Swift 4.0")
#endif

***项目崩溃dyld: Library not loaded: @rpath/libswiftCore.dylib && reason: image not found
- 网上通用的处理方式
  - 直接修改ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=YES
  - 修改Build Settings -> Linking -> Runpath Search Paths 加上 ”/usr/lib/swift"文本
  - 修改Swift支持的版本为4/4.2/5, 选择下低版本即可
    - 但是需要适配语言版本带来的编译错误修改(可以通过swift版本判定进行代码适配)
- 实际测试中发现
  - 再Pod之后很多项目已经带有相对路径的path(/usr/lib/swift), 而且embed_swift_standard_libraries=true, 但是依然会出现崩溃
    - 此时修改Swift版本为4.2或者4.0, 之后编译运行OK, 恢复版本号到Swift5.0则可以正常使用了
    - 其实直接修改swift版本可以运行Ok
- 参考帖子
    - https://stackoverflow.com/questions/26024100/dyld-library-not-loaded-rpath-libswiftcore-dylib/69852407#69852407
    - https://blog.csdn.net/sking2018/article/details/122558831
```



#### 网络测试

##### charles使用

> 模拟网络请求
>
> 参考: https://blog.csdn.net/Lu_GXin/article/details/106492466

##### Atlantis

```
- 原生网络统计
- https://github.com/ProxymanApp/atlantis
- 原生WKWebView在独立于app进程之外的进程中执行网络请求，请求数据不经过主进程; 而通常网络监控都是针对App主进程进行监控, 并不对针对系统层级监控;
- 由于WKWebView和App不在同一个进程，如果WKWebView进程崩溃并不会导致应用崩溃，仅仅是页面白屏等异常。页面的载入、渲染等消耗内存和性能的操作，都在WKWebView的进程中处理，处理后再将结果交给App进程用于显示，所以App进程的性能消耗会小很多
```

##### Mocky(网络模拟)

> 参考: https://run.mocky.io/v3/4cd6a924-a4a9-4b02-9454-b47f7d300748



#### Pod库自定义

```
https://gitee.com/JackYing_JY/JYBaseTableAdaptor/blob/master/自定义pod库、整合自定义pod及git使用记录.md
```



#### M1芯片适配

##### 模拟器运行BUG

```
- 部分项目在M1芯片上无法运行Xcode Simulator(模拟器), 只可以真机运行
  - Project => Build Settings => Excluded Architectures 增加arm64配置即可
- 参考: https://juejin.cn/post/6920218654013407246
```



#### InjectionIII

仅适用于模拟器

```
# https://www.jianshu.com/p/5b881d7477f9
# https://github.com/krzysztofzablocki/Inject
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    #if DEBUG
    // 把InjectionIII.app换成InjectionX.app
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
    #endif
    return true
}
```



#### Async适配

```
https://github.com/sideeffect-io/AsyncExtensions.git
https://github.com/freshOS/Then.git
```



#### Mac Local Server

```
`/Library/WebServer/Documents`
sudo apachectl start
sudo apachectl stop
sudo apachectl restart
```



#### Flutter-MacOS

```
# 貌似有问题, 需要继续深入
# 参考: https://github.com/GroovinChip/macos_ui

$ brew tap felangel/mason
$ brew install mason
$ mason add -g macosui_starter

# 指定文件目录
$ mason make macosui_starter
```



#### 其他相关记录

###### Tableview联动

- https://www.jianshu.com/p/4e6ed002dfc6/

###### 埋点

- https://www.jianshu.com/p/7896e20eee34

###### git pull出问题

- https://www.jianshu.com/p/bc60c8b04bc5

###### 查询Mac公网IP地址

```
# https://blog.csdn.net/qq_20042935/article/details/122034299
$ curl ifconfig.me
```

###### GIF

- 测试中发现: Kingfisher已经修改了加载逻辑, 增加了缓存功能

###### OpenAIKit
- GPT-3 available
- https://github.com/MarcoDotIO/OpenAIKit
- 模型训练

###### 随机图片网址
- https://source.unsplash.com/random

###### UMeng快应用
- https://developer.umeng.com/docs/119267/detail/92733
