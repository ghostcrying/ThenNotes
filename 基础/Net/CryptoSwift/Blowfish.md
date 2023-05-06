# Blowfish



#### 介绍

> **Blowfish** 算法是一个 **64** 位分组及可变密钥长度的对称密钥分组密码算法，可用来加密 **64** 比特长度的字符串。
>
> **Blowfish** 算法具有加密速度快、紧凑、密钥长度可变、可免费使用等特点，已被广泛使用于众多加密软件。
>
> 由于 **Blowfish** 算法采用变长密钥，这在给用户带来极大便利的同时也存在隐患。由于算法加/解密核心在于密钥的选择和保密，但在实际应用中经常使用一些弱密钥对信息资源进行加密，导致存在着很大的安全隐患。
>
> **Blowfish** 同上文介绍的 **AES** 一样，也拥有多种加密模式：**ECB**、**CBC**、**CFB**、**CTR**、**OFB**、**PCBC**



#### Example

##### ECB

```
do {
    let str = "Hello World!"
    let key = "keychain01234567keychain01234567"
    print("key密钥：\(key)")

    //使用Blowfish-ECB加密模式
    let chiper = try Blowfish(key: key.bytes, blockMode: ECB(), padding: .pkcs7)

    //开始加密
    let encrypted = try chiper.encrypt(str.bytes)
    print("加密结果(base64): " + encrypted.toBase64()) // /GtDfcJbbWbrV1YyKxQw1A==

    //开始解密
    let decrypted = try chiper.decrypt(encrypted)
    print("解密结果: " + String(data: Data(decrypted), encoding: .utf8)!)
} catch { }
```

##### CBC

```
do {
    let str = "Hello World!"
    let key = "keychain01234567keychain01234567"
    print("key密钥：\(key)")

    let iv = "12345678"
    print("密钥偏移量：\(iv)")

    // 使用Blowfish-CBC加密模式
    let chiper = try Blowfish(key: key.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)

    // 开始加密
    let encrypted = try chiper.encrypt(str.bytes)
    print("加密结果(base64): " + encrypted.toBase64()) // QVhTADT4wp5+gT1v2MVGHQ==

    // 开始解密
    let decrypted = try chiper.decrypt(encrypted)
    print("解密结果: " + String(data: Data(decrypted), encoding: .utf8)!)
} catch { }
```

