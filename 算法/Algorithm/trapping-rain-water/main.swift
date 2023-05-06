//
//  main.swift
//  trapping-rain-water
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 *** LeetCode: 42. 接雨水
 * https://leetcode.cn/problems/trapping-rain-water/
 
 给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。

  
 示例 1：
 输入：height = [0,1,0,2,1,0,1,3,2,1,2,1]
 输出：6
 解释：上面是由数组 [0,1,0,2,1,0,1,3,2,1,2,1] 表示的高度图，在这种情况下，可以接 6 个单位的雨水（蓝色部分表示雨水）。
 
 示例 2：
 输入：height = [4,2,0,3,2,5]
 输出：9
  
 提示：
 n == height.length
 1 <= n <= 2 * 104
 0 <= height[i] <= 105
 */
import Foundation

class Solution {
    // 边界的存水量为0, 不计算, 根据规律得知计算每个格子的存水量相加即为最终存水量
    // 单个格子的存水量: min(left_max, right_max) - 格子高度
    // 暴力解法:
    func trap_1(_ height: [Int]) -> Int {
        var sum = 0
        let legth = height.count
        for i in 1..<legth-1 {
            var l = 0
            for j in 0...i {
                l = max(l, height[j])
            }
            var r = 0
            for j in i..<legth {
                r = max(r, height[j])
            }
            let single = min(l, r) - height[i]
            sum += single
        }
        return sum
    }
    // 暴力解法优化: 动态规划
    func trap_2(_ height: [Int]) -> Int {
        let legth = height.count
        var max_l = [Int](repeating: 0, count: legth)
        var max_r = [Int](repeating: 0, count: legth)
        /// 左侧最大高度
        max_l[0] = height[0]
        for i in 1..<legth {
            max_l[i] = max(max_l[i - 1], height[i])
        }
        // 右侧最大高度
        max_r[legth-1] = height[legth-1]
        for i in (0..<legth-1).reversed() {
            max_r[i] = max(max_r[i + 1], height[i])
        }
        // 叠加: 左右两侧最大高度最小值
        var sum = 0
        for i in 0..<legth {
            sum += min(max_l[i], max_r[i]) - height[i]
        }
        return sum
    }
    // 双指针法: 可以从动态规划变化得来
    // https://pic.leetcode-cn.com/dca8d12e6eeb3030fda9ff5dd93fc006f0198ae3b536da3ad34306f1e2eabf33-image.png
    // https://pic.leetcode-cn.com/25947aa4298e665dd7fe65c7a0e0dd61e185a36059a7ed0b9e7a8d7321a5de2a-image.png
    // https://pic.leetcode-cn.com/5360bc242064e515f1f3b58daba2cbdc3e4da0ddee90ae9574ba227d6c7b29ea-image.png
    // https://pic.leetcode-cn.com/425ecab62ac1a7c6c6c3cf320b03a8736227839a3bd59532379402cefd5372c8-image.png
    // https://pic.leetcode-cn.com/fba2b3de3e50c0be28021d2ce7953ffbe3e5d17bed52c9818afde04db3b5deb1-image.png
    // https://pic.leetcode-cn.com/0e29e6e588a5b16fd317d02d0289eb31afa0ac103945118efb025eccc7d1eb0b-image.png
    // https://pic.leetcode-cn.com/140f13e7d149207e3ab9e92ed4f06c8309845acb5b792351850011192d2b97e1-image.png
    // https://pic.leetcode-cn.com/f2606dd3a2c879f7acc5ad9e16ef850d5cda52c256df3f18adb86877339f0907-image.png
    // https://pic.leetcode-cn.com/0d7f72510b92096d0f0a76d845ba7e251b3d3f569e1503c2a860d3ebd323c093-image.png
    // https://pic.leetcode-cn.com/4e598a097bc921f40db2e63c1f99b45102b5793da62101e54041e1970f9195f6-image.png
    // https://pic.leetcode-cn.com/d3445d95d273dd55e0457cda3d4e7954667cacca9ce8c735ac6ddfbaa5fe07c4-image.png
    func trap_3(_ height: [Int]) -> Int {
        var l = 0, r = height.count - 1
        var l_max = 0, r_max = 0
        var sum = 0
        while l < r {
            if height[l] < height[r] {
                if height[l] >= l_max {
                    l_max = height[l]
                } else {
                    // 存水
                    sum += l_max - height[l]
                }
                l += 1
            } else {
                if height[r] >= r_max {
                    r_max = height[r]
                } else {
                    // 存水
                    sum += r_max - height[r]
                }
                r += 1
            }
        }
        return sum
    }

}

let lists_1 = [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]
let lists_2 = [4,2,0,3,2,5]
print(Solution().trap_1(lists_2))
print(Solution().trap_2(lists_2))

/**
 *** LeetCode: 238. 除自身以外数组的乘积
 *https://leetcode.cn/problems/product-of-array-except-self/
 
 给你一个整数数组 nums，返回 数组 answer ，其中 answer[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积 。
 题目数据 保证 数组 nums之中任意元素的全部前缀元素和后缀的乘积都在  32 位 整数范围内。
 请不要使用除法，且在 O(n) 时间复杂度内完成此题。
 
 说明:
 2 <= nums.length <= 105
 -30 <= nums[i] <= 30
 保证 数组 nums之中任意元素的全部前缀元素和后缀的乘积都在  32 位 整数范围内

 */

class SecondSolution {
    // 分析:
    // 暴力解法: 直接拿上所有数字相乘, 然后除以每一个元素即可, 但是题目要求不能使用除法, 因此废弃
    // 优化1: 直接遍历计算每一个元素左右两侧的乘积, 再一次遍历进行两侧相乘得到最终数组
    func productExceptSelf_1(_ nums: [Int]) -> [Int] {
        let count = nums.count
        var l = [Int](repeating: 0, count: count)
        l[0] = 1
        for i in 1..<count {
            l[i] = l[i - 1] * nums[i - 1]
        }
        var r = [Int](repeating: 0, count: count)
        r[count-1] = 1
        for i in (0..<count-1).reversed() {
            r[i] = r[i + 1] * nums[i + 1]
        }
        var last = [Int](repeating: 0, count: count)
        for i in 0..<count {
            last[i] = r[i] * l[i]
        }
        return last
    }
    
    // 优化2: 左侧遍历一次后, 省略右侧遍历, 直接进行
    func productExceptSelf_2(_ nums: [Int]) -> [Int] {
        let count = nums.count
        var lists = [Int](repeating: 1, count: count)
        lists[0] = 1
        for i in 1..<count {
            lists[i] = lists[i - 1] * nums[i - 1]
        }
        // 存储右侧乘积
        var r = 1
        for i in (0..<count).reversed() {
            lists[i] = lists[i] * r
            r *= nums[i]
        }
        return lists
    }
}
