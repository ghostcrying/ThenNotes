//
//  main.swift
//  pascals-triangle
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 ***LeetCode: 118.杨辉三角
 
 给定一个非负整数 numRows，生成「杨辉三角」的前 numRows 行。

 在「杨辉三角」中，每个数是它左上方和右上方的数的和。

 示例 1:
 输入: numRows = 5
 输出: [[1],[1,1],[1,2,1],[1,3,3,1],[1,4,6,4,1]]
 
 示例 2:
 输入: numRows = 1
 输出: [[1]]
  

 提示:
 1 <= numRows <= 30

 */

import Foundation

class Solution {
    
    func generate(_ numRows: Int) -> [[Int]] {
        var results = Array(repeating: [Int](), count: numRows)
        for i in 0..<numRows {
            results[i] = Array(repeating: 1, count: i + 1)
            if i < 2 { continue }
            for j in 1..<i {
                results[i][j] = results[i-1][j-1] + results[i-1][j]
            }
        }
        
        return results
    }
    
    func generate_1(_ numRows: Int) -> [[Int]] {
        if numRows == 1 {
            return [[1]]
        }
        if numRows == 2 {
            return [[1], [1, 1]]
        }
        var results = Array(repeating: [Int](), count: numRows)
        results[0] = [1]
        results[1] = [1, 1]
        for i in 2..<numRows {
            results[i] = Array(repeating: 1, count: i + 1)
            for j in 1..<i {
                results[i][j] = results[i-1][j-1] + results[i-1][j]
            }
        }
        
        return results
    }
}

print(Solution().generate_1(5))



