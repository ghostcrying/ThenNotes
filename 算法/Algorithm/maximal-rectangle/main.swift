//
//  main.swift
//  maximal-rectangle
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 *
 *

 ***LeetCode: 85. 最大矩形
 *https://leetcode.cn/problems/maximal-rectangle/
 给定一个仅包含 0 和 1 、大小为 rows x cols 的二维二进制矩阵，找出只包含 1 的最大矩形，并返回其面积。

 示例 1：
 *https://assets.leetcode.com/uploads/2020/09/14/maximal.jpg
 输入：matrix = [["1","0","1","0","0"],["1","0","1","1","1"],["1","1","1","1","1"],["1","0","0","1","0"]]
 输出：6
 解释：最大矩形如上图所示。
 *
 示例 2：
 输入：matrix = []
 输出：0
 *
 示例 3：
 输入：matrix = [["0"]]
 输出：0
 *
 示例 4：
 输入：matrix = [["1"]]
 输出：1
 *
 示例 5：
 输入：matrix = [["0","0"]]
 输出：0
  

 提示：
 rows == matrix.length
 cols == matrix[0].length
 1 <= row, cols <= 200
 matrix[i][j] 为 '0' 或 '1'
 */

import Foundation

/// 题解参考: https://leetcode.cn/problems/maximal-rectangle/solution/gryffindor-85-zui-da-ju-xing-by-jeremi-w6lo/
///
class Solution {
    
    // 计算每一行的最大矩形体积
    // 由一维转化为二维
    func maximalRectangle(_ matrix: [[Character]]) -> Int {
        var heights = Array(repeating: 0, count: matrix[0].count)
        var maxArea = 0
        for row in 0 ..< matrix.count {
            for col in 0 ..< matrix[0].count {
                // 当前格子为0, 直接设定高度为0
                if matrix[row][col] == "0" {
                    heights[col] = 0
                } else {
                    // 高度叠加
                    heights[col] += 1
                }
            }
            maxArea = max(maxArea, largestRectangleArea(heights))
        }
        return maxArea
    }
    
    func largestRectangleArea(_ heights: [Int]) -> Int {
        var stack = [Int]()
        let heights = [0] + heights + [0]
        var maxArea = 0
        for index in heights.indices {
            while !stack.isEmpty && heights[stack.last!] > heights[index] {
                let curIndex = stack.popLast()!
                let height = heights[curIndex]
                let width = index - stack.last! - 1
                maxArea = max(maxArea, height * width)
            }
            stack.append(index)
        }
        return maxArea
    }
    
    
}

