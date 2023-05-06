//
//  main.swift
//  validate-binary-search-tree
//
//  Created by 大大 on 2022/7/6.
//
/*:
 ***LeetCode: 98. 验证二叉搜索树
 *https://leetcode.cn/problems/validate-binary-search-tree/
 
 给你一个二叉树的根节点 root，判断其是否是一个有效的二叉搜索树。

 有效 二叉搜索树定义如下：
 - 节点的左子树只包含 小于 当前节点的数。
 - 节点的右子树只包含 大于 当前节点的数。
 - 所有左子树和右子树自身必须也是二叉搜索树。
  

 示例 1：
 https://assets.leetcode.com/uploads/2020/12/01/tree1.jpg
 输入：root = [2,1,3]
 输出：true
 
 示例 2：
 https://assets.leetcode.com/uploads/2020/12/01/tree2.jpg
 输入：root = [5,1,4,null,null,3,6]
 输出：false
 解释：根节点的值是 5 ，但是右子节点的值是 4 。
  

 提示：
 树中节点数目范围在[1, 104] 内
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

class Solution {
    
    func isValidBST(_ root: TreeNode?) -> Bool {
        return isValidBSTHelper(root, Int.min, Int.max)
    }
    //! 递归
    func isValidBSTHelper(_ root : TreeNode?, _ low: Int, _ upper : Int) -> Bool {
        guard let root = root else {
            return true
        }
        if low != Int.min && root.val <= low {
            return false
        }
        if upper != Int.max && root.val >= upper {
            return false
        }
        return isValidBSTHelper(root.left ?? nil, low, root.val) && isValidBSTHelper(root.right ?? nil, root.val, upper)
    }
    
    //! 使用中序遍历: 中序遍历后所有数值都是递增的
    private var temp = Int.min // 临时值
    func isValidBST_1(_ root: TreeNode?) -> Bool {
        if root == nil {
            return true
        }
        let valid = isValidBST_1(root?.left)
        if !valid {
            return false
        }
        if root!.val <= temp {
            return false
        } else {
            temp = root!.val
        }
        return isValidBST_1(root?.right)
    }
    
    // 三种遍历算法: 可以以下面三个打印的位置作为判别
    func recursionPreorderTraversal(_ node: TreeNode?) {
        if node != nil {
            // print(node?.val) // 前序遍历在此处操作
            recursionPreorderTraversal(node)
            recursionPreorderTraversal(node)
            
        }
    }
    func recursionMiddleorderTraversal(_ node: TreeNode?) {
        if node != nil {
            recursionMiddleorderTraversal(node)
            // print(node?.val) // 中序遍历在此处操作
            recursionMiddleorderTraversal(node)
        }
    }
    func recursionPostorderTraversal(_ node: TreeNode?) {
        if node != nil {
            recursionPostorderTraversal(node)
            recursionPostorderTraversal(node)
            // print(node?.val) // 后序遍历在此处操作
        }
    }
    
    /// 返回前序遍历节点值
    func preorderTraversal(_ root: TreeNode?) -> [Int] {
        var lists = [Int]()
        func preorderTraversal(_ node: TreeNode?) {
            if node == nil {
                return
            }
            lists.append(node!.val)
            preorderTraversal(node?.left)
            preorderTraversal(node?.right)
        }
        preorderTraversal(root)
        return lists
    }
    
    /// 返回二叉树的每层数组
    func levelOrder(_ root: TreeNode?) -> [[Int]] {
        var results = [[Int]]()
        level(root, &results, 0)
        return results
    }
    private func level(_ node: TreeNode?, _ results: inout [[Int]], _ h: Int) {
        if node == nil {
            return
        }
        if results.count == h {
            results.append([node!.val])
        } else {
            results[h].append(node!.val)
        }
        level(node?.left, &results, h + 1)
        level(node?.right, &results, h + 1)
    }
    
    
    /// 前序遍历构造二叉搜索树
    /// 第一种方式: 二分法, index = 0肯定是首节点, 根据首位进行二分查找左右节点区间, 递归即可
    /// 第二种方法: 根据数值上下界递归构建左右子树
    private var index = 0
    private var preorder = [Int]()
    func bstFromPreorder(_ preorder: [Int]) -> TreeNode? {
        let length = preorder.count
        self.preorder = preorder
        return bstFromPreorderHelp(low: Int.min, upper: Int.max, length: length)
    }
    func bstFromPreorderHelp(low: Int, upper: Int, length: Int) -> TreeNode? {
        if index == length {
            return nil
        }
        let cur = preorder[index]
        if cur < low || cur > upper {
            return nil
        }
        index += 1
        let node = TreeNode(cur)
        node.left = bstFromPreorderHelp(low: low, upper: cur, length: length)
        node.right = bstFromPreorderHelp(low: cur, upper: upper, length: length)
        return node
    }
}

/**
 ** 二叉树的遍历: 前序(根左右)，中序(左根右)，后序(左右根)
 */

/// [5, 4, 6, null, null, 3, 7]
///          5
///    3           6
/// 1     4    3       7


