/*:
 
 MVC iOS Design Pattern
 ==========
 
 `Model` + (`View + Controller`)
 
 ![Image](MVC.png "Local image")
 
 Code
 
 > UI elements and its auto-layout mechanism are done via code-only through constraints (`NSLayoutConstraint(item:, attribute:, relatedBy:, toItem:, attribute:, multiplier:, constant:)`).
 >
 > Show UIView on screen via `PlaygroundPage.current.liveView = yourVC.view`
 >
 > You can also set up constraint via [Visual Format Language](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html) but just for personal taste, I found that using `NSLayoutConstraint(item:, attribute:, relatedBy:, toItem:, attribute:, multiplier:, constant:)` is more robust and offer complete functionality.
 
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

class GreetingViewController : UIViewController {   // View + Controller
    var person: Person!
    var showGreetingButton: UIButton!
    var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: 320, height: 640)
        self.view.backgroundColor = UIColor.white
        self.setupUIElements()
        self.layout()
    }
    
    func setupUIElements() {
        self.title = "Test"
        
        self._setupButton()
        self._setupLabel()
    }
    
    private func _setupButton() {
        self.showGreetingButton = UIButton()
        self.showGreetingButton.setTitle("Click me", for: .normal)
        self.showGreetingButton.setTitleColor(UIColor.black, for: .normal)
        self.showGreetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.showGreetingButton.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        self.view.addSubview(self.showGreetingButton)
    }
    
    private func _setupLabel() {
        self.greetingLabel = UILabel()
        self.greetingLabel.text = "Hi!"
        self.greetingLabel.textColor = UIColor.darkGray
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
        let cs2 = NSLayoutConstraint(item: self.greetingLabel!, attribute: .bottom, relatedBy: .equal, toItem: self.showGreetingButton, attribute: .bottom, multiplier: 1.0, constant: 50)
        let cs3 = NSLayoutConstraint(item: self.greetingLabel!, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.70, constant: 0)
        
        self.view.addConstraints([cs1, cs2, cs3])
    }
    
    @objc func didTapButton(sender: UIButton) {
        self.greetingLabel.text = "Hello " + self.person.firstName + " " + self.person.lastName + "!"
    }
}

let model = Person(firstName: "John", lastName: "Tom")
let vc = GreetingViewController()
vc.person = model

PlaygroundPage.current.liveView = vc

