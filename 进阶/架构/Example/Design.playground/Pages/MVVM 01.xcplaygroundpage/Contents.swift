//: [Previous](@previous)

import Foundation

class Bind<T> {
    /// 包
    typealias Handler = (T) -> ()
    /// 处理
    private var handles: [Handler] = []
    
    private var skip: Int = 0
    
    /// 读取
    public var value: T {
        didSet {
            self.fire()
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    /// 绑定并触发
    public func bindFire(handle: @escaping (Handler)) {
        self.handles.append(handle)
        if self.skip == 0 {
            self.fire()
        } else {
            self.skip -= 1
        }
    }
    
    public func skipfirst() -> Bind<T> {
        self.skip = 1
        return self
    }
    
    public func fire() {
        for handle in handles {
            handle(self.value)
        }
    }
}


class Person {
    
    var state = Bind<Int>(0)
    
    var num: Int = 0
    var num1: Int = 2
    
    func changeState() {
        num += 1
        state.value = num
    }
}

let p = Person()
p.state.bindFire { (i) in
    print("fire direct: \(i)")
}
p.state.skipfirst().bindFire { (i) in
    print("fire skip: \(i)")
}
p.changeState()


//: [Next](@next)
