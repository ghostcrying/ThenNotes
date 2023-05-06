# Autolayout



## 前言

### translatesAutoresizingMaskIntoConstraints

- 默认为`true`
- 把 autoresizingMask 转换为 Constraints
- 即：可以把 frame ，bouds，center 方式布局的视图自动转化为约束形式。（此时该视图上约束已经足够 不需要手动去添加别的约束）

------

- 用代码创建的所有view ， translatesAutoresizingMaskIntoConstraints 默认是 YES
- 用 IB 创建的所有 view ，translatesAutoresizingMaskIntoConstraints 默认是 ~~NO~~ (autoresize 布局:YES , autolayout布局 :NO)

> translatesAutoresizingMaskIntoConstraints 的本意是将 frame 布局自动转化为 约束布局，转化的结果是为这个视图自动添加所有需要的约束，如果我们这时给视图添加自己创建的约束就一定会约束冲突。
>
> 为了避免上面说的约束冲突，我们在代码创建 约束布局 的控件时 直接指定这个视图不能用frame 布局（即translatesAutoresizingMaskIntoConstraints=NO），可以放心的去使用约束了



## 方式

```
// 初始化UI
label = UILabel()
label.textAlignment = .center
label.text = "Autolayout"
label.layer.borderWidth = 1
label.layer.cornerRadius = 10
label.backgroundColor = UIColor.black
view.addSubview(label)
// 启用代码约束
label.translatesAutoresizingMaskIntoConstraints = false
```

##### 方式一

```
// layout
label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
label.heightAnchor.constraint(equalToConstant: 50).isActive = true
label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
```

##### 方式二

```
let cs1 = NSLayoutConstraint(item: self.label!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 100)
let cs4 = NSLayoutConstraint(item: self.label!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50)
let cs2 = NSLayoutConstraint(item: self.label!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 100.0)
let cs3 = NSLayoutConstraint(item: self.label!, attribute: .centerX, relatedBy: .equal,    toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)

view.addConstraints([cs1, cs2, cs3, cs4])
```

##### 方式三

```
NSLayoutConstraint.activate([
    label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
    label.heightAnchor.constraint(equalToConstant: 50),
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
])
```



## SnpKit

动画如何才能生效?

```
# 当前代码动画不生效
UIView.animate(withDuration: 10) { self.editor.snp.updateConstraints { $0.bottom.equalTo(100) } }
# 修改
self.editor.snp.updateConstraints { $0.bottom.equalTo(100) }
UIView.animate(withDuration: 10) { self.view.layoutIfNeeded() }
```

#### 第一步：

添加好视图约束，到特定的时候，更新视图约束

#### 第二步：

- 控制器里面

```swift
/// 告诉self.view约束需要更新
self.view.needsUpdateConstraints()
/// 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
self.view.updateConstraintsIfNeeded()
/// 更新动画
UIView.animate(withDuration: 0.5, animations: {
    self.view.layoutIfNeeded()
})
```

- 视图里面

```ruby
///  告诉self.view约束需要更新
self.needsUpdateConstraints()
// / 调用此方法告诉self.view检测是否需要更新约束，若需要则更新，下面添加动画效果才起作用
self.updateConstraintsIfNeeded()
/// 更新动画
UIView.animate(withDuration: 0.5, animations: {
     self.layoutIfNeeded()
})
```

相应的方法

```swift
setNeedsLayout：告知页面需要更新，但是不会立刻开始更新。执行后会立刻调用layoutSubviews。
layoutIfNeeded：告知页面布局立刻更新。所以一般都会和setNeedsLayout一起使用。如果希望立刻生成新的frame需要调用此方法，利用这点一般布局动画可以在更新布局后直接使用这个方法让动画生效。
layoutSubviews：系统重写布局
setNeedsUpdateConstraints：告知需要更新约束，但是不会立刻开始
updateConstraintsIfNeeded：告知立刻更新约束
updateConstraints：系统更新约束
```

