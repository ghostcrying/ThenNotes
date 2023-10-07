# Carthage



#### 应用

- 选择xcframeworks

  ```
  carthage update --use-xcframeworks
  ```

- 选择平台

  ```
  carthage update --platform ios
  ```

- 避免重复构建

  ```
  carthage Update --cache-builds
  ```

- 选择本地编译环境

  ```
  carthage update --use-xcframeworks --no-use-binaries
  ```

  - 有时,当您使用较新版本的语言但依赖项是使用旧版本构建时(即使它仍然兼容),然后执行更新将产生错误。您可以使用标志解决这些情况。一个缺点是你需要更长的时间来编译项目而没有这个标志你可以简单地使用预先构建的框架(如果它可用)

- 导入

  ```
  1. build sdk (xcframeworks)
  carthage update --use-xcframeworks --platform ios 
  
  2. 进行sdk导入:
  - in General settings tab, open the Linked Frameworks and Libraries section 
  - drag the built frameworks to the Link Binaries With Libraries build phase
  ```

  

- Cathfile

  - git库

    ```
    github "SnapKit/SnapKit" ~> 5.0.0
    ```

  - 本地库(自定义服务器git)

    ```
    git "http://code.putao.io/ios_client/lottie-ios.git" "master"
    ```

    



#### 支持Carthage

> open Xcode and make sure that the [scheme is marked as *Shared*] so Carthage can discover it.
>
> 标记scheme是shared, 否则会出现没有平台问题

在项目根目录运行

```
carthage build --no-skip-current --platform ios --use-xcframeworks
carthage build --no-skip-current
# 结束后检查 Carthage->Build->iOS->xxx.framework是否存在, 即可
```

- ##### 构建SDK
  - 新版本目前不需要进行Mach-O的 static强制修改, 使用默认的dynamic即可
  - 使用的时候,   直接使用Embed && not signed

