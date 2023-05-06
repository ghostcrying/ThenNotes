//
//  main.swift
//  container-with-most-water
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 *** LeetCode: 11. 盛最多水的容器
 * https://leetcode.cn/problems/container-with-most-water/
 
 给定一个长度为 n 的整数数组 height 。有 n 条垂线，第 i 条线的两个端点是 (i, 0) 和 (i, height[i]) 。
 找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。
 返回容器可以储存的最大水量。
 说明：你不能倾斜容器。

 示例 1：
 输入：[1,8,6,2,5,4,8,3,7]
 输出：49
 解释：图中垂直线代表输入数组 [1,8,6,2,5,4,8,3,7]。在此情况下，容器能够容纳水（表示为蓝色部分）的最大值为 49。
 *
 示例 2：
 输入：height = [1,1]
 输出：1
  

 提示：
 n == height.length
 2 <= n <= 105
 0 <= height[i] <= 104

 */

import Foundation

class Solution {
    // 双指针法
    func maxArea(_ height: [Int]) -> Int {
        var l = 0
        var r = height.count - 1
        var result = 0
        while l < r {
            let lv = height[l]
            let rv = height[r]
            if lv <= rv {
                result = max(result, lv * (r - l))
                l += 1
            } else {
                result = max(result, rv * (r - l))
                r -= 1
            }
        }
        return result
    }
}

let list_1 = [1, 8, 6, 2, 5, 4, 8, 3, 7]
let list_2 = [1, 1]
print(Solution().maxArea(list_1))
print(Solution().maxArea(list_2))

