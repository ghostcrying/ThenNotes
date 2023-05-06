# MAC



### 消息认证码（MAC）介绍

- 消息认证码是指在密码学中，通信实体双方使用的一种验证机制，保证消息数据完整性的一种工具。
- 其构造方法由 **M.Bellare** 提出，安全性依赖于 **Hash** 函数，故也称带密钥的 **Hash** 函数。
- 消息认证码是基于密钥和消息摘要所获得的一个值，可用于数据源发认证和完整性校验



### HMAC

> **HMAC**（**Hashed Message Authentication Code**）中文名叫做：散列消息身份验证码。
>
> 它不是散列函数，而是采用了将 **MD5** 或 **SHA1** 散列函数与共享机密密钥(与公钥／私钥对不同)一起使用的消息身份验证机制。基本来说，消息与密钥组合并运行散列函数。然后运行结果与密钥组合并再次运行散列函数。这个 **128** 位的结果被截断成 **96** 位，成为 **MAC**

> **HMAC主要应用在身份验证中，它的使用方法是这样的：**
>
> 1. 客户端发出登录请求（假设是浏览器的 **GET** 请求）
>
> 2. 服务器返回一个随机值，并在会话中记录这个随机值
>
> 3. 客户端将该随机值作为密钥，用户密码进行 **hmac** 运算，然后提交给服务器
>
> 4. 服务器读取用户数据库中的用户密码和步骤2中发送的随机值做与客户端一样的 **hmac** 运算，然后与用户发送的结果比较，如果结果一致则验证用户合法

> 在这个过程中，可能遭到安全攻击的是服务器发送的随机值和用户发送的 **hmac** 结果，而对于截获了这两个值的黑客而言这两个值是没有意义的，绝无获取用户密码的可能性，随机值的引入使 **hmac** 只在当前会话中有效，大大增强了安全性和实用性。大多数的语言都实现了 **hmac** 算法，比如 **php** 的 **mhash**、**python** 的 **hmac.py**、**java** 的 **MessageDigest** 类，在 **web** 验证中使用 **hmac** 也是可行的，用 **js** 进行 **md5** 运算的速度也是比较快的。

#### SHA（安全散列算法：Secure Hash Algorithm）

> 1. 这个是美国国家标准和技术局发布的国家标准 **FIPS PUB 180-1**，一般称为 **SHA-1**。其对长度不超过 **264** 二进制位的消息产生 **160** 位的消息摘要输出，按 **512** 比特块处理其输入。
>
> 2. **SHA** 是一种数据加密算法，该算法经过加密专家多年来的发展和改进已日益完善，现在已成为公认的最安全的散列算法之一，并被广泛使用。该算法的思想是接收一段明文，然后以一种不可逆的方式将它转换成一段（通常更小）密文，也可以简单的理解为取一串输入码（称为预映射或信息），并把它们转化为长度较短、位数固定的输出序列即散列值（也称为信息摘要或信息认证代码）的过程。散列函数值可以说时对明文的一种“指纹”或是“摘要”所以对散列值的数字签名就可以视为对此明文的数字签名。

#### HMAC_SHA1（Hashed Message Authentication Code, Secure Hash Algorithm）

> 1. 这是一种安全的基于加密 **hash** 函数和共享密钥的消息认证协议。它可以有效地防止数据在传输过程中被截获和篡改，维护了数据的完整性、可靠性和安全性。**HMAC_SHA1** 消息认证机制的成功在于一个加密的 **hash** 函数、一个加密的随机密钥和一个安全的密钥交换机制。
>
> 2. **HMAC_SHA1** 算法在身份验证和数据完整性方面可以得到很好的应用，在目前网络安全也得到较好的实现。



#### Poly1305

> **Poly1305** 是 **Daniel.J.Bernstein** 创建的消息认证码，可用于检测消息的完整性和验证消息的真实性，现常在网络安全协议（**SSL**/**TLS**）中与 **salsa20** 或 **ChaCha20** 流密码结合使用。
> **Poly1305** 消息认证码的输入为 **32** 字节（**256bit**）的密钥和任意长度的消息比特流，经过一系列计算生成 **16** 字节（**128bit**）的摘要。



### Example

##### SHA1

```
let str = "Hello World!"
let key = "key"
let hmac = try! HMAC(key: key.bytes, variant: .sha1).authenticate(str.bytes)

print("原始字符串: " + str) // Hello World!
print("key: " + key) // key
print("HMAC运算结果: " + hmac.toHexString()) // 7a0a085ad3e64b088cf9f2d5b4053518dbe5af0f
```

##### MD5 / SHA1 / SHA256 / SHA384 / SHA512

```
try! HMAC(key: key.bytes, variant: .md5).authenticate(str.bytes) 
try! HMAC(key: key.bytes, variant: .sha1).authenticate(str.bytes)
try! HMAC(key: key.bytes, variant: .sha256).authenticate(str.bytes)
try! HMAC(key: key.bytes, variant: .sha384).authenticate(str.bytes)
try! HMAC(key: key.bytes, variant: .sha512).authenticate(str.bytes)
```

##### Poly1305

```
let str = "Hello World!"
let key = "hw012345678901234567890123456789"
let mac = try! Poly1305(key: key.bytes).authenticate(str.bytes)

print("原始字符串: " + str) // Hello World!
print("key: " + key) // hw012345678901234567890123456789
print("Poly1305运算结果: " + mac.toHexString()) // 1f657592cae2aea62046e53f1dac0acf
```

