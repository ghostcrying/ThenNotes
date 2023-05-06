//
//  main.swift
//  zigzag-conversion
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 **LeetCode: 6.Z字形变换
 将一个给定字符串 s 根据给定的行数 numRows ，以从上往下、从左到右进行 Z 字形排列。

 比如输入字符串为 "PAYPALISHIRING" 行数为 3 时，排列如下：
 P   A   H   N
 A P L S I I G
 Y   I   R
 
 0   4   8     12
 1 3 5 7 9  11 13
 2   6   10
 // 2*numRows - 2 = 4
 // lists[numRows-2] = n%(2*numRows - 2)
 // 1: n%(2*numRows - 2) = 1
 // 3: n%(2*numRows - 2) = 3 -> (2*numRows - 2) - index(3)
 0              2n-2          4n-4
 .          .   .          .
 .    (n-2)     .       .
 .   .          .    .
 n-1            3n-3
 之后，你的输出需要从左往右逐行读取，产生出一个新的字符串，比如："PAHNAPLSIIGYIR"。
 请你实现这个将字符串进行指定行数变换的函数：
 string convert(string s, int numRows);
  

 示例 1：
 输入：s = "PAYPALISHIRING", numRows = 3
 输出："PAHNAPLSIIGYIR"
 
 示例 2：
 输入：s = "PAYPALISHIRING", numRows = 4
 输出："PINALSIGYAHRPI"
 解释：
 P     I    N
 A   L S  I G
 Y A   H R
 P     I
 
 0     6
 1   5 7
 2 4   8
 3     9

 示例 3：
 输入：s = "A", numRows = 1
 输出："A"
  

 提示：
 1 <= s.length <= 1000
 s 由英文字母（小写和大写）、',' 和 '.' 组成
 1 <= numRows <= 1000

 */
import Foundation

class Solution {
    //
    func convert_1(_ s: String, _ numRows: Int) -> String {
        if numRows < 2 || s.count <= numRows { return s }
        
        var lists = Array(repeating: "", count: numRows)
        // 是否箭头反转
        var isDown = false
        var curRow = 0
        for c in s {
            lists[curRow].append(c)
            // 当前行curRow为0或numRows -1时，箭头发生反向转折
            if curRow == 0 || curRow == numRows - 1 {
                isDown = !isDown
            }
            curRow += (isDown ? 1 : -1)
        }
        return lists.joined()
    }

    func convert_2(_ s: String, _ numRows: Int) -> String {
        if numRows < 2 || s.count <= numRows { return s }
        
        var lists = Array(repeating: "", count: numRows)
        for (i, c) in s.enumerated() {
            let index = i % (2 * numRows - 2)
            if index < numRows {
                lists[index].append(c)
            } else {
                lists[numRows*2-2-index].append(c)
            }
        }
        return lists.joined()
    }
}

print(Solution().convert_2("PAYPALISHIRING", 3))

// print("Hello, World!")

