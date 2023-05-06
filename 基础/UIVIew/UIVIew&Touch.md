# 响应链&传递链



#### 事件产生

>  UIResponser的子类, touchbegan, move, ended, cancel 产生UIEvent事件



#### 事件响应

##### 时间分发机制

![img](https://cdn.nlark.com/yuque/0/2021/png/1728826/1610689654971-f1e0cb22-65c5-4bcb-aef8-5c67d84bdc78.png?x-oss-process=image%2Fresize%2Cw_601%2Climit_0)

- 事件链UIApplication -> UIWindow -> UIView 从后往前遍历view的subviews -> 找到最佳view

  - UIViewController没有hitTest:withEvent:方法，所以控制器不参与查找响应视图的过程. 但是控制器在响应者链中, 如果控制器的View不处理事件, 会交给控制器来处理. 控制器不处理的话，再交给View的下一级响应者处理

- 响应视图查找

  - 不响应情况
    - 不允许交互
    - 视图透明
    - 隐藏
  - 判定子视图响应
    - convertPoint:toView, 找到子视图点
    - hitTest:withEvent, 判定是否是合适的响应视图

  ```
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      // 1.如果控件不允许与用用户交互, 那么返回nil
      guard self.isUserInteractionEnabled, self.alpha > 0.01, !self.isHidden else {
          return nil
      }
      // 2. 如果点击的点在不在当前控件中,返回nil
      guard self.point(inside: point, with: event) else {
          return nil
      }
      // 3. 逆序遍历
      for sub in subviews.reversed() {
          // 当前触摸点坐标转换为相对子视图触摸点的坐标
          let p = self.convert(point, to: sub)
          // 判断子视图是否找到更合适的子视图(递归)
          if let fitView = sub.hitTest(p, with: event) {
              return fitView
          }
      }
      // 4.没找到,表示没有比自己更合适的view,返回自己
      return self
  }
  ```

##### 响应链

- 从view开始查找响应 - 父视图 -> UIView -> UIViewController -> UIWindow -> UIApplication -> UIApplicationDelegate -> 丢弃

- touchbegin:withEvent只要重写即可响应

- UIControll的子类: 是第一响应者则直接由UIApplication派发事件, 打断Response Chain, 如果其不能处理事件, 则交给手势处理或者响应链传递

- 当响应者链和手势同时出现时，也就是既实现了touches方法又添加了手势，会发现touches方法有时会失效，这是因为手势的执行优先级是高于响应者链的

  - 在UIApplication向第一响应者派发事件, 并且遍历响应者链查找手势时, 会开始执行响应者链中的touches系列方法. 会先执行touchesBegan和touchesMoved方法, 如果响应者链能够继续响应事件, 则执行touchesEnded方法表示事件完成, 如果将事件交给手势处理则调用touchesCancelled方法将响应者链打断

  >  手势识别
  >
  >  \- _UIApplicationHandleEventQueue()识别了一个手势, 首先会调用 Cancel 将当前的 touchesBegin/Move/End 系列回调打断。随后系统将对应的 UIGestureRecognizer 标记为待处理
  >
  >  \- 苹果注册了一个 Observer 监测 BeforeWaiting (Loop即将进入休眠) 事件，这个 Observer 的回调函数是 _UIGestureRecognizerUpdateObserver()，其内部会获取所有刚被标记为待处理的 GestureRecognizer，并执行GestureRecognizer 的回调。
  >
  >  \- 当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理。



### 注意:

> ###### 为什么用队列管理事件,  而不用栈？
>
> - 队列先进先出,能保证先产生的事件先处理。栈先进后出。



#### CALayer添加点击事件

```
var judgelayer: CALayer!
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 通过layer坐标判定
    for t in touches {
        let p = t.location(in: self)
        if self.judgelayer.contains(self.judgelayer.convert(p, from: layer)) {
            print("事件触发")
        }
    }
    // 通过hitTest返回包含坐标系的 layer 视图
    for t in touches {
        let p = t.location(in: self)
        if self.layer.hitTest(p) == self.judgelayer {
            print("事件触发")
        }
    }
}
```



#### 应用

- **点击穿透**

  - 平行视图：重新hitTest,返回想要点击的View

  - 父子视图: 如果子视图是Button 将button的enable改为false。如果是view不要添加手势即可。

- **限定点击区域**

  ```
  class MyButton: UIButton {
      override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
          let margin: CGFloat = 5
          // 负值是方法响应范围
          let area = self.bounds.insetBy(dx: -margin, dy: -margin)
          return area.contains(point)
      }
  }
  
  # 如果使用Runtime进行重写的话会导致所有按钮都被修改 (不可取)
  extension UIButton {
      
      private static var Expandkey = "uibutton.expanded.key"
      
      open func expand(_ value: CGFloat) {
          objc_setAssociatedObject(self, &UIButton.Expandkey, value, .OBJC_ASSOCIATION_ASSIGN)
      }
      
      open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
          if let value = objc_getAssociatedObject(self, &UIButton.Expandkey) as? CGFloat {
              let r = CGRect(x: bounds.origin.x - value, y: bounds.origin.y - value, width: bounds.size.width + 2*value, height: bounds.size.height + 2*value)
              return r.contains(point)
          }
          return super.point(inside: point, with: event)
      }
  }
  ```

  
