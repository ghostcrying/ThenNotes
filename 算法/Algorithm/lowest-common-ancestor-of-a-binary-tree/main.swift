//
//  main.swift
//  lowest-common-ancestor-of-a-binary-tree
//
//  Created by Putao0474 on 2022/7/7.
//
/*:
 ***LeetCode: 236. 二叉树的最近公共祖先
 * https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-tree/
 给定一个二叉树, 找到该树中两个指定节点的最近公共祖先。
 百度百科中最近公共祖先的定义为：“对于有根树 T 的两个节点 p、q，最近公共祖先表示为一个节点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”

 解析:
 根据以上定义，若root 是 p,q 的 最近公共祖先 ，则只可能为以下情况之一：
 1. p 和 q 在root 的子树中，且分列 root 的 异侧（即分别在左、右子树中）；
 2. p = root，且 q 在 root 的左或右子树中；
 3. q = root，且 p 在 root 的左或右子树中；

 ***递归解析：
 ***考虑通过递归对二叉树进行先序遍历，当遇到节点 p 或 q 时返回。从底至顶回溯，当节点 p,q 在节点root 的异侧时，节点 root 即为最近公共祖先，则向上返回 root

 一.终止条件：
 1. 当越过叶节点，则直接返回null ；
 2. 当root 等于p, q ，则直接返回 root ；
 二.递推工作：
 1. 开启递归左子节点，返回值记为 left ；
 2. 开启递归右子节点，返回值记为 right ；
 三.返回值： 根据left 和 ight ，可展开为四种情况；
 1. 当 left 和 right 同时为空 ：说明 root 的左 / 右子树中都不包含 p,q ，返回 null ；
 2. 当 left 和 right 同时不为空 ：说明 p,q 分列在 root 的 异侧 （分别在 左 / 右子树），因此 root 为最近公共祖先，返回 root ；
 3. 当 left 为空 ，right 不为空 ：p,q 都不在 root 的左子树中，直接返回 right 。具体可分为两种情况：
    - p,q 其中一个在 root 的 右子树 中，此时 right 指向 p（假设为 p ）；
    - p,q 两节点都在root 的右子树中，此时的 right 指向 最近公共祖先节点 ；
 4. left 不为空，right 为空 ：与情况 3. 同理；

 
 示例 1：
 https://assets.leetcode.com/uploads/2018/12/14/binarytree.png
 输入：root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1
 输出：3
 解释：节点 5 和节点 1 的最近公共祖先是节点 3 。
 
 示例 2：
 https://assets.leetcode.com/uploads/2018/12/14/binarytree.png
 输入：root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 4
 输出：5
 解释：节点 5 和节点 4 的最近公共祖先是节点 5 。因为根据定义最近公共祖先节点可以为节点本身。
 
 示例 3：
 输入：root = [1,2], p = 1, q = 2
 输出：1
  
 提示：
 树中节点数目在范围 [2, 105] 内。
 -109 <= Node.val <= 109
 所有 Node.val 互不相同 。
 p != q
 p 和 q 均存在于给定的二叉树中。
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

extension TreeNode: Equatable {
    
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
    
    func lowestCommonAncestor(_ root: TreeNode?, _ p: TreeNode?, _ q: TreeNode?) -> TreeNode? {
        if root == nil || root == p || root == q {
            return root
        }
        let l = lowestCommonAncestor(root?.left, p, q)
        let r = lowestCommonAncestor(root?.right, p, q)
        // 左右节点都为nil, 当前节点不包含pq, 返回nil
        if l == nil && r == nil {
            return nil
        }
        // 左节点为nil, 返回右节点
        if l == nil {
            return r
        }
        // 右节点为nil, 返回左节点
        if r == nil {
            return l
        }
        // 左右节点都不为nil, 返回当前节点
        return root
    }
    
    
    func lowestCommonAncestor_1(_ root: TreeNode?, _ p: TreeNode?, _ q: TreeNode?) -> TreeNode? {
        if root == nil || root == q || root == p {
            return root
        }
        let l = lowestCommonAncestor_1(root?.left, p, q)
        let r = lowestCommonAncestor_1(root?.right, p, q)
        if l == nil && r == nil {
            return nil
        }
        if l == nil {
            return r
        }
        if r == nil {
            return l
        }
        return root
    }
}
