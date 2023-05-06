## Flutter Package



#### 原生与Flutter交互

##### Flutter采用 MethodChannel

```
static const platform = const MethodChannel('samples.flutter.io/sample');
try {
  final dynamic result = await platform.invokeMethod('test1');
  print(result.toString());
} on PlatformException catch (e) {
  batteryLevel = "Failed to get battery level: '${e.message}'.";
  print("Failed to get test1 result: '$(e.message)'");
}
```

##### iOS原生响应

```
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self);

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let channel = FlutterMethodChannel(name: "samples.flutter.io/battery", binaryMessenger: controller);
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
          if ("test1" == call.method) {
              result(1)
            } else {
              result(FlutterMethodNotImplemented)
            }
    });

    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
  }
}
```

##### Android原生响应

```
在main.activity中
class MainActivity() : FlutterActivity() {
  private val CHANNEL = "samples.flutter.io/sample"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "test1") {
        result.success(10)
        result.error("UNAVAILABLE", "Test1 method not available.", null)
      } else {
        result.notImplemented()
      }
    }
  }
}
```



#### 创建项目

- **Visual Studio Code**

  ```
  1. 安装Flutter插件
  2. 运行Flutter doctor -v
  3. command+shift+p调出窗口, 选择new project进而选择创建Application/Package...
  ```

- **终端**

  ```
  1. brew install flutter
  2. flutter doctor -v
  3. 指定目录创建项目
  - flutter create --template=plugin --platforms=android,ios -i swift -a java xxx(插件名)
    - --template=plugin：创建插件
      - 默认使用application
    - --platforms=android,ios: 指定平台(不指定平台，不会生成IOS、Android文件夹)
      - package不支持platforms选择
    - -i objc -a java：指定ios和安卓的语言
      - flutter1.9+后默认的iOS项目为swift, Android的默认项目为kotlin
      - ios语言: swift/objc
      - android语言: kotlin/java
  ```

  

#### Plugin

> 自定义的三方库最好都要支持x86, 因为flutter的热更调试在模拟器上直接运行更加方便.

##### iOS

> 目前针对Swift为主语言的插件, 使用Objc的三方库, 暂未解决如何添加桥接文件,  后续验证补充



###### 三方库依赖

- ios/xxx.podspec

  - s.platform版本支持

  - s.dependency三方库支持

    - example: s.dependency 'AFNetworking'

      

###### 友盟分享

```
1. 友盟分享的配置依旧使用原生单独, 也可使用脚本一键配置.
2. 另外dependency: 
    s.dependency 'UMCommon'
    s.dependency 'UMDevice'
    s.dependency 'UMShare/Social/WeChat'
    s.dependency 'UMShare/Social/Sina'
    s.dependency 'UMShare/Social/QQ'
    s.static_framework = true # use_frameworks！如果指定，则pod应当包含静态库框架。
3. s.static_framework = true 会出现文件资源只能指定一种的情况
- s.static_framework = true, 那么资源文件就只能指定一个, 你指定多个文件类型, 然而会只保留一个文件类型, - 解决方案: 把资源文件都分离出来, 弄成一个库, 然后用主项目(s.static_framework = true)依赖这个资源库就可以用所有资源了

4. 友盟的配置
- 友盟三方库是oc库, 因此需要使用oc的plugin库进行集成
- 友盟出现不能跳转回来的bug是因为handleOpenURL这一系列为处理导致的
#pragma mark - FlutterApplicationLifeCycleDelegate
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [UMSocialManager.defaultManager handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [UMSocialManager.defaultManager handleOpenURL:url options:options];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [UMSocialManager.defaultManager handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler {
    return [UMSocialManager.defaultManager handleUniversalLink:userActivity options:nil];
}
```



###### 阿里云一键登陆

```
使用本地三方库: 
s.frameworks = 'YTXOperators', 'YTXMonitor', 'ATAuthSDK'
# 添加自定义Path配置
s.xcconfig = {
  'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../Frameworks"'
}

* 为什么使用三方库直接引用: 在测试期间发现, 阿里云偶尔会出现在电信卡上无法拉起的bug, 后期改为本地三方库使用才解决, 暂未发现是是很么问题.
```



###### 自定义库

```
# 自定义的库, 可以多个由(逗号),分开
s.vendored_frameworks = 'UnityFramework.xcframework'
# 添加自定义Path配置(也可以后期手动添加, 但是不友好)
s.xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../Frameworks" "${PODS_CONFIGURATION_BUILD_DIR}"',
    'OTHER_LDFLAGS' => '$(inherited) -framework UnityFramework ${PODS_LIBRARIES}'
 }

# 该库的特殊性在于, 引入库的时候, 用Unity的视图替换了原始的window视图, 因此会导致有些库查找基础rootcontroller失败
- 使用UIApplication.sharedApplication.delegate.window查找基础window
- (UIViewController *)viewControllerWithWindow:(UIWindow *)window {
    UIWindow *windowToUse = window;
    if (windowToUse == nil) {
        if (@available(iOS 14.0, *)) {
            NSArray<UIWindow*> *windows = [UIApplication sharedApplication].windows;
            for (UIWindow *window in windows) {
                if (window.isKeyWindow) {
                    windowToUse = window;
                    break;
                }
            }
        } else {
            windowToUse = UIApplication.sharedApplication.delegate.window;
        }
    }
    UIViewController *topController = windowToUse.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
```



###### 插件使用

- 指定
  - example: dio: ^4.0.0  # 网络

- 自定义的插件更新建议进行版本的指定

  ```
  # 这种指定是基础的
  flutter_zxing: 
      git: http://code.putao.io/ios_client/flutter_zxing.git
  # 通过tag进行强指定, 可以避免缓存导致问题   
  flutter_umshare: 
      git:
        url: http://code.putao.io/ios_client/flutter_umshare
        ref: '1.0.2'
  ```

  

##### 错误

**三方库跳转插件无法返回的问题**

- 
