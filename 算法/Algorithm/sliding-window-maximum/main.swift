//
//  main.swift
//  sliding-window-maximum
//
//  Created by 大大 on 2022/7/7.
//

/*:
 *https://leetcode-cn.com/problems/sliding-window-maximum
 
 给你一个整数数组 nums，有一个大小为 k 的滑动窗口从数组的最左侧移动到数组的最右侧。你只可以看到在滑动窗口内的 k 个数字。滑动窗口每次只向右移动一位。

 返回 滑动窗口中的最大值 。

  
 示例 1：
 输入：nums = [1, 3, -1, -3, 5, 3, 6, 7], k = 3
 输出：[3, 3, 5, 5, 6, 7]
 解释：
 滑动窗口的位置                最大值
 ---------------               -----
 [1  3  -1] -3  5  3  6  7       3
  1 [3  -1  -3] 5  3  6  7       3
  1  3 [-1  -3  5] 3  6  7       5
  1  3  -1 [-3  5  3] 6  7       5
  1  3  -1  -3 [5  3  6] 7       6
  1  3  -1  -3  5 [3  6  7]      7
 
 示例 2：
 输入：nums = [1], k = 1
 输出：[1]
  

 提示：
 1 <= nums.length <= 105
 -104 <= nums[i] <= 104
 1 <= k <= nums.length
 
 */

import Foundation

class Solution {
    
    func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
        let n = nums.count
        var ans = [Int](repeating: 0, count: n - k + 1)
        var stack = [Int]() // 维护一个递减队列
        var l = 0
        for r in 0..<n {
            let len = r - l + 1
            while !stack.isEmpty && nums[r] > stack.last! {
                _ = stack.popLast()
            }
            stack.append(nums[r])
            // 继续增大窗口
            if len < k {
                continue
            }
            // 窗口大小合适了, 最大元素入队列
            ans.append(stack[0])
            // 如果左侧元素为最大元素, 那么紧接着l右移, 最大值也右移
            if nums[l] == stack[0] {
                stack = Array(stack[1..<stack.count])
            }
            l += 1
        }
        return ans
    }
}


/*:
 *** LeetCode: 692. 前K个高频单词
 *https://leetcode.cn/problems/top-k-frequent-words/
 给定一个单词列表 words 和一个整数 k ，返回前 k 个出现次数最多的单词。

 返回的答案应该按单词出现频率由高到低排序。如果不同的单词有相同出现频率， 按字典顺序 排序。

 
 示例 1：
 输入: words = ["i", "love", "leetcode", "i", "love", "coding"], k = 2
 输出: ["i", "love"]
 解析: "i" 和 "love" 为出现次数最多的两个单词，均为2次。
     注意，按字母顺序 "i" 在 "love" 之前。
 
 示例 2：
 输入: ["the", "day", "is", "sunny", "the", "the", "the", "sunny", "is", "is"], k = 4
 输出: ["the", "is", "sunny", "day"]
 解析: "the", "is", "sunny" 和 "day" 是出现次数最多的四个单词，
     出现次数依次为 4, 3, 2 和 1 次。
  

 注意：
 1 <= words.length <= 500
 1 <= words[i] <= 10
 words[i] 由小写英文字母组成。
 k 的取值范围是 [1, 不同 words[i] 的数量]
  

 进阶：尝试以 O(n log k) 时间复杂度和 O(n) 空间复杂度解决。
 */

extension Solution {
    
    func topKFrequent(_ words: [String], _ k: Int) -> [String] {
        var map = [String: Int]()
        for word in words {
            map[word] = (map[word] ?? 0) + 1
        }
        let lists = map.sorted {
            // 先按照值排序
            if $0.value > $1.value {
                return true
            }
            // 再按照key大小排序
            if $0.value == $1.value {
                return $0.key < $1.key
            }
            return false
        }
        return lists[0..<k].map { $0.key }
    }
}

let words = ["the", "day", "is", "sunny", "the", "the", "the", "sunny", "is", "is"]
print(Solution().topKFrequent(words, 3))

func isPrime(_ a: Int) -> Bool {
    guard a > 3 else { return a > 1 }
    for i in 2...Int(sqrt(Double(a))) {
        if a % i == 0 {
            return false
        }
    }
    return true
}

func getPrime(_ a: Int) -> [Int] {
    var prime = [Int]()
    if a >= 2 {
        prime.append(2)
    }
    for i in stride(from: 3, to: a, by: 2) {
        if isPrime(i) {
            prime.append(i)
        }
    }
    return prime
}

extension Solution {
    /// https://leetcode.cn/problems/ugly-number-ii/
    /// 返回第n个丑数 1 <= n <= 1690
    /// 丑数 就是只包含质因数 2、3 和 5 的正整数
    /// 1也是丑数
    func nthUglyNumber(_ n: Int) -> Int {
        let factors = [2, 3, 5]
        var set = Set<Int>()
        set.insert(1)
        var heap = [1]
        var ugly = 1
        for _ in 1...n {
            let current = heap.removeFirst()
            ugly = current
            for f in factors {
                let next = current * f
                if set.insert(next).inserted == true {
                    heap.append(next)
                    heap.sort()
                }
            }
            print(heap)
        }
        return ugly
    }
    
    // 使用动态规划也行
    func nthUglyNumber_1(_ n: Int) -> Int {
        var stack = [Int](repeating: 0, count: n + 1)
        stack[1] = 1
        var f1 = 1, f2 = 1, f3 = 1
        for i in stride(from: 2, through: n, by: 1) {
            let s1 = stack[f1] * 2, s2 = stack[f2] * 3, s3 = stack[f3] * 5
            let value = min(min(s1, s2), s3)
            stack[i] = value
            if s1 == value {
                f1 += 1
            }
            if s2 == value {
                f2 += 1
            }
            if s3 == value {
                f3 += 1
            }
        }
        return stack[n]
    }
}

print(Solution().nthUglyNumber(10))
