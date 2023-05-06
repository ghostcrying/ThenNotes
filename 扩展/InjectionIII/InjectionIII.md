# InjectionIII



#### 基本使用

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    #if DEBUG
    // 把InjectionIII.app换成InjectionX.app
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
    #endif
    return true
}

# 具体页面使用
@objc func injected() {
    #if DEBUG
    self.viewDidLoad()
    #endif
}
```



#### 参考:

> - https://www.jianshu.com/p/5b881d7477f9
> - https://github.com/krzysztofzablocki/Inject