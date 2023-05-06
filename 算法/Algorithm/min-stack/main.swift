//
//  main.swift
//  min-stack
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 ***LeetCode: 155. 最小栈
 * https://leetcode.cn/problems/min-stack/
 *
 设计一个支持 push ，pop ，top 操作，并能在常数时间内检索到最小元素的栈。

 实现 MinStack 类:

 MinStack() 初始化堆栈对象。
 void push(int val) 将元素val推入堆栈。
 void pop() 删除堆栈顶部的元素。
 int top() 获取堆栈顶部的元素。
 int getMin() 获取堆栈中的最小元素。
  

 示例 1:
 输入：
 ["MinStack","push","push","push","getMin","pop","top","getMin"]
 [[],[-2],[0],[-3],[],[],[],[]]

 输出：
 [null,null,null,null,-3,null,0,-2]

 解释：
 MinStack minStack = new MinStack();
 minStack.push(-2);
 minStack.push(0);
 minStack.push(-3);
 minStack.getMin();   --> 返回 -3.
 minStack.pop();
 minStack.top();      --> 返回 0.
 minStack.getMin();   --> 返回 -2.
  

 提示：
 -231 <= val <= 231 - 1
 pop、top 和 getMin 操作总是在 非空栈 上调用
 push, pop, top, and getMin最多被调用 3 * 104 次
 */

import Foundation

class MinStack {

    private var list = [Int]()
    private var minNum: Int?
    
    init() {
        list.reserveCapacity(500)
    }
    
    func push(_ val: Int) {
        list.append(val)
    }
    
    func pop() {
        let last = list.popLast()
        if last == minNum {
            minNum = list.min()
        }
    }
    
    func top() -> Int {
        return list.last!
    }
    
    func getMin() -> Int {
        return minNum!
    }
}

class MinStack1 {

    class Node {
        let val: Int
        let min: Int
        var next: Node?
        
        init(val: Int, min: Int) {
            self.val = val
            self.min = min
        }
    }
    
    private var head: Node?
    
    init() {
    }
    
    func push(_ val: Int) {
        if let head = head {
            let n = Node(val: val, min: min(head.min, val))
            n.next = head
            self.head = n
        } else {
            self.head = Node(val: val, min: val)
        }
    }
    
    func pop() {
        head = head?.next
    }
    
    func top() -> Int {
        return head!.val
    }
    
    func getMin() -> Int {
        return head!.min
    }
}


/**
 * Your MinStack object will be instantiated and called as such:
 * let obj = MinStack()
 * obj.push(val)
 * obj.pop()
 * let ret_3: Int = obj.top()
 * let ret_4: Int = obj.getMin()
 */

