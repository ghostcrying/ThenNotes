//
//  main.swift
//  largest-rectangle-in-histogram
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 ***LeetCode: 84. 柱状图中最大的矩形
 *https://leetcode.cn/problems/largest-rectangle-in-histogram/
 *
 给定 n 个非负整数，用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 1 。
 求在该柱状图中，能够勾勒出来的矩形的最大面积。

  
 示例 1:
 *https://assets.leetcode.com/uploads/2021/01/04/histogram.jpg
 输入：heights = [2,1,5,6,2,3]
 输出：10
 解释：最大的矩形为图中红色区域，面积为 10
 *
 示例 2：
 *https://assets.leetcode.com/uploads/2021/01/04/histogram-1.jpg
 输入： heights = [2,4]
 输出： 4
  
 提示：
 1 <= heights.length <=105
 0 <= heights[i] <= 104
 */

/*:
 ***关键思路：
 - 为什么要找左右两边高度 大于 当前遍历的高度 的下标？因为只有高度大于当前高度，面积才有可能更大，如果找<=的，面积只可能小于或者等于原先计算的最大面积。
 - 为什么单调增栈要存储下标，而不是高度？因为通过下标可以找高度，而且通过下标是唯一的，这样才能找到对应位置的对应高度。
 - 进入外层循环，向右延伸，是确定了高度大于当前高度的最右下标。
 - 进入内层循环，由于单调增栈的特性，栈pop出来的的一定是高度大于当前高度的最左下标。
 - area =（（外层循环的下标-1）-（内层循环走到的下标））* 内层循环pop出来的高度，然后取最大值。
 - 数组头尾加入0，当作哨兵，所以一定会找到比当前index的高度，还小的值，结束左右寻找的流程。
 */
import Foundation

class Solution {
    // 从左到右每一根柱子: 将其固定为矩形的高度h, 随后我们从这跟柱子开始向两侧延伸，直到遇到高度小于h的柱子，就确定了矩形的左右边界
    // 2,1,5,6,2,3
    func largestRectangleArea_1(_ heights: [Int]) -> Int {
        let n = heights.count
        var results = 0
        for i in 0..<n {
            let h = heights[i]
            var l = i, r = i
            // 确定左右边界
            while l >= 1 && heights[l - 1] >= h {
                l -= 1
            }
            while r + 1 < n && heights[r + 1] >= h {
                r += 1
            }
            results = max(results, (r - l + 1) * h)
        }
        return 0
    }
    // 优化
    // 2,1,5,6,2,3
    // 0 2 1 5 6 2 3 0
    func largestRectangleArea_2(_ heights: [Int]) -> Int {
        let newHeight = [0] + heights + [0]
        var result = 0
        var stack = [Int]()
        for (i, value) in newHeight.enumerated() {
            // print("forin: \(i)")
            while !stack.isEmpty, newHeight[stack.last!] > value {
                let last = stack.popLast()!
                let space = newHeight[last] * (i - stack.last! - 1)
                print(space)
                result = max(result, space)
            }
            stack.append(i)
            // print("stack")
            // print(stack)
        }
        return result
    }
    
}

print(Solution().largestRectangleArea_2([2,1,5,6,2,3]))
