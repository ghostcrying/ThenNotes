#### Array

- 增加

```
每个数组都会保留特定数量的内存来保存其内容。当向数组中添加元素时，该数组超过其预留的容量，该数组就会分配更大的内存空间，并将它的所有元素赋值到新的存储空间。添加一个元素的时间时固定的，相对来说性能是平均的。但是重新分配的操作会带来性能成本，随着数组的增大，这些操作发生的频率也会越来越低。
如果知道大约需要存储多少元素，在添加到元素之前使用 reserveCapacity(_:) 函数，避免中间重新分配。使用 count 和 capacity 属性来确定数组在不分配更大存储空间的情况下还可以存储多少元素。

var array = [1, 2]
array.reserveCapacity(20)
```

- 拷贝

  - 每个数组都有一个独立的存储空间，存储着数组中包含的所有元素的值。对于简单类型，如整数或者其他结构，当更改一个数组中的值时，该元素的值不会在数组的任何副本中更改

    ```
    var numbers = [4, 5, 6]
    var numbersCopy = numbers
    
    numbers[0] = 9
    print(numbers)
    // Prints "[9, 5, 6]"
    print(numbersCopy)
    // Prints "[4, 5, 6]"
    ```

  - 如果数组的元素是类的实例。在本例中，存储在数组中的值时对存在于数组之外的对象引用。如果更改一个数组中对象的引用 ，则只有该数组有对新对象的引用。但是，如果两个数组包含对同一个对象的引用，则可以从两个数组中看到该对象属性的更改

    ```
    class InterR {
      var value = 10
    }
    ​
    var integers1 = [InterR(), InterR()]
    var integers2 = integers1
    ​
    integers1[0].value = 100
    print(integers2[0].value)
    // Prints "100"
    ​
    integers1[0] = InterR()
    print(integers1[0].value)
    // Prints "10"
    print(integers2[0].value)
    // Prints "100"
    ```

    

#### UserDefault

- 路径 

```
guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
    return
}
let path = NSHomeDirectory() + "/Library" + "/Preferences" + "/\(bundleIdentifier)" + ".plist"

print(path)
```

- 存储模型

```
extension UserDefaults {
    /// 遵守Codable协议的set方法
    ///
    /// - Parameters:
    ///   - object: 泛型的对象
    ///   - key: 键
    ///   - encoder: 序列化器
    public func setCodableObject<T: Codable>(_ object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {

        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }

    /// 遵守Codable协议的get方法
    ///
    /// - Parameters:
    ///   - type: 泛型的类型
    ///   - key: 键
    ///   - decoder: 反序列器
    /// - Returns: 可选类型的泛型的类型对象
    public func getCodableObject<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
}

/// var dict = ["age": 10]
/// print(dict["age"])
/// dict["age"] = 20
/// print(dict["age"])
```

- 读写

```
extension UserDefaults {

    /// 针对Any?
    public subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
    
    /// 针对Int
    public subscript(int key: String) -> Int {
        get {
            return integer(forKey: key)
        }

        set {
            set(newValue, forKey: key)
        }
    }
}

/// UserDefaults.standard["name"] = "season"
/// print(UserDefaults.standard["name"]) // Optional(season)

/// UserDefaults.standard[int: "age"] = 10
/// print(UserDefaults.standard[int: "age"]) // 10
```

