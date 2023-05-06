//
//  main.swift
//  diagonal-traverse
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 ***LeetCode: 498. 对角线遍历
 *https://leetcode.cn/problems/diagonal-traverse*
 
 给你一个大小为 m x n 的矩阵 mat ，请以对角线遍历的顺序，用一个数组返回这个矩阵中的所有元素。
 
 示例 1：
 输入：mat = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
 * https://assets.leetcode.com/uploads/2021/04/10/diag1-grid.jpg
 输出：[1, 2, 4, 7, 5, 3, 6, 8, 9]
 
 示例 2：
 输入：mat = [[1, 2], [3, 4]]
 输出：[1, 2, 3, 4]
  
 提示：
 m == mat.length
 n == mat[i].length
 1 <= m, n <= 104
 */

import Foundation

class Solution {
    // 发现对角线有m + n - 1条, 奇数线左下, 偶数线右上
    // 对角线上 所有元素 x+y = 线条下标
    func findDiagonalOrder(_ mat: [[Int]]) -> [Int] {
        let m = mat.count
        let n = mat[0].count
        var results = [Int]()
        for i in 0..<(m + n - 1) {
            // 求余
            if i & 1 == 0 {
                // 偶数
                var x = min(m - 1, i)
                var y = i - x
                while x >= 0 && y < n {
                    results.append(mat[x][y])
                    x -= 1
                    y += 1
                }
            } else {
                // 奇数
                var y = min(n - 1, i)
                var x = i - y
                while x < m && y >= 0 {
                    results.append(mat[x][y])
                    x += 1
                    y -= 1
                }
            }
        }
        return results
    }
}

let mat_1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
let mat_2 = [[1, 2], [3, 4]]
print(Solution().findDiagonalOrder(mat_1))
print(Solution().findDiagonalOrder(mat_2))

