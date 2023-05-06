# Rabbit

#### 介绍

> - **Rabbit** 流密码是由 **Cryptico** 公司设计的，密钥长度 **128** 位，
> - 最大加密消息长度为 **264 Bytes**，即 **16 TB**，若消息超过该长度，则需要更换密钥对剩下的消息进行处理



#### Example

```
do {
    let str = "Hello World!"
    let key = "keychain01234567"
    print("key密钥：\(key)")

    //使用Rabbit加密模式
    let chiper = try Rabbit(key: key.bytes)

    //开始加密
    let encrypted = try chiper.encrypt(str.bytes)
    print("加密结果(base64): " + encrypted.toBase64()) // kDu8kn2sfotC7jiu

    //开始解密
    let decrypted = try chiper.decrypt(encrypted)
    print("解密结果: " + String(data: Data(decrypted), encoding: .utf8)!)
} catch { }
```

