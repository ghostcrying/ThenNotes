/*:
 VIPER iOS Design Pattern
 ========
 
 `Entity` + `Interactor` + `Presenter` + `View` + `Router`
  
 ![Image](VIPER.png "Local image")
 
 > The most of distribution for responsibility but the most of high maintenance cost
 >
 > `Model` now is `Entity` but with `Interactor` to act as its data provider
 >
 > `Presenter` hooks up with both `View` and `Interactor`.
 >
 > `Presenter` hooks up with `Interactor` to get notified for its `Entity`'s states update
 >
 > `Presenter` hooks up with `View` (owned by) to allow functionality for `View` to get its representable data to show
 >
 > `Router` is responsible for switching the screen (UIViewController)
 

 ## Table of Contents
 
 * [MVC](MVC)
 * [MVVM](MVVM)
 * [MVP](MVP)
 * [VIPER](VIPER)
 * [Behavioral](Behavioral)
 * [Creational](Creational)
 * [Structural](Structural)
 */


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

