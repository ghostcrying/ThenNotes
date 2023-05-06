//
//  main.swift
//  find-largest-value-in-each-tree-row
//
//  Created by Putao0474 on 2022/7/6.
//
/*:
 ***LeetCode: 515. 在每个树行中找最大值
 *https://leetcode.cn/problems/find-largest-value-in-each-tree-row/
 
 给定一棵二叉树的根节点 root ，请找出该二叉树中每一层的最大值。

 示例1：
 https://assets.leetcode.com/uploads/2020/08/21/largest_e1.jpg
 输入: root = [1, 3, 2, 5, 3, null, 9]
 输出: [1, 3, 9]
 
 示例2：
 输入: root = [1,2,3]
 输出: [1,3]
  

 提示：
 二叉树的节点个数的范围是 [0,104]
 -231 <= Node.val <= 231 - 1
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

extension TreeNode: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        // 用于唯一标识
        hasher.combine(val)
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        return lhs.left == rhs.left && lhs.right == rhs.right && lhs.val == rhs.val
    }
    
}

class Solution {
    
    func largestValues(_ root: TreeNode?) -> [Int] {
        guard root != nil else { return [] }
        var results = [Int]()
        sublogic(root, &results, 0)
        return results
    }
    // result: 结果
    // h: 纵深
    private func sublogic(_ root: TreeNode?, _ result: inout [Int], _ h: Int) {
        if result.count == h {
            result.append(root?.val ?? 0)
        } else {
            result[h] = max(result[h], root?.val ?? 0)
        }
        if root?.left != nil {
            sublogic(root?.left, &result, h + 1)
        }
        if root?.right != nil {
            sublogic(root?.right, &result, h + 1)
        }
    }
}

print(Solution().largestValues(nil))

