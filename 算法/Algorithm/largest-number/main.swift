//
//  main.swift
//  largest-number
//
//  Created by Putao0474 on 2022/7/22.
//
/*:
 ***LeetCode: 179. 最大数
 ***https://leetcode-cn.com/problems/largest-number
 给定一组非负整数 nums，重新排列每个数的顺序（每个数不可拆分）使之组成一个最大的整数。

 注意：输出结果可能非常大，所以你需要返回一个字符串而不是整数。

  
 示例 1：
 输入：nums = [10,2]
 输出："210"
 
 示例 2：
 输入：nums = [3,30,34,5,9]
 输出："9534330"
  

 提示：
 1 <= nums.length <= 100
 0 <= nums[i] <= 109
 */
import Foundation

/*:
 解题思路
 对于数组怎么排序，我们可以发现，优先高位数大的排在前面即可

 对于两个数不一致的情况，我们依次对高位进行大小比对，直至分成大小
 对于某一个数是另一个数的前缀时，我们采用循环对比，拿超出的字符跟前缀对比，比如 对于 [111311, 1113],我们需要将 1113放在前面。
 */
class Solution {
    //
    func largestNumber(_ nums: [Int]) -> String {
        let sort = nums.sorted { x, y in
            let s1 = "\(x)\(y)"
            let s2 = "\(y)\(x)"
            return s1 > s2
        }
        if sort[0] == 0 {
            return "0"
        }
        return sort.map { "\($0)" }.joined()
    }
    
}

/*:
 ***LeetCode: 324. 摆动排序 II
 ***https://leetcode.cn/problems/wiggle-sort-ii/
 给你一个整数数组 nums，将它重新排列成 nums[0] < nums[1] > nums[2] < nums[3]... 的顺序。

 你可以假设所有输入数组都可以得到满足题目要求的结果。

  

 示例 1：

 输入：nums = [1,5,1,1,6,4]
 输出：[1,6,1,5,1,4]
 解释：[1,4,1,5,1,6] 同样是符合题目要求的结果，可以被判题程序接受。
 示例 2：

 输入：nums = [1,3,2,2,3,1]
 输出：[2,3,1,3,1,2]
  

 提示：

 1 <= nums.length <= 5 * 104
 0 <= nums[i] <= 5000
 题目数据保证，对于给定的输入 nums ，总能产生满足题目要求的结果

 */
extension Solution {
    
    func wiggleSort(_ nums: inout [Int]) {
        let arr = nums.sorted()
        let n = arr.count
        let x = (n + 1) / 2
        var i = 0, j = x - 1, k = n - 1
        while i < n, j >= 0, k >= 0 {
            nums[i] = arr[j]
            if i + 1 < n {
                nums[i + 1] = arr[k]
            }
            j -= 1
            k -= 1
            i += 2
        }
    }
}
var lists1 = [1,3,2,2,3,1]
var lists2 = [1,5,1,1,6,4]
Solution().wiggleSort(&lists1)
print(lists1)
Solution().wiggleSort(&lists2)
print(lists2)


/*:
 ***LeetCode: 287. 寻找重复数
 ***https://leetcode-cn.com/problems/find-the-duplicate-number

 给定一个包含 n + 1 个整数的数组 nums ，其数字都在 [1, n] 范围内（包括 1 和 n），可知至少存在一个重复的整数。
 假设 nums 只有 一个重复的整数 ，返回 这个重复的数 。
 你设计的解决方案必须 不修改 数组 nums 且只用常量级 O(1) 的额外空间。

 示例 1：
 输入：nums = [1, 3, 4, 2, 2]
 输出：2
 
 示例 2：
 输入：nums = [3, 1, 3, 4, 2]
 输出：3
  
 提示：
 1 <= n <= 105
 nums.length == n + 1
 1 <= nums[i] <= n
 nums 中 只有一个整数 出现 两次或多次 ，其余整数均只出现 一次

 */
extension Solution {
    // 快慢指针: 参考循环链表查找环节点方式
    func findDuplicate(_ nums: [Int]) -> Int {
        var s = 0, f = 0
        while s != f {
            s = nums[s]
            f = nums[nums[f]]
        }
        s = 0
        while s != f {
            s = nums[s]
            f = nums[f]
        }
        return s
    }
}


extension Solution {
    
    // 爬楼梯
    // f(x) = f(x-1) + f(x-2)
    // 迭代: 会超时
    func climbStairs(_ n: Int) -> Int {
        if n <= 3 {
            return n
        }
        return climbStairs(n-1) + climbStairs(n-2)
    }
    //
    func climbStairs_1(_ n: Int) -> Int {
        if n <= 3 {
            return n
        }
        var f2 = 2
        var f3 = 3
        for _ in 4...n {
            let r = f2 + f3
            f2 = f3
            f3 = r
        }
        return f3
    }
    
    // 平方数查找
    func mySqrt(_ x: Int) -> Int {
        var left = 0, right = x
        var res = 0
        while left <= right {
            let mid = left + (right - left) / 2
            if mid * mid > x {
                right = mid - 1
            } else {
                res = mid
                left = mid + 1
            }
        }
        return res
    }

}
