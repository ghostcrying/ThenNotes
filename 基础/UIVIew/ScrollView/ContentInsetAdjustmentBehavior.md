##### ContentInsetAdjustmentBehavior

```
* iOS 7中使用automaticallyAdjustsScrollViewInsets该方法来自动调整 UIScrollView 的 contentInset.* * 在iOS 11之后将会使用 UIScrollView 的 contentInsetAdjustmentBehavior 属性来代替该方法。
```

- UIScrollViewContentInsetAdjustmentScrollableAxes

  - 如果scrollView的ContentSize很小，则不考虑安全区域

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentAlways.png?raw=true)

  - ContentSize大于超出显示范围，则计算安全区域
    - 被拉长了，纵向可以滚动，横向宽度不够不能滚动。红色是横向方向，不可滚动，安全区域被忽略。

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentScrollableAxes2.png?raw=true)

  - 如果强制横向滚动，则计算安全区域
    - 图片超长
    - 强制横向滚动
    - 则两个安全区域都会被考虑

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentScrollableAxes3.png?raw=true)
  
  

- UIScrollViewContentInsetAdjustmentAutomatic

  - 就算不够高度，也会空出上下两部分的安全区域
    - 图片很小，不够撑满屏幕，但是用这个参数，会空出上下方向的安全区域

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentAutomatic.png?raw=true)

  - 其他的行为与UIScrollViewContentInsetAdjustmentScrollableAxes一致

- UIScrollViewContentInsetAdjustmentNever

  - 就算你的ScrollView超出了safeAreaInsets，系统不会对你的scrollView.adjustedContentInset做任何事情，即不作任何调整.

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentNever.png?raw=true)

- UIScrollViewContentInsetAdjustmentAlways

  - 不管内容够不够大，全部考虑安全区域

  ![](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/UIScrollView/ContentInsetAdjustmentAlways.png?raw=true)
