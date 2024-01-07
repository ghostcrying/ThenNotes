# iOS @2x @3x图的区别和理解

[![img](https://upload.jianshu.io/users/upload_avatars/4625389/3897b10d-3249-4644-b197-2d6fa2a94749.jpeg?imageMogr2/auto-orient/strip|imageView2/1/w/96/h/96/format/webp)](https://www.jianshu.com/u/88c9838a42fd)

[yyggzc521](https://www.jianshu.com/u/88c9838a42fd)关注IP属地: 广东

22018.11.20 15:39:04字数 1,003阅读 35,897

#### 首先应明确：iOS开发是使用点作为基本单位的

*（不清楚这一点下面就会很懵逼）*

![img](https://upload-images.jianshu.io/upload_images/4625389-13bc17e9e2cd03a9.png?imageMogr2/auto-orient/strip|imageView2/2/w/551/format/webp)

屏幕快照 2018-11-20 上午9.50.53.png

![img](https://upload-images.jianshu.io/upload_images/4625389-2a61c7704cc19ec7.png?imageMogr2/auto-orient/strip|imageView2/2/w/591/format/webp)

屏幕快照 2018-11-20 下午12.55.44.png

#### 所谓的@2x、@3x就是屏幕显示模式；也可以理解为一个点等于多少个像素。@2x，就是1个点等于2个像素；同理，@3x，就是1个点等于3个像素



```objectivec
可以使用 UIScreen.main.scale (OC: [UIScreen mainScreen].scale)来获取屏幕显示模式， 1pt = ?px 的值
iPhone6中 这个值为2，iPhone6p中 这个值为3
```

> iPhone 3GS屏幕是320 x 480像素，iPhone 4是640 x 960像素，这里的像素可以想象成屏幕上真正用来显示颜色的发光小点
> iPhone 4和iPhone 3GS的屏幕尺寸是一样的，都是3.5英寸（*这里的数字是指手机屏幕对角线的物理长度*）。同样一个点看起来都是一样的。只是iPhone 4在单位英寸上像素更多，看起来更细腻

###### 文字，颜色等是矢量数据，放大不会失真,而图片并非矢量数据，所以处理方式有所不同。

比如图片 example.png，大小为 30 x 40像素（注意：单位是像素，图片的单位通常都用像素表示）。分别显示在iPhone 3GS和iPhone 4中，且大小都占据屏幕上30 x 40个点。
显示的结果是：这张图片在iPhone 4中看起来就会模糊。
这是因为iPhone 4中1个点等于2个像素，也就是30 x 40像素的图片，占据了60 x 80像素的屏幕。
所以为使得图片清晰，需要进行图片适配。就会看到工程xcassets中一张图片有3张尺寸：@1x @2x @3x



```kotlin
example.png      // 30 x 40像素
example@2x.png   // 60 x 80像素
example@3x.png   // 90 x 120像素
```

当工程中使用名字为"example"的图片时候，会根据 **屏幕模式** 自动选择对应的图片。1x模式，就会选择example.png, 2x模式就会优先选择example@2x.png，假如example@2x.png不存在，就选择example.png，同时放大2倍

#### *那么我们为什么不只用@3x图呢？*

> 只用@3x图，不同手机加载之后也只会去缩小，不但可以避免因放大而导致的模糊。而且还会引入更少的图片，减少包的大小。这么考虑也是合理，只不过会带来新的问题。👇👇👇

> 1. iPhone6加载3倍图时，首先会将3倍图数据加载到内存中，而大多数情况下，@3x图会比@2x图尺寸大一些，会造成一定的内存损耗
> 2. iPhone6在将要显示图片的时候，会将图片发送到GPU，GPU会为图片分配计算空间。如果图片大了一些，会消耗过多的GPU计算量
> 3. iPhone6加载300px * 300px (px:像素) 的图片后，图片尺寸会变成 150pt x 150pt （pt:点），如果ImageView设定的具体尺寸为100pt x 100pt，那么此时缩放会增加一些计算量

##### 总结：为了避免以上的问题，同时多引入的2种尺寸图片，对ipa包体的大小影响极小，所以还是要引入3种尺寸的图片

#### *顺便说一下网络图片如何自动适配@2x @3x？*

> 网络下载的图片，只有一种尺寸， 但是我们项目要求不同型号的iPhone显示图片大小不一样，要做到适配跟效果图高度一致

> 解决方案：
> 拿到网络图片UIImage后， 设置他的scale
> 假如你们后台上传的图片都是@3x图，那么X就设置成3， 这样当在@2x 设备上运行的时候，就自动返回 @2x 的图片对象



```csharp
[UIImage imageWithCGImage:img.CGImage withScale:X];
```