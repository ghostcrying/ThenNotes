//
//  main.swift
//  merge-k-sorted-lists
//
//  Created by 大大 on 2022/7/5.
//
/*:
 ***LeetCode: 23. 合并K个升序链表
 *https://leetcode.cn/problems/merge-k-sorted-lists/
 
 给你一个链表数组，每个链表都已经按升序排列。

 请你将所有链表合并到一个升序链表中，返回合并后的链表。

  
 示例 1：
 输入：lists = [[1,4,5],[1,3,4],[2,6]]
 输出：[1,1,2,3,4,4,5,6]
 解释：链表数组如下：
 [
   1->4->5,
   1->3->4,
   2->6
 ]
 将它们合并到一个有序链表中得到。
 1->1->2->3->4->4->5->6
 
 示例 2：
 输入：lists = []
 输出：[]
 
 示例 3：
 输入：lists = [[]]
 输出：[]
  

 提示：
 k == lists.length
 0 <= k <= 10^4
 0 <= lists[i].length <= 500
 -10^4 <= lists[i][j] <= 10^4
 lists[i] 按 升序 排列
 lists[i].length 的总和不超过 10^4
 
 */

import Foundation

public class ListNode {
    
    public var val: Int
    public var next: ListNode?
    
    public init() {
        self.val = 0
        self.next = nil
    }
    
    public init(_ val: Int) {
        self.val = val
        self.next = nil
    }
    
    public init(_ val: Int, _ next: ListNode?) {
        self.val = val
        self.next = next
    }
}

extension ListNode: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(val)
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.next == rhs.next && lhs.val == rhs.val
    }
    
}

class Solution {
    // 暴力求解: leetcode上暴力解法竟然比分治法性能好
    // 所有元素合并一个数组, 直接创建一个新链表
    func mergeKLists_1(_ lists: [ListNode?]) -> ListNode? {
        var vals = [Int]()
        for var n in lists {
            while n != nil {
                vals.append(n?.val ?? 0)
                n = n?.next
            }
        }
        // 排序
        vals.sort(by: <)
        // 构建新链表
        let dummy = ListNode(0)
        var node: ListNode? = dummy
        for i in vals {
            node?.next = ListNode(i)
            node = node?.next
        }
        return dummy.next
    }
    
    // 分治法
    // 每两个链表合并, 最后在合并
    func mergeKLists_2(_ lists: [ListNode?]) -> ListNode? {
        if lists.count == 0 {
            return nil
        }
        if lists.count == 1 {
            return lists[0]
        }
        let mid = lists.count / 2
        let l = mergeKLists_2(Array(lists[0..<mid]))
        let r = mergeKLists_2(Array(lists[mid..<lists.count]))
        return mergetTwoLists(l, r)
    }
    
    private func mergetTwoLists( _ l: ListNode?, _ r: ListNode?) -> ListNode? {
        let dummy = ListNode(0)
        var node: ListNode? = dummy
        var l1 = l, r1 = r
        while l1 != nil && r1 != nil {
            if l1!.val < r1!.val {
                node?.next = l1
                l1 = l1?.next
            } else {
                node?.next = r1
                r1 = r1?.next
            }
            node = node?.next
        }
        if l1 != nil {
            node?.next = l1
        } else {
            node?.next = r1
        }
        return dummy.next
    }
}

