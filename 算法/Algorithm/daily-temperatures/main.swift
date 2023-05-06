//
//  main.swift
//  daily-temperatures
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 ***LeetCode: 739. 每日温度
 *https://leetcode.cn/problems/daily-temperatures/
 *
 给定一个整数数组 temperatures ，表示每天的温度，返回一个数组 answer ，其中 answer[i] 是指对于第 i 天，下一个更高温度出现在几天后。如果气温在这之后都不会升高，请在该位置用 0 来代替。

 示例 1:
 输入: temperatures = [73,74,75,71,69,72,76,73]
 输出: [1,1,4,2,1,1,0,0]
 *
 示例 2:
 输入: temperatures = [30,40,50,60]
 输出: [1,1,1,0]
 *
 示例 3:
 输入: temperatures = [30,60,90]
 输出: [1,1,0]
  
 提示：
 1 <= temperatures.length <= 105
 30 <= temperatures[i] <= 100

 */

import Foundation

class Solution {
    
    func dailyTemperatures_1(_ temperatures: [Int]) -> [Int] {
        let count = temperatures.count
        var a = [Int](repeating: 0, count: count)
        for i in 0..<(count-1) {
            for j in i..<count {
                if temperatures[j] > temperatures[i] {
                    a[i] = j - i
                    break
                }
             }
        }
        return a
    }
    
    func dailyTemperatures_2(_ temperatures: [Int]) -> [Int] {
        let count = temperatures.count
        var stack = [Int]() // 存储一个温度递减的下标队列
        var resul = [Int](repeating: 0, count: count)
        for i in 0..<count {
            // 当温度大于栈顶元素温度, 则差值就是当前栈顶元素对应温度: 需要几天上升的结果
            // 栈顶出栈, 继续遍历栈即可
            while !stack.isEmpty && temperatures[i] > temperatures[stack.last!] {
                let index = stack.popLast()!
                resul[index] = i - index
            }
            stack.append(i)
        }
        return resul
    }
    // 5 4 3 6
}

