# Atomic

#### Struct

```
@propertyWrapper
struct Atomic<Value> {
    private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
    
    mutating func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync {
            mutation(&value)
        }
    }
}

struct MyStruct {
    @Atomic var x = 0

    mutating func increment() {
        _x.mutate { $0 += 1 }
    }
}

var value = MyStruct()
value.increment() // `x` equals 
```

#### Class

```
@propertyWrapper
class Atomic<Value> {

   private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
   private var value: Value

   init(wrappedValue: Value) {
       self.value = wrappedValue
   }

   var wrappedValue: Value {
       get {
           return queue.sync { value }
       }
       set {
           queue.sync { value = newValue }
       }
   }

   var projectedValue: Atomic<Value> {
       return self
   }

   // The `mutating` modifier is removed
   func mutate(_ mutation: (inout Value) -> Void) {
       return queue.sync {
           mutation(&value)
       }
   }

}

struct AnotherStruct {
   @Atomic var x: [Int] = [1, 2, 3]
}
var value = AnotherStruct()
value.$x.mutate { $0[1] = 123 } // ✅ Atomic operation
```

