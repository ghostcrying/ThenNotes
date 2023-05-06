//
//  main.swift
//  next-greater-element-ii
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 ***LeetCode: 503. 下一个更大元素 II
 *https://leetcode.cn/problems/next-greater-element-ii/
 *
 给定一个循环数组 nums （ nums[nums.length - 1] 的下一个元素是 nums[0] ），返回 nums 中每个元素的 下一个更大元素 。

 数字 x 的 下一个更大的元素 是按数组遍历顺序，这个数字之后的第一个比它更大的数，这意味着你应该循环地搜索它的下一个更大的数。如果不存在，则输出 -1 。

 示例 1:
 输入: nums = [1, 2, 1]
 输出: [2, -1, 2]
 解释: 第一个 1 的下一个更大的数是 2；
 数字 2 找不到下一个更大的数；
 第二个 1 的下一个最大的数需要循环搜索，结果也是 2。
 *
 示例 2:
 输入: nums = [1, 2, 3, 4, 3]
 输出: [2, 3, 4, -1, 4]
  
 提示:
 1 <= nums.length <= 104
 -109 <= nums[i] <= 109
 */

import Foundation

class Solution {
    
    func nextGreaterElements(_ nums: [Int]) -> [Int] {
        let count = nums.count
        var stack = [Int]() // 单调栈递减序列: 存储下标
        var result = [Int](repeating: -1, count: count)
        // 将数组翻一倍查找
        for i in 0..<2*count {
            let c = i % count
            // stack栈顶元素小于当前, 则stack出栈, 更新result, 继续遍历
            while !stack.isEmpty, nums[c] > nums[stack.last!] {
                let last = stack.popLast()!
                result[last] = nums[c]
            }
            stack.append(c)
        }
        return result
    }
}

