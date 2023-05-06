//
//  main.swift
//  multiply-strings
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 给定两个以字符串形式表示的非负整数 num1 和 num2，返回 num1 和 num2 的乘积，它们的乘积也表示为字符串形式。
 注意：不能使用任何内置的 BigInteger 库或直接将输入转换为整数。

 示例 1:
 输入: num1 = "2", num2 = "3"
 输出: "6"
 
 示例 2:
 输入: num1 = "123", num2 = "456"
 输出: "56088"

 提示：
 1 <= num1.length, num2.length <= 200
 num1 和 num2 只能由数字组成。
 num1 和 num2 都不包含任何前导零，除了数字0本身。

 */
import Foundation

/**
 [0, 0, 0, 0, 0, 0]
 
 4 5 6
 1 2 3
 
 -: 3*6 = 18, index = 2 + 2 + 1 = i + j + 1 = 5
 -: 3*5 = 15, index = 2 + 1 + 1 = i + j + 1 = 4
 -: 3*4 = 12, index = 2 + 0 + 1 = i + j + 1 = 3
 ...
 */

class Solution {
    // 数组存储相加
    func multiply_1(_ num1: String, _ num2: String) -> String {
        if num1 == "0" || num2 == "0" {
            return "0"
        }
        let m = num1.count
        let n = num2.count
        let arr1 = num1.map { Int(String($0))! }
        let arr2 = num2.map { Int(String($0))! }
        var sum = Array(repeating: 0, count: m + n)
        for i in (0..<m).reversed() {
            for j in (0..<n).reversed() {
                sum[i + j + 1] += arr1[i] * arr2[j]
            }
        }
        var result = ""
        for i in (1..<sum.count).reversed() {
            sum[i - 1] += sum[i] / 10
            sum[i] %= 10
            result = "\(sum[i])" + result
            if i == 1 && sum[0] != 0 {
                result = "\(sum[0])" + result
            }
        }
        return result
    }
    
    // 优化: 第一遍遍历直接存储
    func multiply_2(_ num1: String, _ num2: String) -> String {
        if num1 == "0" || num2 == "0" {
            return "0"
        }
        let m = num1.count
        let n = num2.count
        let arr1 = num1.map { Int(String($0))! }
        let arr2 = num2.map { Int(String($0))! }
        var sum = Array(repeating: 0, count: m + n)
        for i in (0..<m).reversed() {
            for j in (0..<n).reversed() {
                sum[i + j + 1] += arr1[i] * arr2[j]
            }
        }
        var result = ""
        for i in (1..<sum.count).reversed() {
            sum[i - 1] += sum[i] / 10
            sum[i] %= 10
            result = "\(sum[i])" + result
            if i == 1 && sum[0] != 0 {
                result = "\(sum[0])" + result
            }
        }
        return result
    }
}

print(123*456)
print(Solution().multiply_2("123", "456"))
