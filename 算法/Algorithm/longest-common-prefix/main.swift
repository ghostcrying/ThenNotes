//
//  main.swift
//  longest-common-prefix
//
//  Created by 大大 on 2022/6/28.
//

/**
 编写一个函数来查找字符串数组中的最长公共前缀。
 如果不存在公共前缀，返回空字符串 ""。

 示例 1：
 输入：strs = ["flower", "flow", "flight"]
 输出："fl"
 
 示例 2：
 输入：strs = ["dog", "racecar", "car"]
 输出：""
 解释：输入不存在公共前缀。
  
 提示：
 1 <= strs.length <= 200
 0 <= strs[i].length <= 200
 strs[i] 仅由小写英文字母组成
 */
import Foundation

class Solution {
    // 暴力法: 直接排序从第一个字符串开始进行遍历
    func longestCommonPrefix_1(_ strs: [String]) -> String {
        if strs.count < 2 {
            return strs.joined()
        }
        var strs = strs.sorted { $0.count < $1.count }
        var index = strs[0].count
        while index > 0 {
            for i in 0..<strs.count {
                strs[i] = String(strs[i].prefix(index))
            }
            if Set(strs).count == 1 {
                return strs[0]
            }
            index -= 1
        }
        return ""
    }
    
    // 分治法
    func longestCommonPrefix_2(_ strs: [String]) -> String {
        if strs.count < 2 {
            return strs.joined()
        }
        return findLongestCommonPrefix(strs, 0, strs.count - 1)
    }
    
    private func findLongestCommonPrefix(_ strs: [String], _ start: Int, _ ended: Int) -> String {
        if start >= ended {
            return strs[start]
        }
        let mid = (start + ended) / 2 + start
        let left = findLongestCommonPrefix(strs, 0, mid)
        let right = findLongestCommonPrefix(strs, mid + 1, ended)
        return commonPrefix(left, right)
    }

    private func commonPrefix(_ leftStr: String, _ rightStr: String) -> String {
        if leftStr.count <= 0 || rightStr.count <= 0 {
            return ""
        }
        let array_l = Array(leftStr)
        let array_r = Array(rightStr)
        let minCount = min(array_l.count, array_r.count)
        for i in 0..<minCount {
            if array_l[i] != array_r[i] {
                return leftStr.subStringTo(i)
            }
        }
        return leftStr.subStringTo(minCount)
    }
}

extension Solution {
    // 所有数据都是小写英文字母
    func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
        var wordSet = Set(wordList)
        var quene = [(String, Int)]()
        quene.append((beginWord, 1)) // 开始单词和层级加入队列
        var stack = Array(repeating: [String](), count: wordList.count + 2)
        stack[1] = [beginWord]
        while !quene.isEmpty {
            // 出队 进行bfs
            let (word, level) = quene.removeFirst()
            // 和endword相等返回层级
            if word == endWord {
                print(stack[1...level].map { $0.first ?? "" }.joined(separator: "->"))
                return level
            }
            let lastStacklength = stack[level + 1].count
            // 循环单词列表
            for i in 0..<word.count {
                // 循环26个小写字母
                for c in 97...122 {
                    // 得到新的单词
                    let w = word.replaceIndex(i, with: Character(UnicodeScalar(c)!))
                    if w == word { continue }
                    // 检查wordset包不包括新生成的单词 避重复入列
                    if wordSet.contains(w) {
                        // 新单词加入队列
                        quene.append((w, level + 1))
                        stack[level + 1].append(w)
                        // 避死循环
                        wordSet.remove(w)
                    }
                }
            }
            /// 如果长度不变
            if stack[level + 1].count == lastStacklength {
                stack[level].removeFirst()
            }
        }
        // 始终没有遇到终点
        return 0
    }
}


print("Hello, World!".prefix(1))
print("sss".replaceIndex(1, with: "+"))

extension String {
    func replaceIndex(_ index: Int, with value: Character) -> String {
        guard index < self.count else { return "" }
        var s = self
        let index = s.index(s.startIndex, offsetBy: index)
        s.replaceSubrange(index...index, with: String(value))
        return s
    }
}

extension String {

    // 截取规定下标之后的字符串
    func subStringFrom(_ index: Int) -> String {
        guard index < count else {
            return ""
        }
        let index = self.index(startIndex, offsetBy: index)
        return String(self[index...])
    }

    // 截取规定下标之前的字符串
    func subStringTo(_ index: Int) -> String {
        guard index < count else { return self }
        let index = self.index(startIndex, offsetBy: index)
        return String(self[..<index])
    }

}



print("subStringTo".subStringTo(12))
// print("sss++".subStringFrom(6))

// print(Solution().ladderLength("hit", "cog", ["hot","dot","dog","lot","log","cog","hig"]))
// print(Solution().longestCommonPrefix_2(["flower", "flow", "flight"]))
