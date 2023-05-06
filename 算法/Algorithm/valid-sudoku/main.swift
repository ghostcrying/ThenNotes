//
//  main.swift
//  valid-sudoku
//
//  Created by Putao0474 on 2022/7/6.
//
/*:
 ***LeetCode:36. 有效的数独
 *https://leetcode.cn/problems/valid-sudoku/
 
 请你判断一个 9 x 9 的数独是否有效。只需要 根据以下规则 ，验证已经填入的数字是否有效即可。

 数字 1-9 在每一行只能出现一次。
 数字 1-9 在每一列只能出现一次。
 数字 1-9 在每一个以粗实线分隔的 3x3 宫内只能出现一次。（请参考示例图）
  
 注意：
 一个有效的数独（部分已被填充）不一定是可解的。
 只需要根据以上规则，验证已经填入的数字是否有效即可。
 空白格用 '.' 表示。
  

 示例 1：
 https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2021/04/12/250px-sudoku-by-l2g-20050714svg.png
 输入：board =
 [["5","3",".",".","7",".",".",".","."]
 ,["6",".",".","1","9","5",".",".","."]
 ,[".","9","8",".",".",".",".","6","."]
 ,["8",".",".",".","6",".",".",".","3"]
 ,["4",".",".","8",".","3",".",".","1"]
 ,["7",".",".",".","2",".",".",".","6"]
 ,[".","6",".",".",".",".","2","8","."]
 ,[".",".",".","4","1","9",".",".","5"]
 ,[".",".",".",".","8",".",".","7","9"]]
 输出：true
 
 示例 2：
 输入：board =
 [["8","3",".",".","7",".",".",".","."]
 ,["6",".",".","1","9","5",".",".","."]
 ,[".","9","8",".",".",".",".","6","."]
 ,["8",".",".",".","6",".",".",".","3"]
 ,["4",".",".","8",".","3",".",".","1"]
 ,["7",".",".",".","2",".",".",".","6"]
 ,[".","6",".",".",".",".","2","8","."]
 ,[".",".",".","4","1","9",".",".","5"]
 ,[".",".",".",".","8",".",".","7","9"]]
 输出：false
 解释：除了第一行的第一个数字从 5 改为 8 以外，空格内其他数字均与 示例1 相同。 但由于位于左上角的 3x3 宫内有两个 8 存在, 因此这个数独是无效的。
  

 提示：

 board.length == 9
 board[i].length == 9
 board[i][j] 是一位数字（1-9）或者 '.'
 */

import Foundation

class Solution {
    
    func isValidSudoku(_ board: [[Character]]) -> Bool {
        let origin = [Int](repeating: 0, count: 10)
        
        for i in 0..<9 {
            var count = origin
            for j in board[i] {
                if let hex = j.hexDigitValue {
                    if count[hex] > 0 {
                        return false
                    }
                    count[hex] = 1
                }
            }
        }
        
        for i in 0..<9 {
            var count = origin
            for j in 0..<8 {
                if let hex = board[j][i].hexDigitValue {
                    if count[hex] > 0 {
                        return false
                    }
                    count[hex] = 1
                }
            }
        }
        
        for i in [0, 3, 6] {
            for j in [0, 3, 6] {
                var count = origin
                for k in 0..<9 {
                    if let hex = board[i + k/3][j + k%3].hexDigitValue {
                        if count[hex] > 0 {
                            return false
                        }
                        count[hex] = 1
                    }
                }
            }
        }
        
        return true
    }

    func isValidSudoku_1(_ board: [[Character]]) -> Bool {
        // 依次检查条件1，2，3即可
        let ccounts = Array(repeating:0, count:10)

        // 检查行
        for i in 0...8 {
            var counts = ccounts
            for e in board[i] {
                if let v = e.hexDigitValue {
                    if counts[v] > 0 { return false }
                    counts[v] = 1
                }
            }
        }

        // 检查列
        for j in 0...8 {
            var counts = ccounts
            for i in 0...8 {
                if let v = board[i][j].hexDigitValue {
                    if counts[v] > 0 { return false }
                    counts[v] = 1
                }
            }
        }

        // 检查块,每个块的起始坐标是[i,j],然后通过z来遍历块中元素
        for i in [0,3,6] {
            for j in [0,3,6] {
                var counts = ccounts
                for z in 0...8 {
                    if let v = board[i+z/3][j+z%3].hexDigitValue {
                        if counts[v] > 0 { return false }
                        counts[v] = 1
                    }
                }
            }
        }

        return true

    }
}

let lists: [[Character]] = [
    ["5","3",".",".","7",".",".",".","."],["6",".",".","1","9","5",".",".","."],[".","9","8",".",".",".",".","6","."],
    ["8",".",".",".","6",".",".",".","3"],["4",".",".","8",".","3",".",".","1"],["7",".",".",".","2",".",".",".","6"],
    [".","6",".",".",".",".","2","8","."],[".",".",".","4","1","9",".",".","5"],[".",".",".",".","8",".",".","7","9"]
]

let lists1: [[Character]] = [
    [".",".",".","9",".",".",".",".","."],[".",".",".",".",".",".",".",".","."],[".",".","3",".",".",".",".",".","1"],
    [".",".",".",".",".",".",".",".","."],["1",".",".",".",".",".","3",".","."],[".",".",".",".","2",".","6",".","."],
    [".","9",".",".",".",".",".","7","."],[".",".",".",".",".",".",".",".","."],["8",".",".","8",".",".",".",".","."]
]
print(Solution().isValidSudoku_1(lists1))
