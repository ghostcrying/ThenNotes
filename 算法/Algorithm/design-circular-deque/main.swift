//
//  main.swift
//  design-circular-deque
//
//  Created by Putao0474 on 2022/7/1.
//
/**
 ***LeetCode: 641. 设计循环双端队列
 *https://leetcode.cn/problems/design-circular-deque

 实现 MyCircularDeque 类:

 MyCircularDeque(int k) ：构造函数,双端队列最大为 k 。
 boolean insertFront()：将一个元素添加到双端队列头部。 如果操作成功返回 true ，否则返回 false 。
 boolean insertLast() ：将一个元素添加到双端队列尾部。如果操作成功返回 true ，否则返回 false 。
 boolean deleteFront() ：从双端队列头部删除一个元素。 如果操作成功返回 true ，否则返回 false 。
 boolean deleteLast() ：从双端队列尾部删除一个元素。如果操作成功返回 true ，否则返回 false 。
 int getFront() )：从双端队列头部获得一个元素。如果双端队列为空，返回 -1 。
 int getRear() ：获得双端队列的最后一个元素。 如果双端队列为空，返回 -1 。
 boolean isEmpty() ：若双端队列为空，则返回 true ，否则返回 false  。
 boolean isFull() ：若双端队列满了，则返回 true ，否则返回 false 。
  

 示例 1：

 输入
 ["MyCircularDeque", "insertLast", "insertLast", "insertFront", "insertFront", "getRear", "isFull", "deleteLast", "insertFront", "getFront"]
 [[3], [1], [2], [3], [4], [], [], [], [4], []]
 输出
 [null, true, true, true, false, 2, true, true, true, 4]

 解释
 MyCircularDeque circularDeque = new MycircularDeque(3); // 设置容量大小为3
 circularDeque.insertLast(1);                    // 返回 true
 circularDeque.insertLast(2);                    // 返回 true
 circularDeque.insertFront(3);                    // 返回 true
 circularDeque.insertFront(4);                    // 已经满了，返回 false
 circularDeque.getRear();                  // 返回 2
 circularDeque.isFull();                        // 返回 true
 circularDeque.deleteLast();                    // 返回 true
 circularDeque.insertFront(4);                    // 返回 true
 circularDeque.getFront();                // 返回 4
  
  

 提示：

 1 <= k <= 1000
 0 <= value <= 1000
 insertFront, insertLast, deleteFront, deleteLast, getFront, getRear, isEmpty, isFull  调用次数不大于 2000 次
 
 */

import Foundation

class MyCircularDeque {
    
    private var capacity: Int // 容量
    private var front: Int
    private var last: Int
    private var lists: [Int]
    // k: 大小
    init(_ k: Int) {
        // 如果为看k, 没办法进行队列充满与空的判别
        capacity = k + 1
        //
        lists = [Int](repeating: 0, count: capacity)
        // 头部指向第 1 个存放元素的位置
        // 插入时，先减，再赋值
        // 删除时，索引 +1（注意取模）
        front = 0
        // 尾部指向下一个插入元素的位置
        // 插入时，先赋值，再加
        // 删除时，索
        last = 0
    }
    
    func insertFront(_ value: Int) -> Bool {
        if isFull() {
            return false
        }
        front = (front - 1 + capacity) % capacity
        lists[front] = value
        return true
    }
    
    func insertLast(_ value: Int) -> Bool {
        if isFull() {
            return false
        }
        lists[last] = value
        last = (last + 1) % capacity
        return true
    }
    
    func deleteFront() -> Bool {
        if isEmpty() {
            return false
        }
        front = (front + 1) % capacity
        return true
    }
    
    func deleteLast() -> Bool {
        if isEmpty() {
            return false
        }
        last = (last - 1 + capacity) % capacity
        return true
    }
    
    func getFront() -> Int {
        if isEmpty() {
            return -1
        }
        return lists[front]
    }
    
    func getRear() -> Int {
        if isEmpty() {
            return -1
        }
        return lists[(last - 1 + capacity) % capacity]
    }
    
    func isEmpty() -> Bool {
        return front == last
    }
    // 当 last 循环到数组的前面，要从后面追上 front，还差一格的时候，判定队列为满
    func isFull() -> Bool {
       return (last + 1) % capacity == front
    }
}

class MyCircularDeque_1 {
    
    class ListNode {
        var val: Int
        var next: ListNode?
        var prev: ListNode?
        init(_ val: Int) {
            self.val = val
            self.next = nil
        }
    }
    
    let capacity: Int
    var count = 0
    
    var head: ListNode
    var tail: ListNode
    
    init(_ k: Int) {
        capacity = k
        head = ListNode(0)
        tail = head
        
        var n = k - 1
        while n > 0 {
            let node = ListNode(0)
            tail.next = node
            node.prev = tail
            tail = node
            n -= 1
        }
        
        tail.next = head
        head.prev = tail
        tail = head
    }
    
    func insertFront(_ value: Int) -> Bool {
        if count == capacity { return false }
        if count != 0 {
            head = head.prev!
        }
        head.val = value
        count += 1
        return true
    }
    
    func insertLast(_ value: Int) -> Bool {
        if count == capacity { return false }
        if count != 0 {
            tail = tail.next!
        }
        tail.val = value
        count += 1
        return true
    }
    
    func deleteFront() -> Bool {
        if count == 0 { return false }
        if count != 1 {
            head = head.next!
        }
        count -= 1
        return true
    }
    
    func deleteLast() -> Bool {
        if count == 0 { return false }
        if count != 1 {
            tail = tail.prev!
        }
        count -= 1
        return true
    }
    
    func getFront() -> Int {
        count == 0 ? -1 : head.val
    }
    
    func getRear() -> Int {
        count == 0 ? -1 : tail.val
    }
    
    func isEmpty() -> Bool {
        count == 0
    }
    
    func isFull() -> Bool {
        count == capacity
    }
}

/**
 * Your MyCircularDeque object will be instantiated and called as such:
 * let obj = MyCircularDeque(k)
 * let ret_1: Bool = obj.insertFront(value)
 * let ret_2: Bool = obj.insertLast(value)
 * let ret_3: Bool = obj.deleteFront()
 * let ret_4: Bool = obj.deleteLast()
 * let ret_5: Int = obj.getFront()
 * let ret_6: Int = obj.getRear()
 * let ret_7: Bool = obj.isEmpty()
 * let ret_8: Bool = obj.isFull()
 */

