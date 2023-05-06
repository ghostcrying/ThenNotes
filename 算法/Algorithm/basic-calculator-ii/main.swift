//
//  main.swift
//  basic-calculator-ii
//
//  Created by 大大 on 2022/6/29.
//
/**
 ** LeetCode： 227. 基本计算器 II
 给你一个字符串表达式 s ，请你实现一个基本计算器来计算并返回它的值。

 整数除法仅保留整数部分。
 你可以假设给定的表达式总是有效的。所有中间结果将在 [-231, 231 - 1] 的范围内。
 注意：不允许使用任何将字符串作为数学表达式计算的内置函数，比如 eval() 。


 示例 1：
 输入：s = "3+2*2"
 输出：7
 
 示例 2：
 输入：s = " 3/2 "
 输出：1
 
 示例 3：
 输入：s = " 3+5 / 2 "
 输出：5
  

 提示：
 1 <= s.length <= 3 * 105
 s 由整数和算符 ('+', '-', '*', '/') 组成，中间由一些空格隔开
 s 表示一个 有效表达式
 表达式中的所有整数都是非负整数，且在范围 [0, 231 - 1] 内
 题目数据保证答案是一个 32-bit 整数

 */
import Foundation

class Solution {
    
    func calculate(_ s: String) -> Int {
        var stack = [Int]()
        // 临时变量
        var tmp = 0
        var operate = "+"
        // var
        for c in s + "+" {
            guard c != " " else { continue }
            if c.isNumber {
                // 连续数字进位
                tmp = Int(String(c))! + tmp * 10
            } else {
                switch operate {
                case "+":
                    stack.append(tmp)
                case "-":
                    stack.append(-tmp)
                case "*":
                    stack.append(stack.popLast()! * tmp)
                case "/":
                    stack.append(stack.popLast()! / tmp)
                default:
                    break
                }
                tmp = 0
                operate = String(c)
            }
        }
        return stack.reduce(0, +)
    }
}

print(Solution().calculate(""))


