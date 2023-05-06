//
//  main.swift
//  design-hashset
//
//  Created by 大大 on 2022/7/5.
//
/*:
 ***LeetCode: 705. 设计哈希集合
 *https://leetcode.cn/problems/design-hashset/
 
 不使用任何内建的哈希表库设计一个哈希集合（HashSet）。

 实现 MyHashSet 类：

 void add(key) 向哈希集合中插入值 key 。
 bool contains(key) 返回哈希集合中是否存在这个值 key 。
 void remove(key) 将给定值 key 从哈希集合中删除。如果哈希集合中没有这个值，什么也不做。
  
 示例：

 输入：
 ["MyHashSet", "add", "add", "contains", "contains", "add", "contains", "remove", "contains"]
 [[], [1], [2], [1], [3], [2], [2], [2], [2]]
 输出：
 [null, null, null, true, false, null, true, null, false]

 解释：
 MyHashSet myHashSet = new MyHashSet();
 myHashSet.add(1);      // set = [1]
 myHashSet.add(2);      // set = [1, 2]
 myHashSet.contains(1); // 返回 True
 myHashSet.contains(3); // 返回 False ，（未找到）
 myHashSet.add(2);      // set = [1, 2]
 myHashSet.contains(2); // 返回 True
 myHashSet.remove(2);   // set = [1]
 myHashSet.contains(2); // 返回 False ，（已移除）
  

 提示：

 0 <= key <= 106
 最多调用 104 次 add、remove 和 contains

 
 */
import Foundation

class MyHashSet {

    private var lists = [Int]()
    
    init() { }
    
    func add(_ key: Int) {
        if !lists.contains(key) {
            lists.append(key)
        }
    }
    
    func remove(_ key: Int) {
        lists.removeAll { $0 == key }
    }
    
    func contains(_ key: Int) -> Bool {
        return lists.contains(key)
    }
}

let obj = MyHashSet()
obj.add(10)
obj.remove(10)
let ret_3: Bool = obj.contains(10)

/*:
 ***LeetCode: 706. 设计哈希映射
 *https://leetcode.cn/problems/design-hashmap/
 
 不使用任何内建的哈希表库设计一个哈希映射（HashMap）。

 实现 MyHashMap 类：

 MyHashMap() 用空映射初始化对象
 void put(int key, int value) 向 HashMap 插入一个键值对 (key, value) 。如果 key 已经存在于映射中，则更新其对应的值 value 。
 int get(int key) 返回特定的 key 所映射的 value ；如果映射中不包含 key 的映射，返回 -1 。
 void remove(key) 如果映射中存在 key 的映射，则移除 key 和它所对应的 value 。
  

 示例：

 输入：
 ["MyHashMap", "put", "put", "get", "get", "put", "get", "remove", "get"]
 [[], [1, 1], [2, 2], [1], [3], [2, 1], [2], [2], [2]]
 输出：
 [null, null, null, 1, -1, null, 1, null, -1]

 解释：
 MyHashMap myHashMap = new MyHashMap();
 myHashMap.put(1, 1); // myHashMap 现在为 [[1,1]]
 myHashMap.put(2, 2); // myHashMap 现在为 [[1,1], [2,2]]
 myHashMap.get(1);    // 返回 1 ，myHashMap 现在为 [[1,1], [2,2]]
 myHashMap.get(3);    // 返回 -1（未找到），myHashMap 现在为 [[1,1], [2,2]]
 myHashMap.put(2, 1); // myHashMap 现在为 [[1,1], [2,1]]（更新已有的值）
 myHashMap.get(2);    // 返回 1 ，myHashMap 现在为 [[1,1], [2,1]]
 myHashMap.remove(2); // 删除键为 2 的数据，myHashMap 现在为 [[1,1]]
 myHashMap.get(2);    // 返回 -1（未找到），myHashMap 现在为 [[1,1]]
  

 提示：

 0 <= key, value <= 106
 最多调用 104 次 put、get 和 remove 方法
 */
class MyHashMap {

    var map = [Int](repeating: -1, count: 108 )
    
    init() { }
    
    func put(_ key: Int, _ value: Int) {
        map[key] = value
    }
    
    func get(_ key: Int) -> Int {
      return map[key]
    }
    
    func remove(_ key: Int) {
        map[key] = -1
    }

}
