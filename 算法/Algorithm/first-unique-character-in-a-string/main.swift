//
//  main.swift
//  first-unique-character-in-a-string
//
//  Created by 大大 on 2022/7/5.
//
/*:
 ***LeetCode: 387. 字符串中的第一个唯一字符
 *https://leetcode.cn/problems/first-unique-character-in-a-string/
 
 给定一个字符串 s ，找到 它的第一个不重复的字符，并返回它的索引 。如果不存在，则返回 -1 。

 示例 1：
 输入: s = "leetcode"
 输出: 0
 
 示例 2:
 输入: s = "loveleetcode"
 输出: 2
 
 示例 3:
 输入: s = "aabb"
 输出: -1
  
 提示:
 1 <= s.length <= 105
 s 只包含小写字母
 
 */
import Foundation

class Solution {
    
    func firstUniqChar(_ s: String) -> Int {
        var map = [String.Element: Int]()
        let lists = Array(s)
        for c in lists {
            map[c] = (map[c] ?? 0) + 1
        }
        for (i, c) in lists.enumerated() {
            if map[c] == 1 {
                return i
            }
        }
        return -1
    }
    
    func firstUniqChar_1(_ s: String) -> Int {
        var map = [String.Element: Int]()
        let lists = Array(s)
        for (i, c) in lists.enumerated() {
            if map[c] != nil {
                map[c] = -1
            } else {
                map[c] = i
            }
        }
        var first = s.count
        for i in map.values {
            if i != -1 && i < first {
                first = i
            }
        }
        return first == s.count ? -1 : first
    }
}

