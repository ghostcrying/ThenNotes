//
//  main.swift
//  longest-palindromic-substring
//
//  Created by 大大 on 2022/6/28.
//
/**
 给你一个字符串 s，找到 s 中最长的回文子串。

 示例 1：
 输入：s = "babad"
 输出："bab"
 解释："aba" 同样是符合题意的答案。
 
 示例 2：
 输入：s = "cbbd"
 输出："bb"
  
 提示：
 1 <= s.length <= 1000
 s 仅由数字和英文字母组成

 */

import Foundation

class Solution {
    
    // 中心扩散
    func longestPalindrome_1(_ s: String) -> String {
        if s.count < 2  {
            return s
        }
        
        let count = s.count
        let a = s.map({ String($0) })
        var maxStarts = 0, maxLength = 1
        // 记录左右节点
        var l = 0
        var r = 0
        // 单循环遍历
        for i in 0..<count {
            l = i-1
            r = i+1
            // 记录当前回文长度
            var len = 1
            // 右移
            while r < count && a[r] == a[i] {
                r += 1
                len += 1
            }
            // 左右双向移位
            while l >= 0 && r < count && a[r] == a[l] {
                // 此处l多走了一次, 所以需要最终l + 1, 得到真正的下标
                l -= 1
                r += 1
                len += 2
            }
                
            if len > maxLength {
                maxLength = len
                maxStarts = l
            }
        }
        return a[(maxStarts + 1)..<(maxStarts + maxLength + 1)].joined()
    }
    
    // 动态规划
    func longestPalindrome_2(_ s: String) -> String {
        guard s.count >= 2 else { return s }
        
        let count = s.count
        let a = s.map({ String($0)})
        var maxStarts = 0, maxLength = 1
        var methods = Array(repeating: Array(repeating: false, count: s.count), count: s.count)
                
        for r in 1..<count {
            for l in 0..<r {
                if a[l] == a[r] && (r - l <= 2 || methods[l + 1][r - 1]) {
                    methods[l][r] = true
                    if r - l + 1 > maxLength {
                        maxLength = r - l + 1
                        maxStarts = l
                    }
                }
            }
        }
        
        return a[maxStarts..<maxStarts+maxLength].joined()
    }
}

print(Solution().longestPalindrome_1("snckookcdd"))


/*:
 *** LeetCode: 997. 找到小镇的法官
 * https://leetcode.cn/problems/find-the-town-judge/
 
 小镇里有 n 个人，按从 1 到 n 的顺序编号。传言称，这些人中有一个暗地里是小镇法官。

 如果小镇法官真的存在，那么：

 小镇法官不会信任任何人。
 每个人（除了小镇法官）都信任这位小镇法官。
 只有一个人同时满足属性 1 和属性 2 。
 给你一个数组 trust ，其中 trust[i] = [ai, bi] 表示编号为 ai 的人信任编号为 bi 的人。

 如果小镇法官存在并且可以确定他的身份，请返回该法官的编号；否则，返回 -1 。


 示例 1：
 输入：n = 2, trust = [[1, 2]]
 输出：2
 
 示例 2：
 输入：n = 3, trust = [[1, 3],[2, 3]]
 输出：3
 
 示例 3：
 输入：n = 3, trust = [[1, 3], [2, 3], [3, 1]]
 输出：-1
  
 提示：

 1 <= n <= 1000
 0 <= trust.length <= 104
 trust[i].length == 2
 trust 中的所有trust[i] = [ai, bi] 互不相同
 ai != bi
 1 <= ai, bi <= n
 
 */

func findJudge(_ n: Int, _ trust: [[Int]]) -> Int {
    if trust.count == 0 {
        return n == 1 ? 1 : -1
    }
    var map = [Int: Int]()
    for i in trust {
        let a = i[0]
        let b = i[1]
        map[a] = (map[a] ?? 0) - 1
        map[b] = (map[b] ?? 0) + 1
    }

    for (i, v) in map {
        if v == n - 1 {
            return i
        }
    }
    return -1
}
let lists_3 = [[1, 3], [2, 3], [3, 1]]
let lists_4 = [[1, 3], [2, 3]]
print(findJudge(3, lists_3))
print(findJudge(3, lists_4))
print(findJudge(2, []))

func findJudge_1(_ n: Int, _ trust: [[Int]]) -> Int {
    if trust.count == 0 {
        return n == 1 ? 1 : -1
    }
    var lists = [Int](repeating: 0, count: n + 1)
    for t in trust {
        lists[t[0]] -= 1
        lists[t[1]] += 1
    }
    for i in 1...n {
        if lists[i] == n - 1 {
            return i
        }
    }
    return -1
}

print(findJudge_1(3, lists_3))
print(findJudge_1(3, lists_4))
print(findJudge_1(2, []))
