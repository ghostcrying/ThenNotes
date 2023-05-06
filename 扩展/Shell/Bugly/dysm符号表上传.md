## dysm符号表上传



> - 腾讯bugly通过curl直接网络请求上传已失效,  新的版本使用jar包进行上传.
> - 腾讯的bugly网站会出现新增开发者/管理员失败.



#### 旧版本

```
# 压缩dysm
zip -r xxx.app.dSYM.zip xxx.app.dSYM
# 上传
curl -k "https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=${BUGLY_APPKEY}&app_id=${BUGLY_APPID}" \
     --form "api_version=1" \
     --form "app_id=${BUGLY_APPID}" \
     --form "app_key=${BUGLY_APPKEY}" \
     --form "symbolType=2" \
     --form "bundleId=xxx" \
     --form "productVersion=${Version}" \
     --form "fileName=xxx.app.dSYM.zip" \
     --form "file=@xxx.app.dSYM.zip"
```



#### 新版本

```
# Bugly_Symbol_Path: 本地存储的symbol.jar路径
# inputSymbol输入的dysm文件路径
# platform: 平台
# appid: 腾讯平台申请的appid
# appkey: 腾讯平台申请的appkey
java -jar $Bugly_Symbol_Path \
     -appid $BUGLY_APPID \
     -appkey $BUGLY_APPKEY \
     -bundleid xxx \
     -version $Version \
     -platform IOS \
     -inputSymbol xxx.app.dSYM
```

