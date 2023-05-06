# ChaCha20

#### 介绍

> - **ChaCha20** 是 **ChaCha** 系列流密码，作为 **salsa** 密码的改良版，具有更强的抵抗密码分析攻击的特性，“**20**”表示该算法有 **20** 轮的加密计算。
> - 由于是流密码，故以字节为单位进行加密，安全性的关键体现在密钥流生成的过程，即所依赖的伪随机数生成器（**PRNG**）的强度，加密过程即是将密钥流与明文逐字节异或得到密文，反之，解密是将密文再与密钥流做一次异或运算得到明文。
> - **ChaCha20** 已经在 **RFC 7539** 中标准化。



#### Example

```
do {
    let str = "Hello World!"
    let key = "keychain01234567keychain01234567"
    print("key密钥：\(key)")

    let iv = "12345678"
    print("密钥偏移量：\(iv)")

    // 使用ChaCha20加密模式
    let chiper = try ChaCha20(key: key.bytes, iv: iv.bytes)

    //开始加密
    let encrypted = try chiper.encrypt(str.bytes)
    print("加密结果(base64): " + encrypted.toBase64()) // 0eBmJF0+Mgfb/c+6

    //开始解密
    let decrypted = try chiper.decrypt(encrypted)
    print("解密结果: " + String(data: Data(decrypted), encoding: .utf8)!)
} catch { }
```

