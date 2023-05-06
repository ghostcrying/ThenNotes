//
//  main.swift
//  max-sum-of-rectangle-no-larger-than-k
//
//  Created by Putao0474 on 2022/7/4.
//
/**
 ***LeetCode: 363. 矩形区域不超过 K 的最大数值和
 *https://leetcode.cn/problems/max-sum-of-rectangle-no-larger-than-k/
 
 给你一个 m x n 的矩阵 matrix 和一个整数 k ，找出并返回矩阵内部矩形区域的不超过 k 的最大数值和。

 题目数据保证总会存在一个数值和不超过 k 的矩形区域。

 示例 1：
 * https://assets.leetcode.com/uploads/2021/03/18/sum-grid.jpg
 输入: matrix = [[1, 0, 1], [0, -2, 3]], k = 2
 输出：2
 解释：蓝色边框圈出来的矩形区域 [[0, 1], [-2, 3]] 的数值和是 2，且 2 是不超过 k 的最大数字（k = 2）。
 
 示例 2：
 输入：matrix = [[2, 2, -1]],  k = 3
 输出：3
  

 提示：
 m == matrix.length
 n == matrix[i].length
 1 <= m, n <= 100
 -100 <= matrix[i][j] <= 100
 -105 <= k <= 105
  
 进阶：如果行数远大于列数，该如何设计解决方案？
 通过次数37,434提交次数76,982
 */

import Foundation

class Solution {
    
    func maxSumSubmatrix(_ matrix: [[Int]], _ k: Int) -> Int {
        let m = matrix.count, n = matrix[0].count
        var result = Int.min
        for i in 0..<m { // m上边界
            var sum = [Int](repeating: 0, count: n)
            for j in i..<m { // m下边界
                for l in 0..<n {
                    sum[l] += matrix[j][l] // 在行上下边界中每列数据
                }
                result = max(searchMax(sum, k), result)
            }
        }
        return result
    }
    
    private func searchMax(_ arr: [Int], _ k : Int) -> Int {
        var result = Int.min
        for l in arr.indices {
            var sum = 0
            for r in l..<arr.count {
                sum += arr[r]
                if (sum > result && sum <= k) {
                    result = sum
                }
            }
        }
        return result
    }

    
    func maxSubArray_1(_ nums: [Int]) -> Int {
        let count = nums.count
        var result = Int.min
        for i in 0..<count {
            var sum = 0
            for j in i..<count {
                sum += nums[j]
                result = max(result, sum)
            }
        }
        return result
    }
    
    func maxSubArray_2(_ nums: [Int]) -> Int {
        let count = nums.count
        var result = Int.min
        // sums[i]表示nums中以nums[i]结尾的最大子序和
        var sums = [Int](repeating: 0, count: count)
        sums[0] = nums[0]
        for i in 1..<count {
            sums[i] = max(sums[i-1] + nums[i], nums[i])
            result = max(result, sums[i])
        }
        return result
    }
}
