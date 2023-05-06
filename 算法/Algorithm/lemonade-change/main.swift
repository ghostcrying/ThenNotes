//
//  main.swift
//  lemonade-change
//
//  Created by Putao0474 on 2022/7/22.
//
/*:
 *** LeetCode: 860. 柠檬水找零
 *** https://leetcode.cn/problems/lemonade-change/
 
 在柠檬水摊上，每一杯柠檬水的售价为 5 美元。顾客排队购买你的产品，（按账单 bills 支付的顺序）一次购买一杯。
 每位顾客只买一杯柠檬水，然后向你付 5 美元、10 美元或 20 美元。你必须给每个顾客正确找零，也就是说净交易是每位顾客向你支付 5 美元。
 注意，一开始你手头没有任何零钱。
 给你一个整数数组 bills ，其中 bills[i] 是第 i 位顾客付的账。如果你能给每位顾客正确找零，返回 true ，否则返回 false 。


 示例 1：
 输入：bills = [5,5,5,10,20]
 输出：true
 解释：
 前 3 位顾客那里，我们按顺序收取 3 张 5 美元的钞票。
 第 4 位顾客那里，我们收取一张 10 美元的钞票，并返还 5 美元。
 第 5 位顾客那里，我们找还一张 10 美元的钞票和一张 5 美元的钞票。
 由于所有客户都得到了正确的找零，所以我们输出 true。
 
 示例 2：
 输入：bills = [5,5,10,10,20]
 输出：false
 解释：
 前 2 位顾客那里，我们按顺序收取 2 张 5 美元的钞票。
 对于接下来的 2 位顾客，我们收取一张 10 美元的钞票，然后返还 5 美元。
 对于最后一位顾客，我们无法退回 15 美元，因为我们现在只有两张 10 美元的钞票。
 由于不是每位顾客都得到了正确的找零，所以答案是 false。
  
 提示：
 1 <= bills.length <= 105
 bills[i] 不是 5 就是 10 或是 20
 */

import Foundation

class Solution {
    
    func lemonadeChange(_ bills: [Int]) -> Bool {
        var five = 0, ten = 0
        for i in bills {
            switch i {
            case 5:
                five += 1
            case 10:
                if five > 0 {
                    five -= 1
                    ten += 1
                } else {
                    return false
                }
            case 20:
                if five > 0 && ten > 0 {
                    five -= 1
                    ten -= 1
                } else if five >= 3 {
                    five -= 3
                } else {
                    return false
                }
            default:
                return false
            }
        }
        return true
    }
}

/*:
 LeetCode: 122. 买卖股票的最佳时机 II
 *** https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/
 给你一个整数数组 prices ，其中 prices[i] 表示某支股票第 i 天的价格。
 在每一天，你可以决定是否购买和/或出售股票。你在任何时候 最多 只能持有 一股 股票。你也可以先购买，然后在 同一天 出售。
 返回 你能获得的 最大 利润 。


 示例 1：
 输入：prices = [7,1,5,3,6,4]
 输出：7
 解释：在第 2 天（股票价格 = 1）的时候买入，在第 3 天（股票价格 = 5）的时候卖出, 这笔交易所能获得利润 = 5 - 1 = 4 。
      随后，在第 4 天（股票价格 = 3）的时候买入，在第 5 天（股票价格 = 6）的时候卖出, 这笔交易所能获得利润 = 6 - 3 = 3 。
      总利润为 4 + 3 = 7 。
 
 示例 2：
 输入：prices = [1,2,3,4,5]
 输出：4
 解释：在第 1 天（股票价格 = 1）的时候买入，在第 5 天 （股票价格 = 5）的时候卖出, 这笔交易所能获得利润 = 5 - 1 = 4 。
      总利润为 4 。
 
 示例 3：
 输入：prices = [7,6,4,3,1]
 输出：0
 解释：在这种情况下, 交易无法获得正利润，所以不参与交易可以获得最大利润，最大利润为 0 。
  

 提示：

 1 <= prices.length <= 3 * 104
 0 <= prices[i] <= 104
 */

extension Solution {
    /// https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/solution/mai-mai-gu-piao-de-zui-jia-shi-ji-ii-by-leetcode-s/
    /// 相当于查找x个(l, r)区间的的和值
    /// 那么根据贪心算法, 则最大值就是(l, r)之间利润>0的总和
    /// 贪心算法只能求得最终值, 计算的过程并不是实际的交易过程
    func maxProfit(_ prices: [Int]) -> Int {
        var result = 0
        for i in 1..<prices.count {
            result += max(prices[i] - prices[i-1], 0)
        }
        return result
    }
}

