//
//  main.swift
//  3sum
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 ***LeetCode: 15. 三数之和
 * https://leetcode.cn/problems/3sum/
 
 给你一个包含 n 个整数的数组 nums，判断 nums 中是否存在三个元素 a，b，c ，使得 a + b + c = 0 ？请你找出所有和为 0 且不重复的三元组。
 注意：答案中不可以包含重复的三元组。

 示例 1：
 输入：nums = [-1, 0, 1, 2, -1, -4]
 输出：[[-1, -1, 2], [-1, 0, 1]]
 *
 示例 2：
 输入：nums = []
 输出：[]
 *
 示例 3：
 输入：nums = [0]
 输出：[]
  
 提示：
 0 <= nums.length <= 3000
 -105 <= nums[i] <= 105
 */

import Foundation

class Solution {
    
    /// 超时
    func threeSum_1(_ nums: [Int]) -> [[Int]] {
        let n = nums.count
        if n < 3 { return [] }
        let lists = nums.sorted(by: <)
        var results = Set<[Int]>()
        for i in 0..<n-2 {
            if i > 0 && lists[i-1] == lists[i] { continue }
            if i + 1 > n - 2 { break }
            var tmp = [Int](repeating: 0, count: 3)
            tmp[0] = lists[i]
            for j in i+1..<n-1 {
                if j > i+1 && lists[j-1] == lists[j] { continue }
                if j + 1 > n - 1 { break }
                tmp[1] = lists[j]
                for k in j+1..<n {
                    tmp[2] = lists[k]
                    if tmp.reduce(0, +) == 0 {
                        results.insert(tmp.sorted(by: <))
                        break
                    }
                }
            }
        }
        return results.map { $0 }
    }
    
    // 优化: 针对第三轮循环使用指针进行优化
    func threeSum_2(_ nums: [Int]) -> [[Int]] {
        let n = nums.count
        if n < 3 { return [] }
        // 排序
        let lists = nums.sorted(by: <)
        var results = [[Int]]()
        for i in 0..<n-2 {
            // 上一元素与当前一致就跳过
            if i > 0 && lists[i-1] == lists[i] {
                continue
            }
            var k = n - 1
            let target = -lists[i]
            for j in i+1..<n-1 {
                // 上一元素与当前一致就跳过
                if j > i+1 && lists[j-1] == lists[j] {
                    continue
                }
                // 只有>Target才可以左移: 保证下一循环j+1<->k-1
                while j < k && (lists[k] + lists[j] > target) {
                    k -= 1
                }
                if j == k {
                    break
                }
                if lists[k] + lists[j] == target {
                    results.append([lists[i], lists[j], lists[k]])
                }
            }
        }
        return results
    }
    
    // 正整数数组: a = b + 2*c
    func testSum(_ nums: [Int]) -> [[Int]] {
        let n = nums.count
        if n < 3 { return [] }
        let lists = nums.sorted(by: >)
        var results = [[Int]]()
        for i in 0..<n-2 {
            // 相同直接跳过
            if i > 0 && lists[i - 1] == lists[i] { continue }
            var k = n - 1
            let target = lists[i]
            for j in i+1..<n-1 {
                if j > i+1 && lists[j - 1] == lists[j] { continue }
                while j < k && (2 * lists[k] + lists[j] < target) {
                    k -= 1
                }
                if j == k {
                    break
                }
                if 2 * lists[k] + lists[j] == target {
                    results.append([lists[i], lists[j], lists[k]])
                }
            }
        }
        return results
    }
}


// print(Solution().threeSum([-1, 0, 1, 2, -1, -4]))
// print(Solution().threeSum([0, 0, 0]))
// print(Solution().threeSum_2([2, 0, -2, -5, -5, -3, 2, -4])) // -5, -5, -4, -3, -2, 0, 2, 2

let lists_1 = [3, 1, 1, 2, 0, 3, 4]
print(Solution().testSum(lists_1))
