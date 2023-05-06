# lipo



### SDK的架构

#### 查看

##### frameworks

```
lipo -info xxx.framework/xxx
```

##### library

```
lipo -info xxx.a
```

#### 结构

```
i386 x86_64 armv7 armv7s arm64
```



#### 移除结构

```
lipo -remove 架构类型(i386/x86_64/armv7/armv7s/arm64) xxx.framework/xxx -o xxx.framework/xxx

eg: lipo -remove x86_64 AipBase.framework/AipBase -o AipBase.framework/AipBase
```



#### xcframeworks

> 现在xcode不允许使用多架构的frameworks直接引入, 需要使用xcframeworks

```
xcodebuild -create-xcframework \
           -framework My-iOS.framework \
           -framework My-iOS_Simulator.framework \
           -output My.xcframework
```



参考: https://juejin.cn/post/6844903970893201416