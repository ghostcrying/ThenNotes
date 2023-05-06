//
//  main.swift
//  group-anagrams
//
//  Created by Putao0474 on 2022/7/6.
//
/*
 ***LeetCode: 49. 字母异位词分组
 * https://leetcode.cn/problems/group-anagrams/
 
 给你一个字符串数组，请你将 字母异位词 组合在一起。可以按任意顺序返回结果列表。
 字母异位词 是由重新排列源单词的字母得到的一个新单词，所有源单词中的字母通常恰好只用一次。

 示例 1:
 输入: strs = ["eat", "tea", "tan", "ate", "nat", "bat"]
 输出: [["bat"], ["nat","tan"], ["ate","eat","tea"]]
 
 示例 2:
 输入: strs = [""]
 输出: [[""]]
 
 示例 3:
 输入: strs = ["a"]
 输出: [["a"]]
  
 提示：
 1 <= strs.length <= 104
 0 <= strs[i].length <= 100
 strs[i] 仅包含小写字母
 */

import Foundation

class Solution {
    
    func groupAnagrams_1(_ strs: [String]) -> [[String]] {
        // 记录一共有多少种类
        var lists: [[String.Element: Int]] = []
        // 记录所有字符串map与下标
        var map = [Int: [String.Element: Int]]()
        for (i, v) in strs.enumerated() {
            var dict = [String.Element: Int]()
            for i in v {
                dict[i] = (dict[i] ?? 0) + 1
            }
            if !lists.contains(dict) {
                lists.append(dict)
            }
            map[i] = dict
        }
        var results = [[String]]()
        for v in lists {
            var indexs = [String]()
            for (key, value) in map {
                if value == v {
                    indexs.append(strs[key])
                }
            }
            results.append(indexs)
        }
        
        return results
    }
    
    // 直接遍历数组, 对字符串进行排序hash, 作为hash的key, 判定并存入key对应的value数组
    func groupAnagrams_2(_ strs: [String]) -> [[String]] {
        var map = [String: [String]]()
        for str in strs {
            let key = String(str.sorted())
            if map[key] == nil {
                map[key] = [str]
            } else {
                map[key]?.append(str)
            }
        }
        return Array(map.values)
    }
}

