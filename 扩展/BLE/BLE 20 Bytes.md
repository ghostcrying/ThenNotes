# BLE 20 Bytes



在做蓝牙相关的项目的时候，估计很多都好奇为什么一次最多发送20Byte的数据，话不多说，先上图，下图为蓝牙数据发送的包结构。红色部分为最终我们发送的数据包大小(Notify状态下)。

![未标题-1.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ad20e137221749d4aa27e6c0ac0bac56~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)

在开始之前先提一下Octet与Byte的区别，虽然两个都可以翻译成字节。 Octet 为 八比特组。 在TCP/IP发展初期有些系统结构使用的Byte是10位.

### 广播包简介

#### 广播包头部

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e91396c579d24c92b1ee08075fce7af9~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)**报头部分**

1. 头部主要有1个octet。
2. PDU类型
3. RFU为保留
4. TxAdd 发送地址段
5. RxAdd 接受地址段

**长度部分**

1. 长度主要有1个octet。
2. 6octet为长度，取值为6-37（广播包最后有6octet设备地址，所以最少是6位）。

对于这里的37字节，我的猜想是这样的，不知道是否正确，为了兼容数据PUD中5位长度为31octet的数据，再加上6octet必须要加的设备地址。

#### 广播数据部分

数据分为有效数据和无效数据(用0填充)+6octet设备地址。有效数据结构如下

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/42b1a87243f54fe0927e7b9c36de0d9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)

1. 有效数据部分由多个AD Structure组成
2. 1个AD Structure 由 1个octct的长度和数据(Length)组成
3. data 由 AD type（n个octct） 和 AD data(Length - n)组成

### 数据PDU

#### 头部

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9f04eaba88f84f1a9a2ed92dab16172f~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)

1. Length 为5位 0-31octct，最大31octet
2. 减去 4octet的MIC 31-4 = 27 octet 为Payload长度。

#### 链路层 L2CAP

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d8a282ffb72744c28d1aa71080b3b48e~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)

27 - 2 - 2 = 23 octet

#### notify

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e1be30e21ae465b99bef5d02b6c0a94~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.image?)

23 - 1 - 2 = **20** octet.





###### 参考: https://juejin.cn/user/1890815729208285