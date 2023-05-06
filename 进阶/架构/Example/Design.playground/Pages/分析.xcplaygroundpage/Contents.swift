//: [Previous](@previous)

/*:
 ### 首先前三种模式都是把所有的实体归类到了下面三种分类中的一种：
- Models（模型）数据层，或者负责处理数据的 数据接口层。
- Views（视图） - 展示层(GUI)。对于 iOS理论上来来说所有以 UI 开头的类基本都属于这层。
- Controller/Presenter/ViewModel（控制器/展示器/视图模型
  - 它是 Model 和 View 之间的胶水或者说是中间人。
  - 一般来说，当用户对 View 有操作时它负责去修改相应 Model；当 Model 的值发生变化时它负责去更新对应 View。

 ## MVC、MVP、MVVM之间的区别
 ### MVC和MVP的关系
 - 我们都知道MVP是从经典的模式MVC演变而来，它们的基本思想有相通的地方：
Controller/Presenter负责逻辑的处理，Model提供数 据，View负责显示。作为一种新的模式，
MVP与MVC有着一个重大的区别：在MVP中View并不直接使用Model，
它们之间的通信是通过 Presenter (MVC中的Controller)来进行的，所有的交互都发生在Presenter内部，
而在现实中的MVC中View会直接从Model中读取数据而不是通过 Controller。
 ### MVVM和MVP的关系
 - 而 MVVM 模式将 Presenter 改名为 ViewModel，基本上与 MVP 模式完全一致。
唯一的区别是，它采用双向绑定（data-binding）：View的变动，自动反映在 ViewModel，反之亦然。
这样开发者就不用处理接收事件和View更新的工作，框架已经帮你做好了。
*/

//: [Next](@next)
