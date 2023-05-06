## Swift脚本



#### Xcode步骤

1. Menu->File > New > File, 选择osx -> Shell Script, 默认创建Script.sh脚本文件
2. 打开Script.sh, 移除该代码

```
#!/bin/sh

# 这被称为hash bang语法，指定了要用来运行后续代码行的shell在文件系统中的完整路径。这里指定的是/bin/sh（Bash shell）。进行Swift脚本编程时，需要移除这行代码
```

3. 导入Swift代码

```
#!/usr/bin/env xcrun swift
import Foundation
print("Hello World!")
```

4. 运行脚本

```
# 设置脚本文件的权限，使其能够被shell执行
chmod +x Script.sh 
# 运行, ./告诉shell，该脚本位于当前目录中。必须显式地指出这一点，否则shell会找不到脚本
./Script.sh
```

#### [**参考**](https://www.cnblogs.com/hd1992/articles/5150556.html)



#### 新版本

##### 调用

针对Swift5.0以上, 可以直接针对 xxx.swift脚本进行编译运行

```
# main.swift
import Foundation
print(NSHomeDirectory())
```

```
# 命令行输入:
$ swift main.swift
```

##### 打包调用

```
# 通过Archive之后生成的(exec)Unix可执行文件
# 直接调用即可
./xxx
```



##### 简单示例

- Swift脚本可以直接参与文件/应用层级调用, 通过Cocoa框架即可

```
# 例如打开某应用:
import Foundation
import Cocoa
let configuration = NSWorkspace.OpenConfiguration()
configuration.promptsUserIfNeeded = true // 权限申请弹窗
configuration.hidesOthers = true // 移到最前
NSWorkspace.shared.openApplication(at: URL(filePath: "/Applications/Xcode.app"), configuration: configuration)

# 创建某个目录下所有.h文件的替身到指定目录
func symbolicTest() {
    // 原始操作目录
    let operatePath = NSHomeDirectory() + "/Desktop/TestCopy/Core/"
    let includePath = NSHomeDirectory() + "/Desktop/TestCopy/include/"

    print("--------------------------------------------------")
    let manager = FileManager.default
    manager
        .subpaths(atPath: operatePath)?
        .filter({
            $0.hasSuffix(".h")
        })
        .forEach({
            // 得到文件名称
            if let filename = $0.components(separatedBy: "/").last {
                let symbolicPath = includePath + filename
                try? manager.createSymbolicLink(atPath: symbolicPath, withDestinationPath: operatePath + $0)
            }
        })
    print("--------------------------------------------------")

}
symbolicTest()
```

##### 参数使用

- 直接使用参数

> 参数中: 
>
> - 通过swift main.swift在终端执行: 最终打印会有需要前置参数, 默认19个参数
> - 当添加一个parameter1, 输出参数加两个: 分隔符"--"与实际参数parameter1

```
# 命令行直接使用
$ swift main.swift parameter1 parameter2 ...

# 代码判定
let args = ProcessInfo.processInfo.arguments
# args的所有参数在实际运行的时候, 可能会有许多参数, 只有最后的几个参数才是我们需要的
```

- 使用自定义参数

```
#通过ArgumentParser库实现参数的嵌入, 这也是苹果推荐的方案
import ArgumentParser

struct Repeat: ParsableCommand {
    @Flag(help: "Include a counter with each repetition.")
    var includeCounter = false

    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    @Argument(help: "The phrase to repeat.")
    var phrase: String

    mutating func run() throws {
        let repeatCount = count ?? 2

        for i in 1...repeatCount {
            if includeCounter {
                print("\(i): \(phrase)")
            } else {
                print(phrase)
            }
        }
    }
}
# 目前创建的代码中@main无效, 因此需要手动调用
Repeat.main()

# 调用输出实例
$ repeat hello --count 3
hello
hello
hello

$ repeat --count 3
Error: Missing expected argument 'phrase'.
Help:  <phrase>  The phrase to repeat.
Usage: repeat [--count <count>] [--include-counter] <phrase>
  See 'repeat --help' for more information.

$ repeat --help
USAGE: repeat [--count <count>] [--include-counter] <phrase>

ARGUMENTS:
  <phrase>                The phrase to repeat.

OPTIONS:
  --include-counter       Include a counter with each repetition.
  -c, --count <count>     The number of times to repeat 'phrase'.
  -h, --help              Show help for this command.
```

###### 参考

- https://www.andyibanez.com/posts/writing-commandline-tools-argumentparser-part1/
- https://www.swift.org/blog/argument-parser/
