# Charles



### 下载和安装Charles (Mac-iOS)

#### [下载](https://link.juejin.cn/?target=https://www.charlesproxy.com/download/)

#### 选择对应系统的版本

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NjExNWU2MDIxMDJlYjY3YWUwZGY5M2Y1ODU5YTZlZTlfbXJzQ3F2dk1qa1JkU25tajNMYURrUjU1WkdxVzZDRUNfVG9rZW46Ym94Y244NXBZR25RcmpPMjdJYkpucmVCU2FnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)

#### 安装

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=ZTNlZWYwNmNhOTQwZGRhMzNiOWRjM2I1MTM1YzRjODRfM0ZJcWhweUxLN1FPZW44WDRCTXdOekdWSGJlTm1qVmJfVG9rZW46Ym94Y25HQzdRaWVyb01kUjZaU2U2NWdxMkFnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)

#### [破解](https://www.zzzmode.com/mytools/charles/)



#### 配置手机

> 请确保手机和电脑在同一局域网内 步骤： 设置网络的代理服务器为该电脑的ip地址，端口为8888，此时你已经可以抓取http请求了

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NTNmOWMzOGY5MmExNWZiYzk4M2FhNDg0OTcyMDA5YTRfVkw3ek5seE0xVmhNQlZ2WkxzN2pROVA1REY0VTJRYmdfVG9rZW46Ym94Y25Lb1VxZXJlS3NOZVVRYllNUXM0UGdiXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=OGYwMzZiZGJiOTAxMDRiZDU4NzJhOWU3MTA1ODgwN2NfbmdseTdGOEVTdG5rcGU0bWZQZTdIUGdQU3diTmpBWEJfVG9rZW46Ym94Y241N29hekg0MWtQdjhIYWMycnNvVXVnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NmQ0YjkyMzA2MzMxYzI3ZWNhMzA2OWYzYzI5ZjY4OGVfQzE2b2pRbVQyT1Y2Q1NWZUFaOHQxZGk2Nnh3R3ptOTdfVG9rZW46Ym94Y25wcDh4cXJJZmxNVnhiVVNqSVBKamRkXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)

此时如果抓包，会看到一堆unknown

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=OTk5YTY0OTI4ZjYwZjRiMDRiYzA4ODY1YjUyMDFhZmFfTFJrZzBzcnVsWk9FakV5cUlMcFRlNEQxQ3lFdWp0aFJfVG9rZW46Ym94Y25TTkNJZXNrQXFYTmN3TVdYd0Q1RzNjXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



### 配置抓包HTTPS请求

> 主要步骤是电脑和手机上都安装好证书



#### 电脑上的配置证书

- 安装Charles HTTPS证书 路径：help–>SSLProxying–> Install Charles Root Ceriticate，如图所示：

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NWRkZGVhMzdiNWYyMmVjY2RjYzNhZjg5MTIwYjI1OTlfaHFnRlVWeXpEcU9NREdiY1RyYklCT25TUFRzTk5NNGpfVG9rZW46Ym94Y241T2dGZnkzMTlHYmVIa0ZQS0xxQ0pjXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



- 点击Install Charles Root Ceriticate后，会直接跳到钥匙串

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=YmE1ZWU0NDhlYjAyZTg4N2FjZDliNjk4ZGE3ZTY3MTdfZjQwS29OQlJ1aXYwVUduOEpjd2dhbFk4OWRVN0dWbERfVG9rZW46Ym94Y25RMEJSb3RyUEtnWFVwbWhqTFhISzFnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



- 如果你的证书已经信任，可直接进入下一步，反之，点击Charles Proxy CA，进入钥匙串访问，设置为始终信任

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NzgzZDhiNGFjMmY1OGFkNWMzYjI0Y2IwMjZlYzNjZWFfbjhWcUUzbnkwY0NCdnVMUlVnREs5dmtQbGN2d0dCajVfVG9rZW46Ym94Y25CajJDaVFRUjlBS1ZvTnZkR2d5ck1jXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)





1. 通过Proxy–>Proxy Settings->Proxies, 勾选Enable transparent HTTP proxying



![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=NDkxMjIxNzdjZDJkYzMyZDc4ZDU1ZjVhNWY3ZDhlMjFfNGs5R2ZzOVlvQmgwSUtJZzZzMUVYWmxYZXpoR3o1UlhfVG9rZW46Ym94Y254MXlKMThrOTE4ZUpPcVJKQm1xbVhnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



1. 通过Proxy–>SSL Proxying Settings,勾选Enable SSL Proxying, 并添加host，端口是443 这里是把所有的host都设置进去



![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=MDM2MTlhZDJiMWQzOTJkNDM3NWMwNGZlN2U0NzcxNmFfSFNKSmdOc08wcnV4MWthTmljbDNBTk1NSU5mRFpIc1VfVG9rZW46Ym94Y243VEMxMmxSaUtHSG9qOGhMNWFnUWpkXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



#### 手机端下载证书

1. 电脑上通过help–>SSLProxying–> Install Charles Root Ceriticate on a Mobile Device or Remote Browser，可以获得下载提示

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDE2N2IyNjExYTRkNzQ5ZWI4MGRiYWViMjVjNDE2NjhfM0NkbTNxbWV5Zk1jUEdnbGpYckliVGtkNGJROW1OeldfVG9rZW46Ym94Y25IQnlXRHJpYmpzZUhIMjlrUUM0dElnXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



2. 手机上safari打开上述网址chls.pro/ssl(可能会有不同，请看上图提示)，下载安装证书 **注意要使用safari，其他浏览器下载证书并不会提示安装**



![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=YjZhZDRlZmU1YTBhZjY3NGY1ZTUyMDA5YjA0Y2E1MjlfNTRtNEhwZEdKY2hTMTJOTDc1UzlpeDBJTlhSbEJ3TWZfVG9rZW46Ym94Y25DUkJreFN1ZmVUNWhEQUVUMDJsR25mXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



3. 信任刚刚安装的证书，手机上打开 设置->通用->关于本机-> 证书信任设置 -> 信任证书

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=MDg4ZTRmMWJiNzJlMzVkMTQ2ZGFlMGJjMDhiMzFkNGZfS1NkQ0pnemF5ek1YSnVENUtuU2ZuaTc1bTJDOVcydnFfVG9rZW46Ym94Y25icTdPM2dDVHF4Y0FCRW90bFJ1a29jXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



#### 查看抓包

> 可以看到成功抓取了https

![img](https://d4alb0m07y.feishu.cn/space/api/box/stream/download/asynccode/?code=ZjZkZWVkMmE4NDVjMTJmZTJlOGUwOWViZWY0YzQ3M2ZfZVVKdHhkZDNobzhtRDEzWGd0czFESlRWWDhkTmpFdThfVG9rZW46Ym94Y25lcjh1eDVKcGhtZlBNaDJxS1g1SG5kXzE2NDcxNTc5MTY6MTY0NzE2MTUxNl9WNA)



### 失败的可能原因

> 如果仍然不成功，可以参照以下几点排查

- 手机和电脑不处在同一网络环境下
- 手机上的代理ip不是电脑本机ip
- 证书没装成功
- 没勾选 Proxy -> macOS Proxy，勾选上 macOS Proxy
- 浏览器装的插件拦截了
- 不支持对应的协议，如 https http2 等需要另外配置



#### Charles API超时模拟

https://blog.csdn.net/sinat_34937826/article/details/110493085

网络500...模拟: https://blog.csdn.net/Lu_GXin/article/details/106492466

模拟网站: https://designer.mocky.io/manage