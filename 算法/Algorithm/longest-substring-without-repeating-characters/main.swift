//
//  main.swift
//  longest-substring-without-repeating-characters
//
//  Created by Putao0474 on 2022/6/29.
//
/**
 *** LeetCode: 3. 无重复字符的最长子串
 * https://leetcode.cn/problems/longest-substring-without-repeating-characters/
 给定一个字符串 s ，请你找出其中不含有重复字符的 最长子串 的长度。

 示例 1:
 输入: s = "abcabcbb"
 输出: 3
 解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
 
 示例 2:
 输入: s = "bbbbb"
 输出: 1
 解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
 
 示例 3:
 输入: s = "pwwkew"
 输出: 3
 解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
      请注意，你的答案必须是 子串 的长度，"pwke" 是一个子序列，不是子串。
  
 提示：
 0 <= s.length <= 5 * 104
 s 由英文字母、数字、符号和空格组成
 
 */

import Foundation

class Solution {
    // 滑动窗口
    func lengthOfLongestSubstring_1(_ s: String) -> Int {
        if s.count < 2 { return s.count }
        
        let chs = Array<Character>(s)
        var map = [Character: Int]()
        var start = 0
        var maxLength = 1
        for i in 0..<chs.count {
            let c = chs[i]
            if let preIndex = map[c] {
                start = max(preIndex + 1, start)
            }
            maxLength = max(maxLength, i - start + 1)
            map[c] = i
        }
        return maxLength
    }
    // Hash优化: Asscii数组
    func lengthOfLongestSubstring_2(_ s: String) -> Int {
        if s.count < 2 { return s.count }
        
        let chs = Array<Character>(s)
        var map = Array(repeating: -1, count: 128)
        var start = 0
        var maxLength = 1
        for i in 0..<chs.count {
            let index = Int(chs[i].asciiValue ?? 0)
            start = max(map[index] + 1, start)
            maxLength = max(maxLength, i - start + 1)
            map[index] = i
        }
        return maxLength
    }

}

extension Solution {
    /// https://leetcode.cn/problems/longest-substring-with-at-least-k-repeating-characters/
    /// 一个最长的子字符串的长度，该子字符串中每个字符出现的次数都最少为k
    /// 滑动窗口过于复杂
    /// 优化: 通过递归进行分治
    /// 核心: 字符c在s中存在次数小于k, 那么所有包含c的子串都不满足条件, 此时即可进行切分
    func longestSubstring(_ s: String, _ k: Int) -> Int {
        // 总长度不满足, 直接返回
        guard s.count < k else { return 0 }
        // 字符串切分
        var map = [Character: Int]()
        for i in [Character](s) {
            map[i] = (map[i] ?? 0) + 1
        }
        for c in map.keys {
            guard map[c]! >= k else { continue }
            var length = 0
            for sc in s.components(separatedBy: String(c)) {
                length = max(length, longestSubstring(sc, k))
            }
            return length
        }
        return s.count
    }
    
    /// 偷窃房屋问题
    /// https://leetcode.cn/problems/house-robber/solution/da-jia-jie-she-by-leetcode-solution/
    /// 动态规划: 将问题一分为二, 然后进行解决
    func rob(_ nums: [Int]) -> Int {
        let n = nums.count
        if n == 1 {
            return nums[0]
        }
        var cashes = [Int](repeating: 0, count: n)
        cashes[0] = nums[0]
        cashes[1] = max(nums[0], nums[1])
        for i in 2..<n {
            cashes[i] = max(nums[i] + cashes[i-2], cashes[i-1])
        }
        return cashes[n-1]
    }
}

print("偷盗: \(Solution().rob([1, 2, 3, 1]))")
print("偷盗: \(Solution().rob([2, 7, 9, 3, 1]))")

