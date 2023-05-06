//
//  main.swift
//  task-scheduler
//
//  Created by Putao0474 on 2022/7/1.
//
/**
 
 ***LeetCode: 621. 任务调度器
 * https://leetcode.cn/problems/task-scheduler/

 给你一个用字符数组 tasks 表示的 CPU 需要执行的任务列表。其中每个字母表示一种不同种类的任务。任务可以以任意顺序执行，并且每个任务都可以在 1 个单位时间内执行完。在任何一个单位时间，CPU 可以完成一个任务，或者处于待命状态。

 然而，两个 相同种类 的任务之间必须有长度为整数 n 的冷却时间，因此至少有连续 n 个单位时间内 CPU 在执行不同的任务，或者在待命状态。
 
 ***就是说AA两个相同任务之间必须有>=n的时间间隔, 间隔可以是待命也可以是其他任务
       - 初始以为必须=n才行, 看题解才发现都认为是>=n
 - A -> (单位时间) -> (单位时间) -> A -> (单位时间) -> (单位时间) -> A
 
 你需要计算完成所有任务所需要的 最短时间 。

 示例 1：
 输入：tasks = ["A","A","A","B","B","B"], n = 2
 输出：8
 解释：A -> B -> (待命) -> A -> B -> (待命) -> A -> B
      在本示例中，两个相同类型任务之间必须间隔长度为 n = 2 的冷却时间，而执行一个任务只需要一个单位时间，所以中间出现了（待命）状态。

 示例 2：
 输入：tasks = ["A","A","A","B","B","B"],  n = 0
 输出：6
 解释：在这种情况下，任何大小为 6 的排列都可以满足要求，因为 n = 0
 ["A","A","A","B","B","B"]
 ["A","B","A","B","A","B"]
 ["B","B","B","A","A","A"]
 ...
 诸如此类
 
 示例 3：
 输入：tasks = ["A","A","A","A","A","A","B","C","D","E","F","G"], n = 2
 输出：16
 解释：一种可能的解决方案是：
      A -> B -> C -> A -> D -> E -> A -> F -> G -> A -> (待命) -> (待命) -> A -> (待命) -> (待命) -> A
 提示：
 1 <= task.length <= 104
 tasks[i] 是大写英文字母
 n 的取值范围为 [0, 100]

 */

/**
 桶思想:
 - *计算每行任务数
 - *每行任务数必须>=n
 A出现次数就是桶的最大高度, 每一行都由剩余任务填充,
 最后一行任务其实是由A任务加上与A任务相同次数的B得到
 
 第一种形式: 每行任务数 <=n, ***不足的由待命时间填充(最后一行除外)
 A B C
 A B C
 A B D
 A B -
 A B
 第二种形式: 待命时间都被任务占据, 总时长就是任务数
 - 每行任务数 >=n
 A B C D
 A B C E
 A B D F
 A B D
 A B
 */

import Foundation

class Solution {
    
    // 利用桶思想进行解题
    func leastInterval(_ tasks: [Character], _ n: Int) -> Int {
        let m = tasks.count
        var arr: [Int] = [Int](repeating:0, count: 26)
        let a = Int(String("A").unicodeScalars.first!.value)
        for c in tasks {
            let index = Int(String(c).unicodeScalars.first!.value) - a
            arr[index] += 1
        }
        // 最大长度
        var t = 0
        for i in arr {
            if (i > t) {
                t = i
            }
        }
        // 最后一个长度
        // let lastCount = map.values.filter { $0 == t }.count
        var lastCount = 0
        for i in arr {
            if i == t {
                lastCount += 1
            }
        }
        // 横向任务数: n+1
        // 纵向为: t, t-1单独计算
        let result = (n + 1) * (t - 1) + lastCount
        // 如果按照桶计算得到的时长小于任务数, 说明还有任务需要填充, 则直接为总任务数时长即可(第二种形式)
        return max(result, m)
    }
}
print(Date())
let lists_0: [Character] = ["A","A","A","A","A","A","B","C","D","E","F","G"] // ABC ADE AFG A--A--A
let lists_1: [Character] = ["A","A","A","B","B","B"]
print(Solution().leastInterval(lists_0, 2))

// ["A","A","A","B","B","B","C","C","D","D"], n = 2
// A B C A B C A B C D - - D // 12

print(Date())

