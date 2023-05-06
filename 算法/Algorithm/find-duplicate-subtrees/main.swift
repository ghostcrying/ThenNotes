//
//  main.swift
//  find-duplicate-subtrees
//
//  Created by Putao0474 on 2022/7/6.
//
/*:
 652. 寻找重复的子树

 给定一棵二叉树 root，返回所有重复的子树。
 对于同一类的重复子树，你只需要返回其中任意一棵的根结点即可。
 如果两棵树具有相同的结构和相同的结点值，则它们是重复的。

 示例 1：
 https://assets.leetcode.com/uploads/2020/08/16/e1.jpg
 输入：root = [1, 2, 3, 4, null, 2, 4, null, null, 4]
 输出：[[2, 4],[4]]
 
 示例 2：
 https://assets.leetcode.com/uploads/2020/08/16/e2.jpg
 输入：root = [2, 1, 1]
 输出：[[1]]
 
 示例 3：
 https://assets.leetcode.com/uploads/2020/08/16/e33.jpg
 输入：root = [2, 2, 2, 3, null, 3, null]
 输出：[[2,3 ], [3]]
  
 提示：
 树中的结点数在[1,10^4]范围内。
 -200 <= Node.val <= 200
 通过次数54,408提交次数93,228
 */

import Foundation

public class TreeNode {
    
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    
    public init() {
        self.val = 0
        self.left = nil
        self.right = nil
    }
    
    public init(_ val: Int) {
        self.val = val
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

    private var treeMaps = [Int: Int]()
    private var treeList = [TreeNode?]()
    
    func findDuplicateSubtrees(_ root: TreeNode?) -> [TreeNode?] {
        guard let root = root else {
            return []
        }
        subtrees(root)
        for n in treeList {
            print(n?.val)
        }
        return treeList
    }
    
    @discardableResult
    private func subtrees(_ root: TreeNode?) -> String {
        guard let root = root else {
            return "#"
        }
        // 设计hashKey
        let result = subtrees(root.left) + "," + subtrees(root.right) + "," + "\(root.val)"
        let hashKey = result.hashValue
        print(result)
        var times = treeMaps[hashKey] ?? 0
        times += 1
        if times == 2 {
            treeList.append(root)
        }
        treeMaps[hashKey] = times
        return result
    }
}

let node2_1 = TreeNode(2, TreeNode(4), nil)
let node2_2 = TreeNode(2, TreeNode(4), nil)
let node3_1 = TreeNode(3, node2_2, TreeNode(4))
let root = TreeNode(1, node2_1, node3_1)
print(Solution().findDuplicateSubtrees(root))

