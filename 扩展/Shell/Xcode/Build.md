# xcrun



**Xcode打包上传脚本**

```
Version
Build
Scheme
XcodeProjPath: eg $PRO_PATH/$PRO_NAME.xcodeproj
ArchivePath: eg: $PRO_PATH/$PRO_NAME.xcarchive
PRO_EXPORT: 导出路径
IPAPath: 最终输出的ipa路径
```

- 前置

  ```
  xcrun agvtool new-marketing-version ${Version}
  xcrun agvtool new-version -all ${Build}
  ```

- 清理

  ```
  xcodebuild clean \
             -project $XcodeProjPath \
             -scheme $Scheme
  ```

- 构建

  > `Apple M1`芯片 自动打包问题解决方案 `Xcode 12 iOS` 打包失败
  >
  > 报错提示: `**Provisioning profile "iOS Team Provisioning Profile" doesn't include the currently selected device "xxx's MacBook Pro**`
  >
  > 解决: `archive`后新增参数`-destination 'generic/platform=iOS'`
  >
  > [参考](https://www.jianshu.com/p/6127509147de)

  ```
  xcodebuild archive \
             -project $XcodeProjPath \
             -scheme $Scheme \
             -archivePath $ArchivePath \
             -configuration Release \
             -destination 'generic/platform=iOS'
  ```

- 导出

  - 测试

    ```
    xcodebuild -exportArchive \
               -archivePath $ArchivePath \
               -exportPath "$PRO_EXPORT" \
               -exportOptionsPlist "$WORKSPACE/Cer/development/ExportOptions.plist" \
               -configuration Release \
               -allowProvisioningUpdates true
    ```

  - 线上

    ```
    xcodebuild -exportArchive \
               -archivePath "$PRO_EXPORT/$PRO_NAME.xcarchive" \
               -exportPath "$PRO_EXPORT" \
               -exportOptionsPlist "$WORKSPACE/Cer/appstore/ExportOptions.plist" \
               -configuration Release \
               -allowProvisioningUpdates true
    #校验
    xcrun altool --validate-app -f $IPAPath -t ios \
                 --apiKey $TESTFLIGHT_API_KEY \
                 --apiIssuer $TESTFLIGHT_API_ISSUER \
                 --verbose
    #上传testflight
    xcrun altool --upload-app -f $IPAPath -t ios \
                 --apiKey $TESTFLIGHT_API_KEY \
                 --apiIssuer $TESTFLIGHT_API_ISSUER \
                 --verbose
    ```
    
    

##### 提示

- 在通过脚本执行命令是, 有些路径可能需要输入密码, 可以通过以下形式解决

  ```
  # echo之后是密码, -S会主动拿到密码并执行之后的脚本
  echo "密码" | sudo -S ...
  ```

  

