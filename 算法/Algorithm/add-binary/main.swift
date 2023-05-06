//
//  main.swift
//  add-binary
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 给你两个二进制字符串，返回它们的和（用二进制表示）。
 输入为 非空 字符串且只包含数字 1 和 0。
 
 示例 1:
 输入: a = "11", b = "1"
 输出: "100"
 
 示例 2:
 输入: a = "1010", b = "1011"
 输出: "10101"
  
 提示：
 每个字符串仅由字符 '0' 或 '1' 组成。
 1 <= a.length, b.length <= 10^4
 字符串如果不是 "0" ，就都不含前导零。
 
 */

import Foundation

class Solution {
    
    func addBinary_1(_ a: String, _ b: String) -> String {
        let arr_a = a.map { Int(String($0))! }
        let arr_b = b.map { Int(String($0))! }
        var max = a.count > b.count ? arr_a : arr_b
        let min = a.count > b.count ? arr_b : arr_a
        var last = 0
        for i in (0..<max.count).reversed() {
            let sum = max[i] + ((i < min.count) ? min[i] : 0)
            if sum < 2 {
                max[i] = sum
            } else {
                max[i] = sum - 2
                if i == 0 {
                    last = 1
                } else {
                    max[i-1] += 1
                }
            }
        }
        return (last == 0) ? "" : "1" + max.map { String($0) }.joined()
    }
    
    func addBinary_2(_ a: String, _ b: String) -> String {
        let arr_a = a.map { Int(String($0))! }
        let arr_b = b.map { Int(String($0))! }
        var max = a.count > b.count ? arr_a : arr_b
        let min = a.count > b.count ? arr_b : arr_a
        var result = ""
        for i in (0..<max.count).reversed() {
            let sum = max[i] + ((i < min.count) ? min[i] : 0)
            if sum < 2 {
                max[i] = sum
                result += "\(sum)"
            } else {
                max[i] = sum - 2
                result += "\(max[i])"
                if i == 0 {
                    result += "1"
                } else {
                    max[i-1] += 1
                }
            }
        }
        return result
    }
    
    // 逆序遍历, 存储临时值
    func addBinary_3(_ a: String, _ b: String) -> String {
        let arr_a = Array(a)
        let arr_b = Array(b)
        var i = a.count - 1
        var j = b.count - 1
        var result = ""
        var tmp = 0
        while i >= 0 || j >= 0{
            tmp += (i >= 0 ? (arr_a[i] == "0" ? 0 : 1) : 0)
            tmp += (j >= 0 ? (arr_b[j] == "0" ? 0 : 1) : 0)
            result.append("\(tmp % 2)")
            tmp = tmp >> 1
            i -= 1
            j -= 1
        }
        if tmp == 1 {
            result += "1"
        }
        return String(result.reversed())
    }
    
}

print(Solution().addBinary_3("1011", "1010"))

// print("Hello, World!")

