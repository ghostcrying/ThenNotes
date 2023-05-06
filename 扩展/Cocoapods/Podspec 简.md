### podspec



```
  # podspec 中文注释,注释掉的字段为可选,未注释掉的为必填
  
Pod::Spec.new do |s|  
  
  # ―――Spec基本信息――――――――――――――――――――――――――――――――――――――――――――――#  
  # SDK名字
  s.name         = "TestPodSpec"  
  # SDK版本
  s.version      = "0.0.1"  
  # SDK说明,在搜索SDK时会显示
  s.summary      = "A short description of TestPodSpec."  
  # SDK的描述,DESC是分隔符,写在DESC之间
  s.description  = <<-DESC  
                  描述写在这里
                   DESC  
  # SDK主页,必须是一个能通过网络访问的页面,可以放作者个人页面,公司页面,哪怕放个www.baidu.com也行,只要能访问就可以.
  s.homepage     = "http://EXAMPLE/TestPodSpec"  
  #SDK截图,可以放gif
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"  

  # ―――License信息――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #license说明
  s.license      = "MIT (example)"  
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }  
  
  # ―――作者信息――――――――――――――――――――――――――――――――――――――――――――――#
  # 作者信息,作者名字与邮箱
  s.author             = { "mccree" => "mccree@mc.com" }  
  # Or just: s.author    = "" 
  # 有多个作者的话写这里 
  # s.authors            = { "" => "" }  
  # 社交链接地址
  # s.social_media_url   = "http://twitter.com/"  
  
  # ――― 支持iOS版本信息 ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #  
  # 平台,可以写ios, osx
  # s.platform     = :ios  
  # 支持最低版本
  # s.platform     = :ios, "5.0"  
  #  支持混合平台  
  # s.ios.deployment_target = "5.0"  
  # s.osx.deployment_target = "10.7"  
  # s.watchos.deployment_target = "2.0"  
  # s.tvos.deployment_target = "9.0"  
  
  # ――― 代码仓库支持 git, hg, bzr, svn and HTTP ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #  
  # 代码仓库路径,SDK是根据tag号来取代码的,通常会把tag号设成和版本一样  
  s.source = { :git => "http://EXAMPLE/TestPodSpec.git", :tag => "#{s.version}" }  
  
  # ――― 代码文件 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #  
  # 代码文件匹配,**指匹配任意文件夹,*.{h,m}指匹配任意.h和.m文件
  s.source_files  = "Classes", "Classes/**/*.{h,m}"  
  s.exclude_files = "Classes/Exclude"  
  # SDK需要暴露的.h文件,默认暴露所有
  # s.public_header_files = "Classes/**/*.h"  
  
  # ――― 资源路径 ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #    
  # 指定资源,比如xib,图片等资源都是
  # s.resource_bundles = {
    'XXXKit' => ['XXXKit/Classes/**/*.{storyboard,xib,cer,json,plist}','XXXKit/Assets/*.{bundle,xcassets,imageset,png}']
  }
  
  # ――― 系统库依赖以及静态库―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #  
  # s.framework  = "UIKit"  
  # s.frameworks = "UIKit", "AnotherFramework"  
  # s.library   = "iconv"  
  # s.libraries = "iconv", "xml2"  
  
  
  # ――― 其他三方库依赖 ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #  
  # 比如你的SDK依赖AFNetworking,注意这里和podfile中的语法不同在于,这里无法指定其他依赖的具体路径
  # 比如这种写法就不支持 s.dependency 'XMPPFramework', :git => "https://github.com/robbiehanson/XMPPFramework.git", :branch => 'master'
  # s.dependency "AFNetworking", "~> 3.0"  

  # 可以作为引入本地路径配置...
  # 有多重使用方式
  # s.xcconfig = {
  #   'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../Frameworks"'
  # }
end  
```

