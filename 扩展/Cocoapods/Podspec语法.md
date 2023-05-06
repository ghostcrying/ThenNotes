# Podspec语法

### Example

```
Pod::Spec.new do |spec|
  spec.name          = 'Reachability'
  spec.version       = '3.1.0'
  spec.license       = { :type => 'BSD' }
  spec.homepage      = 'https://github.com/tonymillion/Reachability'
  spec.authors       = { 'Tony Million' => 'tonymillion@gmail.com' }
  spec.summary       = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source        = { :git => 'https://github.com/tonymillion/Reachability.git', :tag => 'v3.1.0' }
  spec.module_name   = 'Rich'
  spec.swift_version = '4.0'

  spec.ios.deployment_target  = '9.0'
  spec.osx.deployment_target  = '10.10'

  spec.source_files       = 'Reachability/common/*.swift'
  spec.ios.source_files   = 'Reachability/ios/*.swift', 'Reachability/extensions/*.swift'
  spec.osx.source_files   = 'Reachability/osx/*.swift'

  spec.framework      = 'SystemConfiguration'
  spec.ios.framework  = 'UIKit'
  spec.osx.framework  = 'AppKit'

  spec.dependency 'SomeOtherPod'
end
```



## 一、Root specification相关

root规范存储了相关库特定版本的信息。

下面的属性只能写在root规范上，**而不能写**在“sub-spec”上。

### 1、必须的字段

#### . name

```
spec.name = 'AFNetworking'
```

pod search 搜索的关键词，这里一定要和.podspec的名称一样，否则会报错；

#### . version

Pod最新的版本。

#### . authors

```
spec.author = 'Darth Vader'
spec.authors = 'Darth Vader', 'Wookiee'
spec.authors = { 'Darth Vader' => 'darthvader@darkside.com',
                 'Wookiee'     => 'wookiee@aggrrttaaggrrt.com' }
```

库维护者（而不是Podspec维护者）的名称和电子邮件地址。

#### . license

```
spec.license = 'MIT'
spec.license = { :type => 'MIT', :file => 'MIT-LICENSE.txt' }
spec.license = { :type => 'MIT', :text => <<-LICENSE
                   Copyright 2012
                   Permission is granted to...
                 LICENSE
               }
```

Pod的许可证

除非源中包含一个名为`LICENSE.*`或`LICENCE.*`的文件，**否则**必须指定许可证文件的路径**或**通常用于许可证类型的通知的完整文本。如果指定了许可文件，它要么必须是没有文件扩展名或者是一个`txt`，`md`或`markdown`。

#### . homepage

```
spec.homepage = 'http://www.example.com'
```

Pod主页的URL

#### . source

检索库的位置

1、使用标签指定Git来源。多数Podspecs是这样写的。

```
spec.source = { :git => 'https://github.com/AFNetworking/AFNetworking.git',
                :tag => spec.version.to_s }
```

2、使用以'v'和子模块为前缀的标签。

```
spec.source = { :git => 'https://github.com/typhoon-framework/Typhoon.git',
                :tag => "v#{spec.version}", :submodules => true }
```

3、使用带标记的Subversion。

```
spec.source = { :svn => 'http://svn.code.sf.net/p/polyclipping/code', :tag => '4.8.8' }
```

4、使用与规范的语义版本字符串相同版本的Mercurial。

```
spec.source = { :hg => 'https://bitbucket.org/dcutting/hyperbek', :revision => "#{s.version}" }
```

5、使用HTTP下载代码的压缩文件。它支持zip，tgz，bz2，txz和tar。

```
spec.source = { :http => 'http://dev.wechatapp.com/download/sdk/WeChat_SDK_iOS_en.zip' }
```

6、使用HTTP下载文件，并使用哈希来验证下载。它支持sha1和sha256。

```
spec.source = { :http => 'http://dev.wechatapp.com/download/sdk/WeChat_SDK_iOS_en.zip',
                :sha1 => '7e21857fe11a511f472cfd7cfa2d979bd7ab7d96' }
```

我们一般比较常用的就是方式1了，也有2和3

#### . summary

```
spec.summary = 'Computes the meaning of life.'
```

简短说明（最多140个字符），该摘要应适当大写并包含正确的标点符号。

### 2、选填字段

#### . swift_versions

```
spec.swift_versions = ['3.0']
spec.swift_versions = ['3.0', '4.0', '4.2']
spec.swift_version = '3.0'
spec.swift_version = '3.0', '4.0'
```

支持的Swift版本。CocoaPods将版本“ 4”视为“ 4.0”，而不是“ 4.1”或“ 4.2”。

**注意** Swift编译器主要接受主要版本，有时会接受次要版本。尽管CocoaPods允许指定次要版本或补丁版本，但Swift编译器可能不会完全认可它。

我们一般是直接指定版本

#### . cocoapods_version

```
spec.cocoapods_version = '>= 0.36'
```

所支持的CocoaPods版本，比如某个属性，是某个cocoapods版本以上才有的，这个时候进行依赖安装，就需要指定版本。

#### . social_media_url

```
spec.social_media_url = 'https://twitter.com/cocoapods'
spec.social_media_url = 'https://groups.google.com/forum/#!forum/cocoapods'
```

Pod、CocoaPods Web服务的社交媒体联系人的URL可以使用此URL。

#### . description

```
spec.description = <<-DESC
                     Computes the meaning of life.
                     Features:
                     1. Is self aware
                     ...
                     42. Likes candies.
                   DESC
```

比摘要更详细的说明，用这个字段

#### . screenshots

```
spec.screenshot  = 'http://dl.dropbox.com/u/378729/MBProgressHUD/1.png'
spec.screenshots = [ 'http://dl.dropbox.com/u/378729/MBProgressHUD/1.png',
                     'http://dl.dropbox.com/u/378729/MBProgressHUD/2.png' ]
```

展示Pod图片的网址列表。用于面向UI库。CocoaPods建议使用`gif`格式。

#### . documentation_url

```
spec.documentation_url = 'http://www.example.com/docs.html'
```

Pod文档的可选URL，CocoaPods网络媒体资源将使用该URL。将其保留为空白将默认为您的库CocoaDocs生成URL。

#### . prepare_command

```
spec.prepare_command = 'ruby build_files.rb'
spec.prepare_command = <<-CMD
                        sed -i 's/MyNameSpacedHeader/Header/g' ./**/*.h
                        sed -i 's/MyNameOtherSpacedHeader/OtherHeader/g' ./**/*.h
                   CMD
```

下载Pod后将执行的bash脚本。该命令可用于创建，删除和修改下载的任何文件，并且将在收集规范其他文件属性的任何路径之前运行。

在清理Pod和创建Pods项目之前，将执行此命令。工作目录是Pod的根目录。

如果pod安装了该`:path`选件，则不会执行此命令。

#### . static_framework

```
spec.static_framework = true
```

use_frameworks！如果指定，则pod应当包含静态库框架。

#### . deprecated

是否已废弃该库。

#### . deprecated_in_favor_of

```
spec.deprecated_in_favor_of = 'NewMoreAwesomePod'
```

不支持使用的Pod名称。



## 二、Platform相关

主要是指明支持当前库的平台和相应的部署target。

#### . Platform

```
spec.platform = :osx, '10.8'
spec.platform = :ios
spec.platform = :osx
```

支持此Pod的平台。保留此空白表示Pod在所有平台上都支持。当支持多个平台时，应改为使用以下deployment_target。

#### . deployment_target

```
spec.ios.deployment_target = '6.0'
spec.osx.deployment_target = '10.8'
```

支持平台的最低部署target。

与`platform`属性相反，`deployment_target` 属性允许指定支持该Pod的多个平台-为每个平台指定不同的部署目标。

## 三、Build settings相关

构建环境的配置相关设置

#### . dependency

```
spec.dependency 'AFNetworking', '~> 1.0'
spec.dependency 'AFNetworking', '~> 1.0', :configurations => ['Debug']
spec.dependency 'AFNetworking', '~> 1.0', :configurations => :debug
spec.dependency 'RestKit/CoreData', '~> 0.20.0'
spec.ios.dependency 'MBProgressHUD', '~> 0.5'   
```

对其他Pod或“sub-spec”的依赖。依赖关系可以指定版本要求。

#### . info_plist

```
spec.info_plist = {
  'CFBundleIdentifier' => 'com.myorg.MyLib',
  'MY_VAR' => 'SOME_VALUE'
}
```

要添加到生成的键值对`Info.plist`。

这些值将与CocoaPods生成的默认值合并，从而覆盖所有重复项。

对于库规范，值将合并到为使用框架集成的库生成的Info.plist中。它对静态库无效。

不支持sub-spec（应用和测试spec除外）。

对于应用程序规范，这些值将合并到应用程序主机的中`Info.plist`。

对于测试spec，这些值将合并到测试包的中`Info.plist`。

#### . requires_arc

```
spec.requires_arc = true 

spec.requires_arc = false
spec.requires_arc = 'Classes/Arc'
spec.requires_arc = ['Classes/*ARC.m', 'Classes/ARC.mm']
```

允许您指定使用ARC的source_files。它可以是支持ARC的文件，也可以是true，以表示所有source_files都使用ARC。

不使用ARC的文件将带有`-fno-objc-arc`编译器标志。

此属性的默认值为`true`。

#### . frameworks

```
spec.ios.framework = 'CFNetwork'
spec.frameworks = 'QuartzCore', 'CoreData'
```

当前target所需系统framework列表

#### . weak_frameworks

```
spec.weak_framework = 'Twitter'
spec.weak_frameworks = 'Twitter', 'SafariServices'
```

当前target所需“弱引用”的framework列表, 

```
为什么我们使用最新的SDK开发的应用却可以运行在旧的系统中呢？答案是使用了弱引用。资料里面说过，我们自己创建的framework，如果需要做版本兼容，那么就要对今后加入的符号等使用弱引用，使用了弱引用之后，即使在版本较旧的环境下跑，也可以运行，只是相应的符号是NULL，下面就是教我们怎样定义弱引用。有一点需要说明的是，如果一个framework没有为新加入的符号加入弱引用，那也不必担心，我们只要在链接时弱引用整个framework就好，方法就是链接的时候使用 -weak_framework frameworkName
```



#### . libraries

```
spec.ios.library = 'xml2'
spec.libraries = 'xml2', 'z'
```

当前target所需系统library列表

#### . compiler_flags

```
spec.compiler_flags = '-DOS_OBJECT_USE_OBJC=0', '-Wno-format'
```

传递给编译器的flag

#### . pod_target_xcconfig

```
spec.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
```

要添加到最终**私有** pod目标xcconfig文件的任何标志。

#### . user_target_xcconfig

不推荐使用

#### . prefix_header_contents

不推荐使用

#### . prefix_header_file

不推荐使用

#### . module_name

```
spec.module_name = 'Three20'
```

用于该spec的框架/ clang模块的名称，而不是默认的名称（如果设置，则为header_dir，否则为规范名称）。

#### . header_dir

```
spec.header_dir = 'Three20Core'
```

头文件的存储目录。

#### . header_mappings_dir

```
spec.header_mappings_dir = 'src/include'
```

用于保留头文件的文件夹结构的目录。如果未提供，则将头文件展平。

#### . script_phases

```
spec.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"' }
spec.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"', :execution_position => :before_compile }
spec.script_phase = { :name => 'Hello World', :script => 'puts "Hello World"', :shell_path => '/usr/bin/ruby' }
spec.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"',
  :input_files => ['/path/to/input_file.txt'], :output_files => ['/path/to/output_file.txt']
}
spec.script_phase = { :name => 'Hello World', :script => 'echo "Hello World"',
  :input_file_lists => ['/path/to/input_files.xcfilelist'], :output_file_lists => ['/path/to/output_files.xcfilelist']
}
spec.script_phases = [
    { :name => 'Hello World', :script => 'echo "Hello World"' },
    { :name => 'Hello Ruby World', :script => 'puts "Hello World"', :shell_path => '/usr/bin/ruby' },
  ]
```

此属性允许定义脚本，以作为Pod编译的一部分执行。与prepare命令不同，脚本作为`xcodebuild`的一部分执行，也可以利用在编译期间设置的所有环境变量。

Pod可以提供要执行的多个脚本，并且将按照声明的顺序添加它们，并考虑它们的执行位置设置。

**注意** 为了提供对所有脚本内容的可见性和意识，如果安装了Pod包含任何脚本，则会在安装时向用户显示警告。

## 四、File patterns相关

文件路径相关设置；不支持遍历父目录

- `*` 匹配所有文件
- `c*` 匹配所有以`c`开头的文件
- `*c` 匹配所有以`c`结尾的文件
- `*c*` 将匹配其中包含`c`的所有文件（包括开头或结尾）

#### . source_files

```
spec.source_files = 'Classes/**/*.{h,m}'
spec.source_files = 'Classes/**/*.{h,m}', 'More_Classes/**/*.{h,m}'
```

需要包含的源文件

#### . public_header_files

```
spec.public_header_files = 'Headers/Public/*.h'
```

用作公共头的文件模式列表。

这些模式与源文件匹配，以包含将公开给用户项目并从中生成文档的标头。构建库时，这些头将出现在构建目录中。如果未指定公共头，则将source_files中的**所有**头视为公共。

#### . private_header_files

```
spec.private_header_files = 'Headers/Private/*.h'
```

用来标记私有文件模式列表。

这些模式与公共标头（如果未指定公共标头，则与所有标头）匹配，以排除那些不应暴露给用户项目并且不应用于生成文档的标头。构建库时，这些头将出现在构建目录中。

没有列出为公共和私有的头文件将被视为私有，但除此之外根本不会出现在构建目录中。

#### . vendored_frameworks

```
spec.ios.vendored_frameworks = 'Frameworks/MyFramework.framework'
spec.vendored_frameworks = 'MyFramework.framework', 'TheirFramework.framework'
```

源文件相关联的framework

#### . vendored_libraries

```
spec.ios.vendored_library = 'Libraries/libProj4.a'
spec.vendored_libraries = 'libProj4.a', 'libJavaScriptCore.a'
```

源文件相关联的libraries

#### . resource_bundles

```
spec.ios.resource_bundle = { 'MapBox' => 'MapView/Map/Resources/*.png' }
spec.resource_bundles = {
  'MapBox' => ['MapView/Map/Resources/*.png'],
  'MapBoxOtherResources' => ['MapView/Map/OtherResources/*.png']
}
```

为了将Pod构建为静态库，官方强烈建议使用此属性来管理资源文件，因为使用resources属性可能会发生名称冲突。

资源文件bundle的名称至少应包括Pod的名称，以最大程度地减少名称冲突的可能性。

#### . resources

```
spec.resource = 'Resources/HockeySDK.bundle'
spec.resources = ['Images/*.png', 'Sounds/*']
```

复制到target中的资源列表。

为了将Pod构建为静态库，官方建议是使用resource_bundle，因为使用resources属性可能会发生名称冲突。此外，使用此属性指定的资源将直接复制到客户端目标，因此Xcode不会对其进行优化。

#### . exclude_files

```
spec.ios.exclude_files = 'Classes/osx'
spec.exclude_files = 'Classes/**/unused.{h,m}'
```

从其他文件模式中排除的文件模式列表。

比如在设置某个子模块的时候，不需要包括其中的一些文件，就可以通过这个属性来进行设置。

#### . preserve_paths

```
spec.preserve_path = 'IMPORTANT.txt'
spec.preserve_paths = 'Frameworks/*.framework'
```

任何被下载的文件之后是不会被移除。

默认情况下，CocoaPods会移除所有与其他任何文件模式都不匹配的文件。

#### . module_map

```
spec.module_map = 'source/module.modulemap'
```

将此Pod集成为框架时应使用的模块映射文件。

默认情况下，CocoaPods基于规范中的公共头创建模块映射文件。

## 五、Subspecs相关

一个库可以指定依赖在另一个库、另一个库的子规范或自身的子规范上。

具体看下面这个例子：

```
pod 'ShareKit', '2.0'
pod 'ShareKit/Twitter',  '2.0'
pod 'ShareKit/Pinboard', '2.0'
```

我们有时候会编写这样的podfile文件，导入第三方或者自己依赖的库；那么它对应的podspec文件应该如何编写呢？

如下：

```
subspec 'Twitter' do |sp|
  sp.source_files = 'Classes/Twitter'
end

subspec 'Pinboard' do |sp|
  sp.source_files = 'Classes/Pinboard'
end
```

这样写就可以了，指定对应的源关联文件或者资源文件即可。

注意一点，就是通过pod search的时候只能是整个模块，即你不能单独搜索里面的子模块，但是我们podfile依赖是可以指定具体依赖哪一个模块。

#### . default_subspecs

```
spec.default_subspec = 'Core'
spec.default_subspecs = 'Core', 'UI'
spec.default_subspecs = :none
```

指定默认的依赖，如果不指定就依赖全部子依赖。

## 六、Multi-Platform support

设置支持的某个平台，比如ios、osx、tvos等

```
spec.ios.source_files = 'Classes/ios/**/*.{h,m}'
spec.osx.source_files = 'Classes/osx/**/*.{h,m}'
spec.osx.source_files = 'Classes/osx/**/*.{h,m}'
spec.tvos.source_files = 'Classes/tvos/**/*.{h,m}'
spec.watchos.source_files = 'Classes/watchos/**/*.{h,m}'
```

如果想要知道自己编写的podspec文件是否合法有效，可以通过命令 `pod spec lint` 进行验证。
