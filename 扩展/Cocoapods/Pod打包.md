# Pod打包

> 目前pod package在xocde13上失败, 未解决.



#### 基础流程

```
# 1. 首次使用cocoapods
# xxx@163.com：邮箱 xxx：用户名 xxx' macbookpro：描述
$ pod trunk register email.com --description='xxx' macbookpro' --verbose
# 下面这个也可以
# orta@cocoapods.org: 邮箱  'Orta Therox': 用户名
$ pod trunk register orta@cocoapods.org 'Orta Therox' --description='macbook air'

# 2. 接下来会收到一封邮件，点击邮件中的链接进行激活
# 查看个人信息
$ pod trunk me

# 3. 创建podspec
pod spec create xxx

# 4. 修改podspec相关配置
# 5. git操作, 提交, tag
# 6. 校验podspec, 也可以直接发布(发布)
$ pod spec lint xxx.podspec --allow-warnings

# 7. 发布
# 执行命令pod trunk push即可完成提交，该命令首先会验证你本地的podspec文件，之后会上传spec文件到trunk，最后会将上传的podspec文件转换为需要的json文件。
$ pod trunk push --allow-warnings

# 8. 之前没有发布过库, 需要认领
# 认领网站: https://trunk.cocoapods.org/claims/new

# 9. 查看库信息
$ pod trunk info xxx

# 10. 搜索
$ pod search xxx
# 检索不到处理
1. setup更新库
$ pod setup
2. 删除缓存
$ rm ~/Library/Caches/CocoaPods/search_index.json
```



自定义Pod库

```
https://gitee.com/JackYing_JY/JYBaseTableAdaptor/blob/master/自定义pod库、整合自定义pod及git使用记录.md

https://guides.cocoapods.org/making/using-pod-lib-create.html
https://guides.cocoapods.org/making/getting-setup-with-trunk.html
```



### 1. 基于pod命令创建SDK

```
pod lib create MyCustomLib
```

- 也可基于现有项目创建podspec

```
pod spec create "库名"   
```



### 2. 修改组件的.podSpec文件

```
Pod::Spec.new do |s|
  s.name             = 'BlueBots'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BlueBots.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/HyEnjoys/BlueBots'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'HyEnjoys' => 'chenzhuo@bloks.com' }
  # s.source           = { :git => 'https://github.com/HyEnjoys/BlueBots.git', :tag => s.version.to_s }
  # 本地SDK则需要进行本地路径指向
  s.source           = { :git => '/Users/admin/Desktop/笔记/Cocoapods/BlueBots' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'BlueBots/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BlueBots' => ['BlueBots/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
```

- `s.source`中是表示使用`pod package`打包时候pod去寻找的打包的路径,podspec默认使用git commit tag作为路径,也可以修改成本地路径`/Users/admin/Desktop/笔记/Cocoapods/BlueBots`,如果当前没有设置`:tag`,打包时候默认使用当前git commit的head节点(如果部分修改内容没有commit,那么使用`git package`不会将未commit的内容进行打包).
- `s.source_files`表示具体的源码的路径,这里注意源码一般放到`Classes`文件夹目录下,而且实体文件中不要有非源码内容放到`Classes`文件夹.Classes文件夹的所有内容都要`Add Targets To: MyCustomLib`.不要`Classes`文件夹或子文件夹中部分内容被`remove referrence`.
- `s.resource_bundles`中的资源.系统会自动将`MyCustomLib/Assets`文件夹下的内容,cocoapod会将我们把`Assets`中的内容自动打包成`MyCustomLib.bundle`.这里也可以使用简单的方式
  - 1 在`Assets`文件夹中放入我们自己写好的`MyCustomLib.bundle`,bundle中是我们使用的资源.
  - 2 使用 `s.resource = 'MyCustomLib/Assets/*'`.最后会将这些资源打入framework中.
  - 3 在Example中手动引用我们自己创建的*.bundle资源文件.
- `s.public_header_files`用来指定需要对外部暴露的头文件的位置
- `s.frameworks`和`s.libraries`,表示当前sdk依赖的系统的framework和类库
- `s.dependency`表示当前podspec类库对外部第三方库的依赖.如果使用`pod package`打包sdk时候,这里的dependency会被自动添加前缀,防止重复引用冲突.而且这里的依赖只能是pod库(公有或者私有)的内容.
- `s.subspec`用来引入我们sdk依赖的自己的framework或者.a等静态库



### 3. 提交代码到远程

```
 git remote add origin https://github.com/HyEnjoys/BlueBots

git push -u origin master (如果报错可尝试用 git push -u origin master -f 可能会覆盖远程的修改)
git add .（记得后面一定要有 .）
git commit -am "提交代码"
git push -u origin master
git tag 0.1.0
git push --tags
注意: 这里的tag号必须和.podSpec文件的版本号一致
```



### 4. 对文件进行本地验证和远程验证

```
pod lib lint --allow-warnings
--allow-warnings 通过警告
```



### 5. 打包framework

- 安装插件cocoapods-packager

```
sudo gem install cocoapods-packager
```

- 打包

```
# 打包.frameworks
pod package BlueBots.podspec --force --verbose

# 打包.a
pod package BlueBots.podspec --library --force --verbose

//强制覆盖之前已经生成过的二进制库 
--force

//生成静态.framework 
--embedded

//生成静态.a 
--library

//生成动态.framework 
--dynamic

//动态.framework是需要签名的，所以只有生成动态库的时候需要这个BundleId 
--bundle-identifier

//不包含依赖的符号表，生成动态库的时候不能包含这个命令，动态库一定需要包含依赖的符号表。 
--exclude-deps

//表示生成的库是debug还是release，默认是release。--configuration=Debug 
--configuration


--no-mangle
//表示不使用name mangling技术，pod package默认是使用这个技术的。我们能在用pod package生成二进制库的时候会看到终端有输出Mangling symbols和Building mangled framework。表示使用了这个技术。
//如果你的pod库没有其他依赖的话，那么不使用这个命令也不会报错。但是如果有其他依赖，不使用--no-mangle这个命令的话，那么你在工程里使用生成的二进制库的时候就会报错：Undefined symbols for architecture x86_64。

--subspecs

//如果你的pod库有subspec，那么加上这个命名表示只给某个或几个subspec生成二进制库，--subspecs=subspec1,subspec2。生成的库的名字就是你podspec的名字，如果你想生成的库的名字跟subspec的名字一样，那么就需要修改podspec的名字。 
这个脚本就是批量生成subspec的二进制库，每一个subspec的库名就是podspecName+subspecName。

--spec-sources
//一些依赖的source，如果你有依赖是来自于私有库的，那就需要加上那个私有库的source，默认是cocoapods的Specs仓库。--spec-sources=private,https://github.com/CocoaPods/Specs.git。 可以跟多个，多个逗号隔开

```



### BUG

- SDK中依赖的第三方库无法使用BITCODE

  ```
  在Example的podfile底部添加以下语句:
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['ENABLE_BITCODE'] = 'NO'
          end
      end
  end
  ```

- SDK调用资源

  ```
  由于最后打包时候有可能打出来的包是动态库,那么建议通过如下方式调用资源:
  
  // Load the framework bundle.
  + (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
      NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
      NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Serenity.bundle"];
      frameworkBundle = [[NSBundle bundleWithPath:frameworkBundlePath] retain];
    });
    return frameworkBundle;
  }
  
  [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"image" ofType:@"png"]];
  ```

- 私有库

  ```
  如果自己的某个sdk的podspec文件中的dependency并未上传到公有或者私有pod库中.紧紧是使用的本地的podspec库.那么此时不能使用pod package打包成功.但是可以通过编写podfile方式,在Example中集成sdk.具体在podfile中需要手动写入需要引入的podspec的地址,而且两者有引入的顺序要求.
  
  举例说明, 如果我们有一个主工程Downloader,它使用一个子库Player,这个Player子库依赖另外一个库FFMpegPlayer.在Player的podspec中的依赖只能写成s.dependency = 'FFMpegPlayer'(虽然有可能FFMpegPlayer库并没有提交到公有或者私有pod库中,这种写法是满足的).同时在我们的Example Downloader的podfile中需要按照顺序写入引入的库:
  
  pod 'FFMpegPlayer', :path => '../FFMpegPlayer' (micro project)
  pod 'Player', :path => '../Player' (small project which depends on FFMpegPlayer)
  一定要注意顺序!!!!!
  
  注意,这里如果要使用pod package打包Player库会失败.
  ```

- swift_version问题

  ```
  - ERROR | [iOS] swift: Specification `\**` specifies an inconsistent `swift_version` (`4.2`) compared to the one present in your `.swift-version` file (`4.0`). Please remove the `.swift-version` file which is now deprecated and only use the `swift_version` attribute within
  your podspec.
  ```

  - 制作pod私有库时，出现这个错误原因主要是 在podspec文件中指定了 s.swift_version，并且在本地还创建了.swift-version这个文件，这两处指定版本不同就会出现问题。
  - 出现这个问题主要是因为网上很多文章在指定swift_version版本时解释不清楚，大部分文章都会直接说pod库指定版本时两种做法：第一点在 .podspec文件中直接s.swift_version='4.0',第二就是`echo "4.0" > .swift-version`。
  - 其实这两条解决方案没有任何问题，出现问题的是这两点不能同时做，如果同时做了，并且指定版本不同时就会一直验证不过，报错！
  - 知道了原因就很好解决了，要么删掉.swift-version文件，要么.podspec文件中不指定版本，这时需要注意的一点是.swift-version文件是隐藏文件，不要以为文件夹中没有就是没有，你需要ls -a 一下就能看到