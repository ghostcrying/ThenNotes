//
//  main.swift
//  linked-list-cycle-ii
//
//  Created by 大大 on 2022/7/5.
//
/*:
 *LeetCode: 142. 环形链表 II
 *https://leetcode.cn/problems/linked-list-cycle-ii/
 
 给定一个链表的头节点  head ，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。

 如果链表中有某个节点，可以通过连续跟踪 next 指针再次到达，则链表中存在环。 为了表示给定链表中的环，评测系统内部使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。如果 pos 是 -1，则在该链表中没有环。注意：pos 不作为参数进行传递，仅仅是为了标识链表的实际情况。
 不允许修改 链表。

  
 示例 1：
 https://assets.leetcode.com/uploads/2018/12/07/circularlinkedlist.png
 输入：head = [3,2,0,-4], pos = 1
 输出：返回索引为 1 的链表节点
 解释：链表中有一个环，其尾部连接到第二个节点。
 
 示例 2：
 https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test2.png
 输入：head = [1,2], pos = 0
 输出：返回索引为 0 的链表节点
 解释：链表中有一个环，其尾部连接到第一个节点。
 
 示例 3：
 https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test3.png
 输入：head = [1], pos = -1
 输出：返回 null
 解释：链表中没有环。
  

 提示：
 链表中节点的数目范围在范围 [0, 104] 内
 -105 <= Node.val <= 105
 pos 的值为 -1 或者链表中的一个有效索引
  

 进阶：你是否可以使用 O(1) 空间解决此题？

 */

import Foundation

public class ListNode {
    
    public var val: Int
    public var next: ListNode?
    public init(_ val: Int) {
        self.val = val
        self.next = nil
    }

    public init() {
        self.val = 0
        self.next = nil
    }
    
    public init(_ val: Int, _ next: ListNode?) {
        self.val = val
        self.next = next
    }
}

extension ListNode: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        // 用于唯一标识
        hasher.combine(val)
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        return lhs.next == rhs.next && lhs.val == rhs.val
    }
    
}

class Solution {
    // 通过Hash进行实现
    func detectCycle_1(_ head: ListNode?) -> ListNode? {
        var map = Set<ListNode>()
        var node = head
        while node != nil {
            if !map.insert(node!).inserted {
                return node
            }
            node = node?.next
        }
        return nil
    }
    // 公式推导
    // 1 2 3 7 8 9 -> 7
    func detectCycle_2(_ head: ListNode?) -> ListNode? {
        var slow: ListNode? = head
        var fast: ListNode? = head
        while fast != nil && fast?.next != nil {
            slow = slow?.next
            fast = fast?.next?.next
            // 环内相遇的点
            if slow == fast {
                // 环内相遇
                var list1: ListNode? = slow
                var list2: ListNode? = head
                while list1 != list2 {
                    list1 = list1?.next
                    list2 = list2?.next
                }
                return list2
            }
        }
        return nil
    }
    
    /// 删除链表的倒数第n个节点,  并返回头结点
    /// 1 2 3 4 5  倒数第2个
    func removeNthFromEnd(_ head: ListNode?, _ n: Int) -> ListNode? {
        guard head?.next != nil else { return nil }
        var r = head
        var l: ListNode? = ListNode(-1, head) // 虚节点
        var index = 0
        let dumy = l // 存储虚节点
        while r != nil {
            // 当r移动到n的位置时, 进行左指针移动
            if index >= n {
                l = l?.next
            }
            index += 1
            r = r?.next
        }
        // l?.next就是需要删除的节点
        let deleteNode = l?.next
        l?.next = l?.next?.next
        // 将要删除的节点的next置为nil
        deleteNode?.next = nil
        return dumy?.next
    }
}

/// 1 2 3 4 5
/// 0 1 2 3 4

let n5 = ListNode(5)
let n4 = ListNode(4, n5)
let n3 = ListNode(3, n4)
let n2 = ListNode(2, n3)
let n1 = ListNode(1, n2)

let node_2 = Solution().removeNthFromEnd(n1, 2)
var node_2_1 = node_2
while node_2_1 != nil {
    print(node_2_1?.val ?? 0)
    node_2_1 = node_2_1?.next
}
