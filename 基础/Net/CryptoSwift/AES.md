# AES



#### 介绍

> 高级加密标准（英语：**Advanced Encryption Standard**，缩写：**AES**），在密码学中又称 **Rijndael** 加密法，是美国联邦政府采用的一种区块加密标准。
>
> 该标准是用来替代原先的 **DES**，现已经被多方分析且广为全世界所使用，成为对称密钥加密中最流行的算法之一。
>
> **AES** 采用对称分组密码体制，加密数据块分组长度必须为 **128** 比特，密钥长度可以是 **128** 比特、**192** 比特、**256** 比特中的任意一个（如果数据块及密钥长度不足时，会补齐）



#### 模式

> **AES** 作为一种分组加密算法为了适应不同的安全性要求和传输需求允许在多种不同的加密模式下工作：
>
> 1. **ECB** 模式（电子密码本模式：**Electronic codebook**）
>
> - **ECB** 是最简单的块密码加密模式，加密前根据加密块大小（如 **AES** 为 **128** 位）分成若干块，之后将每块使用相同的密钥单独加密，解密同理。
>
> - **ECB** 模式由于每块数据的加密是独立的因此加密和解密都可以并行计算。
>
> - **ECB** 模式最大的缺点是相同的明文块会被加密成相同的密文块，这种方法在某些环境下不能提供严格的数据保密性。
>
>   
>
> 2. **CBC** 模式（密码分组链接：**Cipher-block chaining**）
>
> - **CBC** 模式对于每个待加密的密码块在加密前会先与前一个密码块的密文异或然后再用加密器加密。第一个明文块与一个叫初始化向量的数据块异或。
> - **CBC** 模式相比 **ECB** 有更高的保密性，但由于对每个数据块的加密依赖于前一个数据块的加密，所以加密无法并行。
> - **CBC** 模式与 **ECB** 一样在加密前需要对数据进行填充，不是很适合对流数据进行加密。 
>
> 
>
> 3. **CTR** 模式（计算器模式：**Counter**）
>
> - 计算器模式不常见，在 **CTR** 模式中， 有一个自增的算子，这个算子用密钥加密之后的输出和明文异或的结果得到密文，相当于一次一密。
> - 这种加密方式简单快速，安全可靠，而且可以并行加密。
> - 但是在计算器不能维持很长的情况下，密钥只能使用一次。
>
> 
>
> 4. **CFB** 模式（密文反馈：**Cipher feedback**）
>
> - 与 **ECB** 和 **CBC** 模式只能够加密块数据不同，**CFB** 能够将块密文（**Block Cipher**）转换为流密文（**Stream Cipher**）。
> - **CFB** 的加密工作分为两部分：先将前一段加密得到的密文再加密；接着将第 **1** 步加密得到的数据与当前段的明文异或。
> - 由于加密流程和解密流程中被块加密器加密的数据是前一段密文，因此即使明文数据的长度不是加密块大小的整数倍也是不需要填充的，这保证了数据长度在加密前后是相同的。
> - **CFB** 模式非常适合对流数据进行加密，解密可以并行计算。
>
> 
>
> 5. **OFB** 模式（输出反馈：**Output feedback**）
>
> - **OFB** 是先用块加密器生成密钥流（**Keystream**），然后再将密钥流与明文流异或得到密文流，解密是先用块加密器生成密钥流，再将密钥流与密文流异或得到明文，由于异或操作的对称性所以加密和解密的流程是完全一样的。
> - **OFB** 与 **CFB** 一样都非常适合对流数据的加密。
> - **OFB** 由于加密和解密都依赖与前一段数据，所以加密和解密都不能并行。



#### 秘钥长度

> - AES-128 = 16 bytes
> - AES-192 = 24 bytes
> - AES-256 = 32 bytes

> **zeroPadding 补齐规则：**
> 将长度补齐至 **blockSize** 参数的整数倍。比如我们将 **blockSize** 设置为 **AES.blockSize**（**16**）。
>
> - 如果长度小于 **16** 字节：则尾部补 **0**，直到满足 **16** 字节。
> - 如果长度大于等于 **16** 字节，小于 **32** 字节：则尾部补 **0**，直到满足 **32** 字节。
> - 如果长度大于等于 **32** 字节，小于 **48** 字节：则尾部补 **0**，直到满足 **48** 字节。 以此类推......



#### Example

##### ECB+NoPadding

```
do {
    let str = (0..<1)
        .map { _ in
          return "Hello World!"
        }
        .joined()
    print("原始字符串：\(str)")

    let key = "keychain12345678"
    print("key密钥：\(key)")
    print("key长度：\(key.count)") // 16

    // 使用AES-128-ECB加密模式
    let aes = try AES(key: key.bytes, blockMode: ECB())

    // 开始加密
    let encrypted = try aes.encrypt(str.bytes)
    let encryptedBase64 = encrypted.toBase64() // 将加密结果转成base64形式
    print("加密结果(base64): " + encryptedBase64) // GhmnPnRO53dxN5kTLrBnPQ==

    // 开始解密1（从加密后的字符数组解密）
    let decrypted1 = try aes.decrypt(encrypted)
    print("解密结果1: " + String(data: Data(decrypted1), encoding: .utf8)!) // Hello World!

    // 开始解密2（从加密后的base64字符串解密）
    let decrypted2 = try encryptedBase64.decryptBase64ToString(cipher: aes)
    print("解密结果2: " + decrypted2) // Hello World!
} catch {
    print("Error: " + error.localizedDescription)
}
```

##### ECB+ZeroPadding

```
do {
    let str = "Hello World!"
    print("原始字符串：\(str)")

    let key = "ChineseShanghai"
    print("key密钥：\(key)")
    print("key长度：\(key.count)")

    // 使用AES-128-ECB加密模式
    // let aes = try AES(key: key.bytes, blockMode: ECB())
    // 使用 ZeroPadding 默认补齐到16位
    let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize), blockMode: ECB())

    // 开始加密
    let encrypted = try aes.encrypt(str.bytes)
    let encryptedBase64 = encrypted.toBase64() // 将加密结果转成base64形式
    print("加密结果(base64)：\(encryptedBase64)") // IV9MNxQFgZ9/J0Wvi7//tw==

    // 开始解密1（从加密后的字符数组解密）
    let decrypted1 = try aes.decrypt(encrypted)
    print("解密结果1：\(String(data: Data(decrypted1), encoding: .utf8)!)") // Hello World!

    // 开始解密2（从加密后的base64字符串解密）
    let decrypted2 = try encryptedBase64.decryptBase64ToString(cipher: aes)
    print("解密结果2：\(decrypted2)") // Hello World!
} catch {
    print("Error: " + error.localizedDescription)
}
```

##### CBC

```
do {
    let str = "Hello World!"
    print("原始字符串：\(str)")

    let key = "ChineseShanghai1"
    print("key密钥：\(key)")
    print("key长度：\(key.count)")

    let iv = "1234567890123456"
    print("密钥偏移量：\(iv)")
    // 可以使用随机秘钥
    // let iv = AES.randomIV(AES.blockSize) // [UInt8] Type

    // 使用AES-128-CBC加密模式
    let aes = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes))
    // let aes = try AES(key: key, iv: iv)

    //  开始加密
    let encrypted = try aes.encrypt(str.bytes)
    let encryptedBase64 = encrypted.toBase64() // 将加密结果转成base64形式
    print("加密结果(base64)：\(encryptedBase64)")

    // 开始解密1（从加密后的字符数组解密）
    let decrypted1 = try aes.decrypt(encrypted)
    print("解密结果1：\(String(data: Data(decrypted1), encoding: .utf8)!)")

    // 开始解密2（从加密后的base64字符串解密）
    let decrypted2 = try encryptedBase64.decryptBase64ToString(cipher: aes)
    print("解密结果2：\(decrypted2)")
} catch {
    print("Error: " + error.localizedDescription)
}
```



##### String扩展 (便捷)

```
do {
    // 使用AES-128-CBC加密模式的Cipher
    let str = "Hello World"
    let key = "ChineseShaghai1"
    let aes = try AES(key: key.bytes, blockMode: CBC(iv: AES.randomIV(AES.blockSize)))

    let encrypted = try str.encryptToBase64(cipher: aes)
    print("加密结果(base64)：\(encrypted)")

    let decrypted = try encrypted.decryptBase64ToString(cipher: aes)
    print("解密结果：\(decrypted)")
} catch {
    print("Error: " + error.localizedDescription)
}
```



##### 增量更新

```
do {
    // 创建一个用于增量加密的Cryptor实例
    let key = "ChineseShaghai12"
    let iv = "drowssapdrowssap"
    var encryptor = try AES(key: key, iv: iv).makeEncryptor()

    var ciphertext = [UInt8]()
    // 合并每个部分的结果
    ciphertext += try encryptor.update(withBytes: Array("Start Recognize".utf8))
    ciphertext += try encryptor.update(withBytes: Array(" ".utf8))
    ciphertext += try encryptor.update(withBytes: Array("Video.".utf8))
    // 结束
    ciphertext += try encryptor.finish()

    // 输出完整的结果（base64字符串形式）
    print(ciphertext.toBase64()) // a/4hF26Ecn0PGina1jnyspm6GPwtXhbcw4NYrCfG05s=
} catch {
    print("Error: " + error.localizedDescription)
}
```

