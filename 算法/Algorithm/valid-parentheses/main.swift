//
//  main.swift
//  valid-parentheses
//
//  Created by Putao0474 on 2022/7/5.
//
/**
 ***LeetCode: 20. 有效的括号
 *https://leetcode.cn/problems/valid-parentheses/
 
 给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串 s ，判断字符串是否有效。
 有效字符串需满足：
 左括号必须用相同类型的右括号闭合。
 左括号必须以正确的顺序闭合。
  
 示例 1：
 输入：s = "()"
 输出：true
 *
 示例 2：
 输入：s = "()[]{}"
 输出：true
 *
 示例 3：
 输入：s = "(]"
 输出：false
 *
 示例 4：
 输入：s = "([)]"
 输出：false
 *
 示例 5：
 输入：s = "{[]}"
 输出：true
  
 提示：
 1 <= s.length <= 104
 s 仅由括号 '()[]{}' 组成
 */

import Foundation

class Solution {
    func isValid(_ s: String) -> Bool {
        // 取余
        guard s.count & 1 == 0 else {
            return false
        }
        // 以右括号为key, 左括号为value
        // 括号之间必定为成对出现, {[()]}
        // 通过栈的形式对左括号进行存储, 逐个判别
        let map: [Character: Character] = [")": "(", "]": "[", "}": "{"]
        var stack = [Character]()
        for c in s {
            let isRight = map.keys.contains(c)
            if isRight {
                if stack.isEmpty || stack.last != map[c] {
                    return false
                }
                stack.removeLast()
            } else {
                stack.append(c)
            }
        }
        return true
    }
}

