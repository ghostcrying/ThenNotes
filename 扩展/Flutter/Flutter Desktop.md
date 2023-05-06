1. Flutter的master默认是关闭桌面应用, 命令开启

```undefined
# mac
flutter config --enable-macos-desktop
# linux
flutter config --enable-linux-desktop
# pc
flutter config --enable-windows-desktop
```

2. 查看本机支持的桌面模拟器

```undefined
flutter devices
```

3. 创建mac应用工程

```undefined
flutter create --macos desktop_macos_demo
```

4. 增加mac,windows平台支持

```undefined
flutter create --platforms=windows,macos
# flutter create --platforms=windows
# flutter create --platforms=macos
```

5. 编译对应平台

```undefined
flutter build macos
flutter build linux
flutter build windows
```