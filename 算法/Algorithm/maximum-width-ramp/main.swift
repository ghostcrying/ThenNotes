//
//  main.swift
//  maximum-width-ramp
//
//  Created by Putao0474 on 2022/7/5.
//

/**
 ***LeetCode: 962. 最大宽度坡
 *https://leetcode.cn/problems/maximum-width-ramp/
 *
 给定一个整数数组 A，坡是元组 (i, j)，其中  i < j 且 A[i] <= A[j]。这样的坡的宽度为 j - i。
 找出 A 中的坡的最大宽度，如果不存在，返回 0 。

  
 示例 1：
 输入：[6, 0, 8, 2, 1, 5]
 输出：4
 解释：
 最大宽度的坡为 (i, j) = (1, 5): A[1] = 0 且 A[5] = 5.
 *
 示例 2：
 输入：[9, 8, 1, 0, 1, 9, 4, 0, 4, 1]
 输出：7
 解释：
 最大宽度的坡为 (i, j) = (2, 9): A[2] = 1 且 A[9] = 1.
  
 提示：
 2 <= A.length <= 50000
 0 <= A[i] <= 50000
 */

import Foundation

class Solution {
    
    func maxWidthRamp_1(_ nums: [Int]) -> Int {

        return 0
    }
    
    // 7 2 5 4
    // 0 1 2 3 ->下标排序后: 1 3 2 0
    func maxWidthRamp_2(_ nums: [Int]) -> Int {
        let n = nums.count
        // 对下标进行排序
        var b = Array(0..<n)
        b.sort { nums[$0] < nums[$1] }
        //
        var m = n // 初始取N相当于初始取负值丢弃, 后续存储最小的下标
        var result = 0 // 存储最大下标差值
        for i in b {
            result = max(result, i - m) // i - m就是差值
            m = min(m, i) // 1 1 1 0
        }
        return result
    }

}

