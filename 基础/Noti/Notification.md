# Notification



#### 本地通知创建

```
let content = UNMutableNotificationContent()
content.title = ""
content.subtitle = ""
content.body = ""
// content.userInfo = object
// 创建
let notiRequest = UNNotificationRequest(identifier: "com.metajoy.noti.local", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
UNUserNotificationCenter.current().add(notiRequest) { e in
    if e != nil {
        print("Local Noti Request Send Failed: " + e.debugDescription)
    }
}

```

