### Vapor

#### [DOC](https://docs.vapor.codes/)

##### 测试

```
# 8080端口被占用
sudo lsof -i:8080
# 找到pid,
sudo kill pid
# 重新运行即可
```

##### 部署在内网中

要在局域网中让 Vapor 搭建的 Web 服务端可访问，您需要在您的应用程序中设置监听地址为内部 IP 地址（例如：192.168.x.x 或 10.x.x.x），而不是默认的本地回环地址 127.0.0.1 或 localhost。

```
# 地址其实就是本地分配的局域网地址, 通过这个地址进行监听
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)

app.http.server.configuration.hostname = "172.17.26.183"
app.http.server.configuration.port = 2048

defer { app.shutdown() }
try configure(app)
try app.run()

# 外部访问可以直通过http://172.17.26.183:2048/hello进行ping访问
# 请注意，为了使您的 Vapor 应用程序在局域网中可访问，您需要确保您的计算机上没有防火墙或网络安全设置阻止了来自局域网的请求。同时，为了保证您的应用程序的安全性，建议您在内网中使用 HTTPS 协议来保护数据传输的安全性。
```



#### 调试

##### Leaf

```
✅Debug模式下, 报错: No custom working directory set for this scheme
此时需要主动为项目指定Scheme路径: Edit Scheme -> Options -> Working Directory, 指定Resource的资源路径

/// 这个代码在debug环境下依旧无法指定资源的真是位置, 因此还是要修改当前workingDirectory
/// https://github.com/vapor/leaf/issues/175
❎app.leaf.sources = .singleSource(NIOLeafFiles(fileio: app.fileio,
   limits: .default,
   sandboxDirectory: app.directory.workingDirectory,
   viewDirectory: app.directory.workingDirectory + "Views/"))
```

##### sqlite

```
// 执行完基础数据库链接与migrate
app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
app.migrations.add([CreateTodo(), CreateUser(), CreateNotes()])

// 在Debug环境下, 并不能直接migrate成功, 需要主动进行autoMigrate并wait
#if DEBUG
    try app.autoMigrate().wait()
#endif

// 在terminal中, 也需要执行 vapor run migrate
```



#### Content

> - Content可以通过自定义CodingKey来进行自定义变量映射
>
> - 此外还可以通过beforeEncode和afterEncode进行自定义处理
>
> 参考: https://docs.vapor.codes/basics/content/

```
struct ProfileItem: Content {
    
    /// Custom Codingkey
    enum CodingKeys: String, CodingKey {
        case bio
        case userID = "user_id"
    }
    
    var bio: String
    let userID: UUID
    
    // Runs after this Content is decoded. `mutating` is only required for structs, not classes.
    mutating func afterDecode() throws {
        // Name may not be passed in, but if it is, then it can't be an empty string.
        self.bio = self.bio.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.bio.isEmpty {
            throw Abort(.badRequest, reason: "Bio must not be empty.")
        }
    }
    
    // Runs before this Content is encoded. `mutating` is only required for structs, not classes.
    mutating func beforeEncode() throws {
        // Have to *always* pass a name back, and it can't be an empty string.
        let bio = self.bio.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !bio.isEmpty else {
            throw Abort(.badRequest, reason: "Bio must not be empty.")
        }
        self.bio = bio
    }
}

```

#### Fluent

> @Parent 无法直接参与Decode映射, 正常Json请求数据: `{"bio": "Hello, world!", "user_id": "30871B91-BB8B-4571-9F7E-C05394F7DFB8"}`,  因为`user_id`无法直接映射, 因此需构建一层Content充当Decode的处理的媒介
> 例如上面的ProfileItem可以充当Profile的媒介处理, 进而初始化Profile

```

/// 
final class Profile: Model, Content {
    static let schema = "profiles"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "bio")
    var bio: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, bio: String, userID: User.IDValue) {
        self.id = id
        self.bio = bio
        self.$user.id = userID
    }
    
}
```



#### 数据请求

##### curl

```
curl -X GET http://localhost:8080/user 
       
curl --header "Content-Type: application/json" \
     -X POST \
     --data '{"title": "Windy", "body": "It is so hot", "userID": "30871B91-BB8B-4571-9F7E-C05394F7DFB8"}' \
     http://localhost:8080/notes
     
curl --header "Content-Type: application/json" \
     -X GET \
     --data '{"id": "8B020FCB-567B-4456-91FD-EBC8532B0D43"}' \
     http://127.0.0.1:8080/io/user/onlines

curl --header "Content-Type: application/json" \
     -X POST \
     --data '{"name": "JOYE"}' \
     http://172.17.26.183:2048/users

# 文件下载, output是写入本地的路径
curl http://10.109.50.116:2048/files/download/Music_Gucunxinsi_fengzihauzhuan
     --output /Users/chenzhuo/Downloads/music_0.mp3
     
# 文件上传: 目前文件的上传有限制大小, 可以主动修改大小
app.routes.defaultMaxBodySize = 10_100_1000 // 10M大小限制, 也可以更改
curl -X POST \
     -H "Content-Type: multipart/form-data" \
     -F "filename=Music_Gucunxinsi_fengzihauzhuan.mp3"  \
     -F "data=@/xxx/xxx/Downloads/music_0.mp3" \
     http://10.109.50.116:2048/files/upload/stream
# 在此示例中，我们将 `filename` 和 `data` 作为表单数据发送到 `http://localhost:8080/upload` 端点。其中 `filename` 表示文件名，`data` 表示文件的二进制数据。请注意，在 `-F` 参数中，`@` 符号后面的路径应该是您本地计算机上实际文件的路径。

# 单文件上传
curl -X POST \
     -H "Content-Type: multipart/form-data" \
     -F "filename=pexels-2749481.jpg"  \
     -F "data=@/Users/chenzhuo/Desktop/Hacking/pexels-2749481.jpg" \
     http://10.109.62.86:2048/files/upload/images

# 多文件上传
curl -X POST \
     http://10.109.62.86:2048/files/uploads \
     -H 'Content-Type: multipart/form-data' \
     -F 'files[]=@/Users/chenzhuo/Desktop/Hacking/pexels-2749481.jpg' \
     -F 'files[]=@/Users/chenzhuo/Desktop/Hacking/pexels-1687575.jpg'
```



##### async await & EventLoopFuture

`async throws -> [User]`和`throws -> EventLoopFuture<[User]>`之间的主要区别在于它们的返回类型和错误处理方式。

`async throws -> [User]`是一个异步函数，它将立即返回一个包含用户数组的结果。如果函数执行期间出现错误，该函数将抛出一个错误，可以使用`do-catch`块来处理它。

例如，以下是使用`async throws -> [User]`声明的函数示例：

```swift
func getAllUsers() async throws -> [User] {
    let users = try await User.query(on: database).all()
    return users
}

do {
    let users = try await getAllUsers()
    print(users)
} catch {
    print("Error retrieving users: \(error)")
}
```

相反，`throws -> EventLoopFuture<[User]>`是一个返回`EventLoopFuture<[User]>`类型的异步函数，该类型表示在异步操作完成后返回一个包含用户数组的结果。您需要等待`EventLoopFuture`对象完成后才能使用它的结果。如果在异步操作期间出现错误，`EventLoopFuture`对象将包含一个错误，可以使用`flatMap`和`map`等技术来处理它。

例如，以下是使用`throws -> EventLoopFuture<[User]>`声明的函数示例：

```swift
func getAllUsers() throws -> EventLoopFuture<[User]> {
    return User.query(on: database).all()
}

getAllUsers()
    .flatMap { users in
        print(users)
    }
    .flatMapError { error in
        print("Error retrieving users: \(error)")
    }
```

因此，`async throws -> [User]`和`throws -> EventLoopFuture<[User]>`之间的选择将取决于您的代码的异步需求和错误处理方式。

###### 调用方式

```
let session = URLSession.shared
let url = URL(string: "http://localhost:8080/users")!
/// 直接异步处理: iOS 13+
do {
    let data = try await session.data(for: URLRequest(url: url))
    let users = try JSONDecoder().decode([User].self, from: data.0)
} catch {
    print(error.localizedDescription)
}
/// 回调函数处理: iOS 11+
let task = session.dataTask(with: url) { data, response, error in
    guard let data = data, error == nil else {
        print("Error: \(error!)")
        return
    }
    let users = try! JSONDecoder().decode([User].self, from: data)
    // 处理获取到的用户数组
}
task.resume()
```



#### 文件校验

###### 图片验证

```
SwiftGD库目前出现兼容性问题, 但可以修正, 需下载gd库
- 基础处理
Swim: https://github.com/t-ae/swim
- 同样可以进行图片处理
```



#### WebSocket

##### TCP延迟

```
# TCP 无延迟
# 启用 tcpNoDelay 参数将尝试 TCP 数据包延迟最小化。默认为 true。
# 降低数据包延迟。
app.http.server.configuration.tcpNoDelay = true
```



#### Vapor成熟方案

```
https://github.com/AddaMeSPB/ChatEngine.git
https://github.com/in2core/vapor-chatroom-demo.git

https://github.com/vaporberlin/vaporschool
https://github.com/cjbatin/Create-an-iOS-chat-app-with-Vapor.git
```





