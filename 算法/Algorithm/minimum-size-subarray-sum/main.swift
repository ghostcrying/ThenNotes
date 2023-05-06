//
//  main.swift
//  minimum-size-subarray-sum
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 ***LeetCode: 209. 长度最小的子数组
 * https://leetcode.cn/problems/minimum-size-subarray-sum
 
 给定一个含有 n 个正整数的数组和一个正整数 target 。

 找出该数组中满足其和 ≥ target 的长度最小的 连续子数组 [numsl, numsl+1, ..., numsr-1, numsr] ，并返回其长度。如果不存在符合条件的子数组，返回 0 。

  
 示例 1：
 输入：target = 7, nums = [2,3,1,2,4,3]
 输出：2
 解释：子数组 [4,3] 是该条件下的长度最小的子数组。
 *
 示例 2：
 输入：target = 4, nums = [1,4,4]
 输出：1
 *
 示例 3：
 输入：target = 11, nums = [1,1,1,1,1,1,1,1]
 输出：0
  
 提示：
 1 <= target <= 109
 1 <= nums.length <= 105
 1 <= nums[i] <= 105

 进阶：
 如果你已经实现 O(n) 时间复杂度的解法, 请尝试设计一个 O(n log(n)) 时间复杂度的解法。
 */

/**
 ***暴力解法
 *  - 直接遍历
 ***双指针法:  移动窗口
 *  - 左右边界: 初始 l = r = 0, sum = 0, 进行循环移动外循环r移动, 内循环l移动
 */

import Foundation

class Solution {
    /// [1, 2, 9, 11, 10, 4, 5, 1] // 10
    // 暴力点
    func minSubArrayLen_1(_ target: Int, _ nums: [Int]) -> Int {
        let length = nums.count
        var result = length + 1
        for i in 0..<length {
            var sum = 0
            for j in i..<length {
                sum += nums[j]
                if sum >= target {
                    result = min(result, j - i + 1)
                    break
                }
            }
        }
        return (result == length + 1) ? 0 : result
    }
    // 双指针
    func minSubArrayLen_2(_ target: Int, _ nums: [Int]) -> Int {
        let length = nums.count
        var l = 0, r = 0
        var sum = 0, result = length + 1
        while r < length {
            sum += nums[r]
            while sum >= target {
                result = min(result, r - l + 1)
                sum -= nums[l]
                l += 1
            }
            r += 1
        }
        return (result == length + 1) ? 0 : result
    }
}

print(Solution().minSubArrayLen_1(7, [2, 3, 1, 2, 4, 3]))
print(Solution().minSubArrayLen_2(7, [2, 3, 1, 2, 4, 3]))

print(Solution().minSubArrayLen_1(7, [1, 2, 9, 11, 10, 4, 5, 1]))
print(Solution().minSubArrayLen_2(7, [1, 2, 9, 11, 10, 4, 5, 1]))

