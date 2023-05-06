//
//  main.swift
//  remove-k-digits
//
//  Created by Putao0474 on 2022/7/22.
//
/*:
 *** LeetCode: 402. 移掉 K 位数字
 *** https://leetcode.cn/problems/remove-k-digits/
 
 给你一个以字符串表示的非负整数 num 和一个整数 k ，移除这个数中的 k 位数字，使得剩下的数字最小。请你以字符串形式返回这个最小的数字。

 示例 1 ：
 输入：num = "1432219", k = 3
 输出："1219"
 解释：移除掉三个数字 4, 3, 和 2 形成一个新的最小的数字 1219 。
 
 示例 2 ：
 输入：num = "10200", k = 1
 输出："200"
 解释：移掉首位的 1 剩下的数字为 200. 注意输出不能有任何前导零。
 
 示例 3 ：
 输入：num = "10", k = 2
 输出："0"
 解释：从原数字移除所有的数字，剩余为空就是 0 。
  

 提示：
 1 <= k <= num.length <= 105
 num 仅由若干位数字（0 - 9）组成
 除了 0 本身之外，num 不含任何前导零
 */

import Foundation

/*: 方案:
 贪心 + 单调栈
 
 思路
 - 从左至右扫描，当前扫描的数还不确定要不要删，入栈暂存。
 - 123531这样「高位递增」的数，肯定不会想删高位，会尽量删低位。
 - 432135这样「高位递减」的数，会想干掉高位，直接让高位变小，效果好。
 - 所以，如果当前遍历的数比栈顶大，符合递增，是满意的，让它入栈。
 - 如果当前遍历的数比栈顶小，栈顶立刻出栈，不管后面有没有更大的，为什么？
   - 因为栈顶的数属于高位，删掉它，小的顶上，高位变小，效果好于低位变小。

 "1432219"  k = 3
 bottom[1       ]top           1入
 bottom[1 4     ]top           4入
 bottom[1 3     ]top    4出    3入
 bottom[1 2     ]top    3出    2入
 bottom[1 2 2   ]top           2入
 bottom[1 2 1   ]top    2出    1入    出栈满3个，停止出栈
 bottom[1 2 1 9 ]top           9入
 
 照这么设计，如果是"0432219"，0 遇不到比它更小的，最后肯定被留在栈中，变成 0219，还得再去掉前导0。
 "0432219"  k = 3
 bottom[0       ]top          0入
 bottom[0 4     ]top          4入
 bottom[0 3     ]top    4出    3入
 bottom[0 2     ]top    3出    2入
 bottom[0 2 2   ]top           2入
 bottom[0 2 1   ]top    2出    1入    出栈满3个，停止出栈
 bottom[0 2 1 9 ]top           9入

 */
class Solution {
    
    func removeKdigits(_ num: String, _ k: Int) -> String {
        // 维护单调递增栈
        var stack = [Character]()
        // 移除数据量
        var k1 = k
        for c in [Character](num) {
            while !stack.isEmpty && stack.last! > c && k1 > 0 {
                _ = stack.popLast()
                k1 -= 1
            }
            // 不让前导 0 入栈
            // 加一个判断：栈为空且当前字符为 "0" 时，不入栈。取反，就是入栈的条件
            if c != "0" || !stack.isEmpty {
                stack.append(c)
            }
        }
        // 遍历结束时，有可能还没删够 k 个字符，继续循环出栈，删低位
        while k1 > 0 {
            _ = stack.popLast()
            k1 -= 1
        }
        // 如果栈变空了，什么也不剩，则返回 "0"
        // 否则，将栈中剩下的字符，转成字符串返回。
        return stack.isEmpty ? "0" : stack.map({ String($0) }).joined()
    }
}

/*:
 *** LeetCode: 55. 跳跃游戏
 *** https://leetcode.cn/problems/jump-game/
 
 给定一个非负整数数组 nums ，你最初位于数组的 第一个下标 。
 数组中的每个元素代表你在该位置可以跳跃的最大长度。
 判断你是否能够到达最后一个下标。

 示例 1：
 输入：nums = [2,3,1,1,4]
 输出：true
 解释：可以先跳 1 步，从下标 0 到达下标 1, 然后再从下标 1 跳 3 步到达最后一个下标。
 
 示例 2：
 输入：nums = [3,2,1,0,4]
 输出：false
 解释：无论怎样，总会到达下标为 3 的位置。但该下标的最大跳跃长度是 0 ， 所以永远不可能到达最后一个下标。
  
 提示：
 1 <= nums.length <= 3 * 104
 0 <= nums[i] <= 105
 */

extension Solution {
    
    func canJump(_ nums: [Int]) -> Bool {
        let n = nums.count
        var most = 0
        for i in 0..<n {
            most = max(most, i + nums[i])
            if most >= (n - 1) {
                return true
            }
        }
        return false
    }
}
