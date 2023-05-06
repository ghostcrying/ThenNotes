### Swift Package

##### 创建

```
swift package init (--type library/executable/empty/system module)
```



- type

  - library：创建库, 默认

  - executable：创建可执行文件

  - empty：创建空项目

  - system module：创建系统模块项目

    

- xcode edit

  - 执行`swift package generate-xcodeproj`

    ```
    新版本已经无需执行该指令, 打开package默认创建xcodeproject
    ```

    

- Description

  ```
  import PackageDescription
  
  let package = Package(
      name: "testProgram",
      products: [
          // Products define the executables and libraries produced by a package, and make them visible to other packages.
          // A package can produce multiple executables and libraries.
          .library(
              name: "testProgram",
              targets: ["testProgram"]),
          .executable(
              name: "MainExecutable",
              targets: ["MainExecutable"])
      ],
      dependencies: [
          // Dependencies declare other packages that this package depends on.
          // .package(url: /* package url */, from: "1.0.0"),
      ],
      targets: [
          // Targets are the basic building blocks of a package. A target can define a module or a test suite, and of course an executable.
          // Targets can depend on other targets in this package, and on products in packages which this package depends on.
          .target(
              name: "testProgram",
              dependencies: []),
          .testTarget(
              name: "testProgramTests",
              dependencies: ["testProgram"]),
      ]
  )
  ```

  - 该模版代码创建了一个 Package 实例，并通过构造参数来指定项目的 name、product、target 和 dependency。各字段作用如下：

    - name：指定项目名称
    - products：指定项目生成的东西，可以是 library 或者 executable，同一个项目可以生成多个 library 或 executable。
    - dependencies：指定项目所使用的依赖库及其 URL、版本等信息。
    - targets：指定项目生成的目标，

    若要添加开源代码，在 .dependency 中添加：

    ```text
    .package(url: "open source url", from: "version number")
    ```

    若要添加本地依赖，在 .dependency 中添加：

    ```text
    .package(path:"local path")
    ```

    可以添加多个依赖，并且用上述类似的方法还可以创建多个products和targets。

    然后在产生的targets中，指定对应的dependency的名称就可以了

#### 注意

- Swift Package Manager只限制单一语言, 混编状态下会报错

  ```shell
  Target at '.../.../...' contains mixed language source files; feature not supported.
  ```



```
$ git init  // create a new git project
$ git add . // add all files to the stack
$ git remote add origin [github-URL] // add a remote origin in the remote repository
$ git commit -m "Initial Commit" // commit all files in the stack to local repository
$ git tag 1.0.0 // tag the branch
$ git push origin master --tags // push local repository to remote repository
```

