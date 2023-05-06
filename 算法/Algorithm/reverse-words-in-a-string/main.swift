//
//  main.swift
//  reverse-words-in-a-string
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 给你一个字符串 s ，颠倒字符串中 单词 的顺序。
 单词 是由非空格字符组成的字符串。s 中使用至少一个空格将字符串中的 单词 分隔开。
 返回 单词 顺序颠倒且 单词 之间用单个空格连接的结果字符串。
 注意：输入字符串 s中可能会存在前导空格、尾随空格或者单词间的多个空格。返回的结果字符串中，单词间应当仅用单个空格分隔，且不包含任何额外的空格。

  
 示例 1:
 输入：s = "the sky is blue"
 输出："blue is sky the"
 
 示例 2：
 输入：s = "  hello world  "
 输出："world hello"
 解释：颠倒后的字符串中不能存在前导空格和尾随空格。
 
 示例 3：
 输入：s = "a good   example"
 输出："example good a"
 解释：如果两个单词间有多余的空格，颠倒后的字符串需要将单词间的空格减少到仅有一个。
  

 提示：
 1 <= s.length <= 104
 s 包含英文大小写字母、数字和空格 ' '
 s 中 至少存在一个 单词

 */
import Foundation

class Solution {
    
    func reverseWords_1(_ s: String) -> String {
        return s.split { $0.isWhitespace }.reversed().joined(separator: " ")
    }
    
    func reverseWords_2(_ s: String) -> String {
        if s.count <= 1 { return s }
        var str = ""
        var tmp = ""
        // 单遍历, 每到空格重置
        for c in s {
            if c.isWhitespace {
                if !tmp.isEmpty {
                    if str.isEmpty {
                        str = tmp
                    } else {
                        str = tmp + " " + str
                    }
                    tmp = ""
                }
            } else {
                tmp.append(c)
            }
        }
        // print("tmp: \(tmp)")
        // 最终是否有未处理的临时字符串
        if !tmp.isEmpty {
            if str.isEmpty {
                str = tmp
            } else {
                str = tmp + " " + str
            }
        }
        return str
    }
}

print(Solution().reverseWords_2("  hello world"))

