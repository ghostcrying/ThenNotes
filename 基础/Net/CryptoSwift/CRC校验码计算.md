# CRC校验码计算

> **CRC** 即循环冗余校验码（**Cyclic Redundancy Check**）：是数据通信领域中最常用的一种查错校验码，其特征是信息字段和校验字段的长度可以任意选定。
> 循环冗余检查（**CRC**）是一种数据传输检错功能，对数据进行多项式计算，并将得到的结果附在帧的后面，接收设备也执行类似的算法，以保证数据传输的正确性和完整性。
>
> 例如在数据传输过程中, 保证数据的准确进行校验.



#### 示例

```
/*** 计算字节数组的CRC值 ***/
let bytes: [UInt8] = [0x01, 0x02, 0x03]
let crc1 = bytes.crc16() // 41232
let crc2 = bytes.crc32() // 1438416925
 
/*** 计算Data的CRC值 ***/
let data = Data([0x01, 0x02, 0x03])
let crc3 = data.crc16() // 2 bytes [161, 16]
let crc4 = data.crc32() // 4 bytes [85, 188, 128, 29]
 
/*** 计算字符串的CRC值 ***/
let crc5 = "Hello World!".crc16() // 57be
let crc6 = "Hello World!".crc32() // 1c291ca3
```



