### UIApplication

##### 锁屏

```
* idleTimer 是iOS内置的时间监测机制，当在一段时间内未操作即进入锁屏状态。但有些应用程序是不需要锁住屏幕的，比如游戏，视频这类应用。 可以通过设置UIApplication的isIdleTimerDisabled属性来指定iOS是否锁屏
* 这个命令只能禁用自动锁屏，如果点击了锁屏按钮，仍然会进入锁屏的。有一点例外的是，AVPlayer不用设置idleTimerDisabled=YES，也能屏幕常亮，播放完成后过一分钟就自动关闭屏幕

* UIApplication.shared.isIdleTimerDisabled = true
```



