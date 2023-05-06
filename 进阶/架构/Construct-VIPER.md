# VIPER



### Entity + Interactor + Presenter + View + Router

```
VIPER是视图(View)、交互器(Interactor)、展示器(Presenter)、实体(Entity)和路由(Routing)的首字母缩写
V-视图：根据展示器的要求显示界面，并将用户输入反馈给展示器；这里不仅仅是指UIView或其子类，还包括UIViewController，主要负责一些视图的显示、布局、用户事件的接收及转发
I-交互器：包含由用力指定的业务逻辑；
P-展示器：包含为显示（从交互器接受的内容）做的准备工作的相关视图逻辑，并对用户输入进行反馈（从交互器获取新数据）
E-实体：包含交互器要使用的基本模型对象
R-路由：包含用来描述屏幕显示和显示顺序的导航逻辑
```

![mvvm.png](https://github.com/ghostcrying/ThenNotes/blob/main/Assets/Construct/viper_1.png?raw=true)

```
在VIPER的实际应用中，组件之间可以以任意顺序来实现，但在个人的实现过程中，经过反复的理论推敲和实践，推荐使用这样的顺序来进行实现。
```

> The most of distribution for responsibility but the most of high maintenance cost
>
> Model now is Entity but with Interactor to act as its data provider
>
> Presenter hooks up with both View and Interactor.
>
> Presenter hooks up with Interactor to get notified for its Entity's states update
>
> Presenter hooks up with View (owned by) to allow functionality for View to get its representable data to show
>
> Router is responsible for switching the screen (UIViewController)

 

#### 交互器

​        交互器的任务是根据业务逻辑来操纵模型对象（即实体），它的工作应当独立于任何用户界面，只对外暴露相应的接口接口；同样的交互器应当可以同时运用于iOS应用或 OS X应用中。交互器主要包含逻辑，因此非常容易使用TDD进行开发。故此，在实现交互器的时候，只需要是一个普通的NSObject即可，在其内部处理对应的业务逻辑，并向外提供简明的交互接口。

#### 实体

​        实体是被且仅被交互器操作的模型对象，此处再次声明交互器的作用：处理所有的业务逻辑。在swift环境下，实体可以通过NSObject、Struct来实现，如果使用了Core Data，最好将托管对象保持在数据层之后。

#### 展示器

​        在实现VIPER的过程中，展示器也是基于NSObject来实现的。展示器收集来自用户的行为交互，在合适的时候更新用户界面并向交互器发送业务请求。在我们实现的过程中，展示器是整个 VIPER 架构的枢纽（也有人偏向于以 Interactor 为枢纽，通过具体实践，个人推荐使用 Presenter），主要功能是各类消息的转发和界面路由，如：Presenter 从 View 获得用户事件的消息，并发送给 Interactor ，Interactor 进行相应逻辑处理后，反馈消息给 Presenter，Presenter 将消息再反馈到 View 上。

#### 视图

​        视图一般处于一种被动接受的状态，被动接收来自用户的行为交互，被动接收由展示器传递来的消息（如展示器下发的需要展示的内容）。展示器不知道视图中存在的控件，只负责告诉视图在合适需要显示什么样的内容，内容如何显示由视图自行处理。

#### 路由

​        在实现路由的过程中，我尝试过两种方案，一种是网上大多数VIPER架构文章中介绍的wireframe（线框），另一种是基于URL的router。这两种方案都实现以下两个目的：

1. 建立路由中间件，所有的界面跳转由中间件处理；
2. 所有界面跳转可交由后台控制，APP做好路由节点注册；

​        在实现路由模块的过程中，不管是线框还是GSRouter，都是去注册目标vc的生成过程（以block的形式）。简单来说就是，当路由中间件发现你要跳转到某个vc的时候，就去调用这个vc对应的block，在block中初始化该vc，然后将初始化好的vc对象回调出来，再根据跳转形式（present/dismiss or push/pop）进行跳转，同时，还可以为跳转配置对应的动画效果。当然，如果你使用的是storyboard，可以运用建造者模式写一个通用的vc对象生成方法（builder），不需要再经过block，然后为UIViewController添加一个参数自动解析方法，这样你的路由模块就已经具有了基本的功能了



### Example:

```
import UIKit
import PlaygroundSupport

struct Person { // Entity 模型
    let firstName: String
    let lastName: String
}

struct GreetingData {   // another layer of Data
    let greeting: String
    let subject: String
}

protocol GreetingProvider {
    func provideGreetingData()
}

protocol GreetingOutput: AnyObject {
    func receiveGreetingData(greetingData: GreetingData)
}

class GreetingInteractor: GreetingProvider {
    weak var output: GreetingOutput!
    
    func provideGreetingData() {
        let person = Person(firstName: "Wasin", lastName: "Thonkaew")
        let subject = person.firstName + " " + person.lastName
        let greeting = GreetingData(greeting: "Hello", subject: subject)
        self.output.receiveGreetingData(greetingData: greeting)
    }
}

protocol GreetingViewEventHandler {
    func didTapShowGreetingButton()
}

protocol GreetingView: AnyObject {
    func setGreeting(greeting: String)
}

class GreetingPresenter: GreetingOutput, GreetingViewEventHandler {
    weak var view: GreetingView!
    var greetingProvider: GreetingProvider!
    
    /// V触发事件, 由P去处理, P将业务处理丢给I去处理, I处理结束后output到P, P再对V进行操作
    func didTapShowGreetingButton() {
        self.greetingProvider.provideGreetingData()
    }
    
    func receiveGreetingData(greetingData: GreetingData) {
        let greeting = greetingData.greeting + " " + greetingData.subject
        self.view.setGreeting(greeting: greeting)
    }
}

class GreetingViewController : UIViewController, GreetingView {
    var eventHandler: GreetingViewEventHandler!
    var showGreetingButton: UIButton!
    var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        self.setupUIElements()
        self.layout()
    }
    
    func setGreeting(greeting: String) {
        self.greetingLabel.text = greeting
    }
    
    func setupUIElements() {
        self.title = "Test"
        
        self._setupButton()
        self._setupLabel()
    }
    
    private func _setupButton() {
        self.showGreetingButton = UIButton()
        self.showGreetingButton.setTitle("Click me", for: .normal)
        self.showGreetingButton.setTitle("You badass", for: .highlighted)
        self.showGreetingButton.setTitleColor(UIColor.white, for: .normal)
        self.showGreetingButton.setTitleColor(UIColor.red, for: .highlighted)
        self.showGreetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.showGreetingButton.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        self.view.addSubview(self.showGreetingButton)
    }
    
    private func _setupLabel() {
        self.greetingLabel = UILabel()
        self.greetingLabel.textColor = UIColor.white
        self.greetingLabel.textAlignment = .center
        self.greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.greetingLabel)
    }
    
    func layout() {
        self._layoutButton()
        self._layoutLabel()
        
        self.view.layoutIfNeeded()
    }
    
    private func _layoutButton() {
        // layout button at the center of the screen
        let cs1 = NSLayoutConstraint(item: self.showGreetingButton!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 1.0)
        let cs2 = NSLayoutConstraint(item: self.showGreetingButton!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 1.0)
        
        self.view.addConstraints([cs1, cs2])
    }
    
    private func _layoutLabel() {
        // layout label at the center, bottom of the screen
        let cs1 = NSLayoutConstraint(item: self.greetingLabel!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 1.0)
        let cs2 = NSLayoutConstraint(item: self.greetingLabel!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        let cs3 = NSLayoutConstraint(item: self.greetingLabel!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.70, constant: 0)
        
        self.view.addConstraints([cs1, cs2, cs3])
    }
    
    @objc func didTapButton(sender: UIButton) {
        self.eventHandler.didTapShowGreetingButton()
    }
}

// Assembling of VIPER without Router]
let view = GreetingViewController()   /// v
let presenter = GreetingPresenter()   /// p
let interactor = GreetingInteractor() /// I
view.eventHandler = presenter
presenter.view = view
presenter.greetingProvider = interactor
interactor.output = presenter

PlaygroundPage.current.liveView = view.view
```

