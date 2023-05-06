# Flutter常见错误



##### 1. This class (or a class that this class inherits from) is marked as '@immutable', but one or more of its instance fields aren't final: ExploreBaseInfo.scrollController

> 添加关键字final后解决



##### 2. This method overrides a method annotated as '@mustCallSuper' in 'AutomaticKeepAliveClientMixin', but doesn't invoke the overridden method.

> 当为了实现页面keepalive，使用了AutomaticKeepAliveClientMixin方法
>
> 子类必须实现[wantKeepAlive]，并且它们的[build]方法必须调用super.build（返回值始终返回null，应将其忽略） 

![img](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e04533a7322a44e3b195d5fb3b20299e~tplv-k3u1fbpfcp-watermark.image)

```dart
  @override
  Widget build(BuildContext context) {
    super.build(context);    // 调用super.build(返回值始终返回null，应将其忽略)
    return onBuild(context);
  }
```



##### 3. This function has a return type of 'Widget', but doesn't end with a return statement.

> 当widget里有判断返回对应的内容时,没有以return语句结尾 

![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/afbc612ea8884d95b90e16b3729a3b71~tplv-k3u1fbpfcp-watermark.image)

更改：

```dart
Widget itemWidget(int type) {
  if (type == 0) {
    return Container(
        margin: EdgeInsets.only(right: px(0)),
        child: Text("空闲中",
            style: TextStyle(
                color: XColor.logisCon,
                fontSize: px(12),
                fontWeight: FontWeight.bold)));
  } else if (type == 1) {
    return Container(
        margin: EdgeInsets.only(right: px(0)),
        child: Text("操作中",
            style: TextStyle(
                color: XColor.red_F5222D,
                fontSize: px(12),
                fontWeight: FontWeight.bold)));
  }
  return Container();  // 您需要从此处返回任何小部件,您也可以使用CircularProgressIndicator（）
}
```



##### 4. Avoid using braces in interpolation when not needed

> 模版字符串，变量包裹问题：当后面没有紧跟的字母时，避免使用花括号

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ec9ab2f1c0d64e8dbce28b696804509c~tplv-k3u1fbpfcp-watermark.image)

更改：

```dart
log("stock_list:${list.length}");    
log("stock_list:$list");           // 在标识符后面没有紧跟的字母时，避免使用花括号
log("model=$model,type= $type");
```



##### 5. type '_InternalLinkedHashMap<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>'

> 这是类型不对问题导致的: 把Map换成了 var  就好了。



##### 6. Waiting for another flutter command to release the startup lock...

> flutter指令调用后出现该提示, 然后无论重启IED还是咋滴都解决不了问题.
>
> 解决: 找到flutter包--->bin--->cache--->lockfile, 将lockfile文件删掉即可



##### 7. Flutter本地图片不显示问题

> 报错: Exception caught by image resource service Unable to load asset: assets/images/type_travelgroup.png

![](https://upload-images.jianshu.io/upload_images/1658521-6645c69b0271eb8c.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

Flutter 中添加静态资源很简单，将静态资源放置在任意目录（通常是根目录下的 assets 文件夹中），然后在配置文件中 pubspec.yaml 中指定即可。每个 asset 都通过相对于 pubspec.yaml 文件所在位置的路径进行标识

- 在pubspec.yaml 添加路径

```undefined
  assets:
   - assets/images/
   - assets/json/
```

![img](https:////upload-images.jianshu.io/upload_images/1658521-5471d53c7d2491ea.png?imageMogr2/auto-orient/strip|imageView2/2/w/708)



##### 8. _TypeError (type 'double' is not a subtype of type 'int')

> 打全局断点的时候报错
> 说明定义的模型和服务器返回的类型不一致。将模型改变与服务器对应的类型即可



##### 9. Don't import implementation files from another package.

> 导入import 'package:provider/src/provider.dart';路径出错, 
>
> 应该是import 'package:provider/provider.dart'; 主路径即可.



##### 10. Failed assertion: line 319 pos 15: 'color == null || decoration == null'

![img](https:////upload-images.jianshu.io/upload_images/1658521-a49e2569c81d0499.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

图片.png

> 上面文字的意思是，container 这个容器组件中 color 和decoration不能同时存在。注释掉其中一个就可以了



##### 11. Waiting to be able to obtain lock of Flutter binary artifacts directory: /usr/local/Caskroom/flutter/2.5.0/flutter/bin/cache/lockfile

> 直接去该目录下删除该文件重新运行.

