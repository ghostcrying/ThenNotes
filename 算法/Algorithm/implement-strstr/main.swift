//
//  main.swift
//  implement-strstr
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 实现 strStr() 函数:
 给你两个字符串 haystack 和 needle ，请你在 haystack 字符串中找出 needle 字符串出现的第一个位置（下标从 0 开始）。如果不存在，则返回  -1 。

 说明：
 当 needle 是空字符串时，我们应当返回什么值呢？这是一个在面试中很好的问题。
 对于本题而言，当 needle 是空字符串时我们应当返回 0 。这与 C 语言的 strstr() 以及 Java 的 indexOf() 定义相符。

 示例 1：
 输入：haystack = "hello", needle = "ll"
 输出：2
 
 示例 2：
 输入：haystack = "aaaaa", needle = "bba"
 输出：-1
  

 提示：
 1 <= haystack.length, needle.length <= 104
 haystack 和 needle 仅由小写英文字符组成

 */

import Foundation

class Solution {
    
    func strStr(_ haystack: String, _ needle: String) -> Int {
        if needle.count > haystack.count { return -1 }
        
        let h = Array<Character>(haystack)
        let n = Array<Character>(needle)
        let count = n.count
        
        for i in 0...(h.count-n.count) {
            var a = i
            var b = 0
            while b < count && h[a] == n[b] {
                a += 1
                b += 1
            }
            if b == count {
                return i
            }
        }
        return -1
    }
}
print(Solution().strStr("a", "a"))

// print("Hello, World!")

