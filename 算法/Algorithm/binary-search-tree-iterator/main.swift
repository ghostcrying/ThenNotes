//
//  main.swift
//  binary-search-tree-iterator
//
//  Created by 大大 on 2022/7/6.
//
/*:
 ***LeetCode: 173. 二叉搜索树迭代器
 *https://leetcode.cn/problems/binary-search-tree-iterator/

 实现一个二叉搜索树迭代器类BSTIterator ，表示一个按中序遍历二叉搜索树（BST）的迭代器：
 BSTIterator(TreeNode root) 初始化 BSTIterator 类的一个对象。BST 的根节点 root 会作为构造函数的一部分给出。指针应初始化为一个不存在于 BST 中的数字，且该数字小于 BST 中的任何元素。
 boolean hasNext() 如果向指针右侧遍历存在数字，则返回 true ；否则返回 false 。
 int next()将指针向右移动，然后返回指针处的数字。
 注意，指针初始化为一个不存在于 BST 中的数字，所以对 next() 的首次调用将返回 BST 中的最小元素。

 你可以假设 next() 调用总是有效的，也就是说，当调用 next() 时，BST 的中序遍历中至少存在一个下一个数字。


 示例：
 https://assets.leetcode.com/uploads/2018/12/25/bst-tree.png
 输入
 ["BSTIterator", "next", "next", "hasNext", "next", "hasNext", "next", "hasNext", "next", "hasNext"]
 [[[7, 3, 15, null, null, 9, 20]], [], [], [], [], [], [], [], [], []]
 输出
 [null, 3, 7, true, 9, true, 15, true, 20, false]

 解释
 BSTIterator bSTIterator = new BSTIterator([7, 3, 15, null, null, 9, 20]);
 bSTIterator.next();    // 返回 3
 bSTIterator.next();    // 返回 7
 bSTIterator.hasNext(); // 返回 True
 bSTIterator.next();    // 返回 9
 bSTIterator.hasNext(); // 返回 True
 bSTIterator.next();    // 返回 15
 bSTIterator.hasNext(); // 返回 True
 bSTIterator.next();    // 返回 20
 bSTIterator.hasNext(); // 返回 False
  

 提示：

 树中节点的数目在范围 [1, 105] 内
 0 <= Node.val <= 106
 最多调用 105 次 hasNext 和 next 操作
 
 */

import Foundation

public class TreeNode {
    
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    
    public init(_ val: Int) {
        self.val = val
        self.left = nil
        self.right = nil
    }

    public init() {
        self.val = 0
        self.left = nil
        self.right = nil
    }
    
    public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
        self.val = val
        self.left = left
        self.right = right
    }
}

/// 方案:
/// 1. 直接中序遍历存储数组, 进行指针指向next进行判别
class BSTIterator {
    
    var index = 0
    var lists = [Int]()

    init(_ root: TreeNode?) {
        self.recursionMiddleorderTraversal(root)
    }
    /// 中序遍历得到所有数据
    private func recursionMiddleorderTraversal(_ node: TreeNode?) {
        if node == nil {
            return
        }
        recursionMiddleorderTraversal(node?.left)
        lists.append(node!.val)
        recursionMiddleorderTraversal(node?.right)
    }
    
    func next() -> Int {
        index += 1
        return lists[index - 1]
    }
    
    func hasNext() -> Bool {
        return index < lists.count
    }
}

/// 2. 通过栈形式存储, 随用随查找
class BSTIterator2 {
    
    private var stack: [TreeNode] = []

    init(_ root: TreeNode?) {
        guard let root = root else { return }
        // 初始先拿到left的Node压栈
        preload(root)
    }
    
    private func preload(_ node: TreeNode) {
        var current: TreeNode? = node
        while current != nil {
            stack.append(current!)
            current = current?.left
        }
    }

    func next() -> Int {
        let smallest = stack.popLast()!
        // 如果有右节点, 就对右节点进行压栈
        if let node = smallest.right {
            preload(node)
        }
        return smallest.val
    }
    
    func hasNext() -> Bool {
        return !stack.isEmpty
    }
}
/// 二叉搜索树第k小的元素
class Solution {
    // 需要优化, 不能直接就存储数组
    // 使用压栈形式
    func kthSmallest(_ root: TreeNode?, _ k: Int) -> Int {
        var node = root
        var stack = [TreeNode]()
        var n = k
        while node != nil || !stack.isEmpty {
            while node != nil {
                stack.append(node!)
                node = node?.left
            }
            node = stack.popLast()
            n -= 1
            if n == 0 {
                break
            }
            node = node?.right
        }
        return node?.val ?? -1
    }
}

/**
 * Your BSTIterator object will be instantiated and called as such:
 * let obj = BSTIterator(root)
 * let ret_1: Int = obj.next()
 * let ret_2: Bool = obj.hasNext()
 */
