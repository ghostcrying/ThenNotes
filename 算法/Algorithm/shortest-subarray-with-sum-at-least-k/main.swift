//
//  main.swift
//  shortest-subarray-with-sum-at-least-k
//
//  Created by Putao0474 on 2022/7/4.
//
/**
 ***LeetCode: 862. 和至少为 K 的最短子数组
 *https://leetcode.cn/problems/shortest-subarray-with-sum-at-least-k/

 给你一个整数数组 nums 和一个整数 k ，找出 nums 中和至少为 k 的 最短非空子数组 ，并返回该子数组的长度。如果不存在这样的 子数组 ，返回 -1 。
 子数组 是数组中 连续 的一部分。

 示例 1：
 输入：nums = [1], k = 1
 输出：1
 
 示例 2：
 输入：nums = [1,2], k = 4
 输出：-1
 
 示例 3：
 输入：nums = [2,-1,2], k = 3
 输出：3

 提示：
 1 <= nums.length <= 105
 -105 <= nums[i] <= 105
 1 <= k <= 109
 */

import Foundation

class Solution {
    // 暴力点
    func shortestSubarray_1(_ nums: [Int], _ k: Int) -> Int {
        let n = nums.count
        var result = n + 1
        for i in 0..<n {
            var sum = 0
            for j in i..<n {
                sum += nums[j]
                if sum >= k {
                    result = min(result, j - i + 1)
                    break
                }
            }
        }
        return (result == n + 1) ? -1 : result
    }
    
    //
    func shortestSubarray_2(_ nums: [Int], _ k: Int) -> Int {
        let n = nums.count
        // 前缀和
        var preSum = [Int](repeating: 0, count: n + 1)
        preSum[0] = 0
        for i in 0..<n {
            if nums[i] >= k {
                return 1
            }
            preSum[i + 1] = preSum[i] + nums[i]
        }
        var front = 0, rear = 0
        var result = n + 1 // 比n大即可
        // 保存数组元素的下标, 通过双指针模拟stack的操作
        var indexs = [Int](repeating: 0, count: n + 1)
        for i in 0..<n+1 {
            // 因为要维护一个递增队列，故如果最新的元素比队尾小，影响单调性，把队尾元素弹出
            while front < rear && preSum[i] < preSum[indexs[rear - 1]] {
                rear -= 1
            }
            indexs[rear] = i
            rear += 1
            while front < rear && preSum[i] - preSum[indexs[front]] >= k {
                // i - indexs[front] 表示最短的数组长度
                result = min(result, i-indexs[front]);
                front += 1
            }
        }
        
        return result > n ? -1 : result
    }

    
    class ListNode {
        var val: Int
        var next: ListNode?
        init(_ val: Int) {
            self.val = val
            self.next = nil
        }
    }
    // 1 -> 2 -> 3
    func reverseList(_ head: ListNode?) -> ListNode? {
        var p: ListNode? = nil
        var c = head
        while c != nil {
            let next = c?.next
            c?.next = p // 重新指向
            p = c // 存储当前
            c = next // 存储下一个
        }
        return p
    }
}

print(Solution().shortestSubarray_2([2, -1, 2], 3))
