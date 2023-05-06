/*:
 
 MVP iOS Design Pattern
 ========
  
 `Model` + `UIViewController` + `Presenter`
 
 or
 
 `Model` + `Passive View` + `Presenter`
 
 Usually regard
 
 - `UIViewController` -> `UIView`
 - `Presenter`` -> `UIViewController` or simply Controller in general term
 
 ![Image](MVP.png "Local image")
 
 `Passive View` as compared to `UIViewController` in MVC in which the latter is more active in making activity compared to former which will be called by `Presenter` to update its state.
 
 
 > `Model` structure is defined isolatedly in the same way as did in MVC
 >
 > There are 2 new protocols defined: one for `Passive View`, and another one for `Presenter`.
 >
 > `Passive View` protocol provides functionality (aim at `Presenter`) to update its state
 >
 > `Presenter` protocol provides functionality to initialize itself using both `Passive View` and model as parameters, and others to control or update its in-controlled `Passive View`
 >
 > The possible reason that `Presenter` needs to be embedded inside `Passive View` is because `Passive View` is actually `UIViewController` which normally is the default entry of to show on screen or operate in iOS sense. It's embedded there to allow code to make use of it.
 >
 > `Passive View` won't update its state by itself, but it provides how it is going to show UI element on screen. Instead it's up to `Presenter` to update the state. You can see in `GreetingViewController` class that it handles all UI layouting including constraints, and how to show on screen, but doesn't care about the states (values) of individual UI element which is `UILabel` in this case.
 
 
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

struct Person { // Model
    let firstName: String
    let lastName: String
}

// 协议
protocol GreetingView: AnyObject {
    func setGreeting(greeting: String)
}
// 协调器
protocol GreetingViewPresenter {
    init(view: GreetingView, person: Person)
    func showGreeting()
}

class GreetingPresenter: GreetingViewPresenter {
    weak var view: GreetingView? // 弱持有
    let person: Person
    
    required init(view: GreetingView, person: Person) {
        self.view = view
        self.person = person
    }
    
    func showGreeting() {
        let greeting = "Hello " + self.person.firstName + " " + self.person.lastName
        self.view?.setGreeting(greeting: greeting)
    }
}

class GreetingViewController: UIViewController, GreetingView {
    var presenter: GreetingViewPresenter!
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
        self.presenter.showGreeting()
    }
}

// Assembling of MVP
// Note: Very important that these following lines will be within View when actually creating normal XCode project and follow design here.
let model = Person(firstName: "Wasin", lastName: "Thonkaew")
let view = GreetingViewController()
let presenter = GreetingPresenter(view: view, person: model)
view.presenter = presenter

PlaygroundPage.current.liveView = view.view
