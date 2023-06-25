# Unity Plugin

#### 基础

简单创建Unity项目, 下载Unity HUB => Unity, Visual Studio (不是VSCode), 创建简单项目

> 1. 打开 Unity 编辑器，并创建一个新场景或打开一个现有场景。
>
> 2. 在 Unity 编辑器中，右键单击场景层次结构视图中的一个游戏对象，选择 "Create Empty"（创建空对象）或者 "3D Object"（创建 3D 对象）来创建一个新的游戏对象。
>
> 3. 选中新创建的游戏对象，在 Unity 编辑器中选择 "Add Component"（添加组件），并选择 "New Script"（新建脚本）。
>
> 4. 在弹出的对话框中，输入脚本名称，并选择脚本语言（C#），然后单击 "Create and Add"（创建并添加）。
>
> 5. Unity 将为您创建一个新的 C# 脚本，并将其附加到您选择的游戏对象上。您可以在 Unity 编辑器中打开该脚本，并开始编写您的代码。
>
> 6. 在 C# 脚本中，进行简单的交互
>
>    ```
>    public class TestClick : MonoBehaviour {
>        void Start() {
>            Button btn = this.GetComponent<Button>();
>            btn.onClick.AddListener(OnClick);
>        }
>        private void OnClick() {
>            Debug.Log("Button Clicked. ClickHandler.");
>            #if UNITY_IOS
>            // 调用原生进行数据发送
>            string message = unityToNative("...");
>            #endif
>        }
>    }
>    ```



#### Plugin Unity <=> iOS

##### 语言

`Swift&Objc`皆可, 但都需要进行桥接, `swift`中被桥接`.m`引用的所有类都需要`@objc public`声明

##### Swift

基础桥接

```
Swift代码会自动生成桥接文件, 只需要导入通用-Swift.h即可
#import "UnityFramework/UnityFramework-Swift.h" 
```

###### framework

同样可以对Swift代码直接进行封装成framework, 通过映射形式获取项目中相关方法进而进行数据传递

此外, 不通过桥接文件, 直接在`swift`代码中通过`@_cdecl("myCFunction")`方式声明函数, 再C中直接调用即可

```
// SwiftInterface
class SwiftInterface {
#if os(iOS)
    private static var principalClass: NSObject.Type? {
        let bundlePath = Bundle.main.bundlePath.appending("/Frameworks/UnityFramework.framework")
        guard let bundle = Bundle(path: bundlePath) else { return nil }
        let principalClass = bundle.principalClass as! NSObject.Type
        return principalClass
    }
#endif

    static func sendMessage(object: String, method: String, arg: String) {
#if os(iOS)
        guard let principalClass = principalClass else { return }
        let unityFramework: NSObject = principalClass.value(forKey: "getInstance") as! NSObject
        let sendMessageToGOWithNameSelector: Selector = NSSelectorFromString("sendMessageToGOWithName:functionName:message:")
        callInstanceMethod(targetInstance: unityFramework,
                           selector: sendMessageToGOWithNameSelector,
                           argCStr1: (object as NSString).utf8String!,
                           argCStr2: (method as NSString).utf8String!,
                           argCStr3: (arg as NSString).utf8String!)
#endif
    }
#if os(iOS)
    /// 通过IMP形式进行消息发送
    private static func callInstanceMethod<T: NSObject>(targetInstance: T,
                                                        selector: Selector,
                                                        argCStr1: UnsafePointer<CChar>,
                                                        argCStr2: UnsafePointer<CChar>,
                                                        argCStr3: UnsafePointer<CChar>) {
        typealias methodType = @convention(c) (
            Any, Selector,
            // args
            UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>
        ) -> Void
        let methodImplementation: IMP = class_getMethodImplementation(type(of: targetInstance), selector)!
        let methodInvocation = unsafeBitCast(methodImplementation,
                                             to: methodType.self)
        methodInvocation(targetInstance, selector, argCStr1, argCStr2, argCStr3)
    }
#endif

#if os(iOS)
    static var rootViewController: UIViewController {
        let principalClass: NSObject.Type = principalClass!
        let unityFramework: NSObject = principalClass.value(forKey: "getInstance") as! NSObject
        let appController: NSObject = unityFramework.value(forKey: "appController") as! NSObject
        let rootViewController: UIViewController = appController.value(forKey: "rootViewController") as! UIViewController
        return rootViewController
    }
#endif
}
```

具体参考: 

- [UnityPluginXcodeTemplate](https://github.com/fuziki/UnityPluginXcodeTemplate)
- [SwiftToUnityExample](https://github.com/jwtan/SwiftToUnityExample)



##### 消息发送

消息传输过程中, 原生这边处理建议通过单例来实现, 具体问题具体处理

###### 通用

```
extern "C" {
  // unity send message to native and response
  const char* unityToNative(const char* message) {
      ...
      return ...;
  }
}
// 全局可以建立唯一的传输方法, 便于API规范, 也可以定义许多方法

// Unity的c#代码中: 声明之后再由其他方法尽心调用等处理
[DllImport("__Internal")] public static extern string unityToNative(string message);
```



###### Native => Unity

**原生**

```
#import "UnityInterface.h"  // 主要是为UnitySendMessage调用
UnitySendMessage(gameObject, method, message);
- gameObject
  - 能查找到项目实例
- method
  - gameObject的实现方法
- message
  - 发送的消息
```

**Unity**

```
// Unity的c#代码
需要保证gameObject存在, 且method已经声明
public class gameObject: MonoBehaviour {
    // method: receiveNativeMessage这个是协定方法
    public void receiveNativeMessage(string _message) {
    }
}
```



#### Plugin Unity <=> Android