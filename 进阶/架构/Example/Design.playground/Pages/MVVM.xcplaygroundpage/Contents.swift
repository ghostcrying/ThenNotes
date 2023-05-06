/*:
 ## MVVM iOS Design Pattern
 
 `Model` + `View Model` + `View`
 
 Usually regard
 
 - `View Model` -> the handler or controller of model
 - `View` -> ``UIViewController`` or simply Controller in general term
 
 ![Image](MVVM.png "Local image")
 
 ios code
 
 ![Image](MVVM.Code.png "Local image")
 
 > It's very similar to MVP but with binding setup in code. Like a supervisoning version of MVP.
 >
 > `View` has more activities to do compared to MVP. Instead of `View` to provide functionality for `View Model` to update its state. `View` will do by itself via binding which is setup in code.
 >
 > Binding can be regarded as reactive programming approach. Users can utilize reactive library out there i.e. [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), or [RxSwift](https://github.com/ReactiveX/RxSwift). Or just go via callback approach.
 >
 > `View Model` is added as part of `View` can be viewed for a reason as because `View Model` is supervisoning of `View`, but it's not so strong reason.
 >
 > Anyway from previous point, separating `View Model` and `View` from each other is to have better testability. `View Model` doesn't have to know about `View`. Thus now we have separated component which can be further tested separately.
 >
 > I think MVP already done a great job at distribution, but MVVM does it better to remove completely a requirement for `View Model` to have a knowledge about its `View`.
 
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

protocol GreetingViewModelProtocol: AnyObject {
    var greeting: String? { get }
    var greetingDidChange: ((GreetingViewModelProtocol) -> ())? { get set }
    init(person: Person)
    func showGreeting()
}

class GreetingViewModel : GreetingViewModelProtocol {
    let person: Person
    
    var greeting: String? {
        didSet {
            self.greetingDidChange?(self)
        }
    }
    
    var greetingDidChange: ((GreetingViewModelProtocol) -> ())?
    
    required init(person: Person) {
        self.person = person
    }
    
    func showGreeting() {
        self.greeting = "Hello " + self.person.firstName + " " + self.person.lastName
    }
}

class GreetingViewController : UIViewController {
    var viewModel: GreetingViewModelProtocol? {
        didSet {
            self.viewModel?.greetingDidChange = { [unowned self] viewModel in
                self.greetingLabel.text = viewModel.greeting
            }
        }
    }
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
        
        guard let vm = self.viewModel else { return }
        
        vm.showGreeting()
    }
}

// Assembling of MVVM
let model = Person(firstName: "Wasin", lastName: "Thonkaew")
let view = GreetingViewController()
let viewModel = GreetingViewModel(person: model)
view.viewModel = viewModel

PlaygroundPage.current.liveView = view.view
