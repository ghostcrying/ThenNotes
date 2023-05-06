//
//  main.swift
//  trapping-rain-water-ii
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 *** LeetCode: 407. 接雨水 II
 *https://leetcode.cn/problems/trapping-rain-water-ii/
 
 给你一个 m x n 的矩阵，其中的值均为非负整数，代表二维高度图每个单元的高度，请计算图中形状最多能接多少体积的雨水。

 示例 1:
 输入: heightMap = [[1,4,3,1,3,2],[3,2,1,3,2,4],[2,3,3,2,3,1]]
 * https://assets.leetcode.com/uploads/2021/04/08/trap1-3d.jpg
 输出: 4
 解释: 下雨后，雨水将会被上图蓝色的方块中。总的接雨水量为1+2+1=4。
 
 示例 2:
 输入: heightMap = [[3,3,3,3,3], [3,2,2,2,3], [3,2,1,2,3], [3,2,2,2,3], [3,3,3,3,3]]
 * https://assets.leetcode.com/uploads/2021/04/08/trap2-3d.jpg
 输出: 10
  
 提示:
 m == heightMap.length
 n == heightMap[i].length
 1 <= m, n <= 200
 0 <= heightMap[i][j] <= 2 * 104
 
 */

/**
 *  1. 接水判定:
 *  - 边界无法接水
 *  - 该方块自身的高度比其上下左右四个相邻的方块接水后的高度都要低
 *  2. 转换z平面, 就是个矩形木桶
 *  - 假设方块索引为(i, j), 高度为heightMap(i, j), 接水后的高度water(i, j)
 *  - water(i, j) = max(heightMap(i, j), min(water(i-1, j), water(i+1, j), water(i, j-1), water(i, j+1)))
 *  - 实际接水高度: water(i, j) - heightMap(i, j)
 *  - 最外层方块遵循: water(i, j) = heightMap(i, j)
 */

import Foundation

class Solution {
    struct Node: Comparable {
        let i: Int
        let j: Int
        let height: Int
        
        static func < (_ n1: Node, _ n2: Node) -> Bool {
            return n1.height < n2.height
        }
        
        static func > (_ n1: Node, _ n2: Node) -> Bool {
            return n1.height > n2.height
        }
    }
    
    /*
     * 把每一个元素称作块。因为那个图片给的好像瓷砖啊。
     * 其实做这题一开始都是想的是对于每一个块，去找它四个方向最高的高度中的最小值(二维下则是左右最高的高度取较小的那一个)作为上界，当前块作为下界
       但是这4个方向每次遍历复杂度过高，且不能像二维那样去提前预存每个方向的最大值
     * 那可以反过来我不以每个块为处理单元，而是以块的四周作为处理单元
     * 那如何保证所有四周的可能性都考虑到呢？
       我们从矩阵的最外围往里面遍历，像一个圈不断缩小的过程
     * 为了防止重复遍历用visited记录
     * 其次要用小顶堆(以高度为判断基准)来存入所有快的四周(即圈是不断缩小的，小顶堆存的就是这个圈)
     * 为什么要用小顶堆？
       这样可以保证高度较小的块先出队
     ** 为什么要让高度较小的块先出队？(关键点)
       1. 一开始时候就讲了基础做法是：对于每一个块，去找它四个方向最高的高度中的最小值(二维下则是左右最高的高度取较小的那一个)作为上界，当前块作为下界
       2. 而我们现在反过来不是以中心块为处理单元，而是以四周作为处理单元
       3. 我们如果能确保当前出队的元素对于该中心块来说是它周围四个高度中的最小值那么就能确定接雨水的大小
       4. 为什么队头元素的高度比中心块要高它就一定是中心块周围四个高度中的最小值呢？
          因为我们的前提就是小顶堆：高度小的块先出队，所以对于中心块来说，先出队的必然是中心块四周高度最小的那一个
     * 步骤：
       1. 构建小顶堆，初始化为矩阵的最外围(边界所有元素)
       2. 不断出队，倘若队头元素的四周(队头元素的四周其实就是上面说的中心块，队头元素是中心块的四周高度中最矮的一个)
          即代表能够接雨水：队头元素减去该中心块即当前中心块能接雨水的值
       3. 但是接完雨水之后中心块还要存进队列中，但这时要存入的中心块是接完雨水后的中心块
     */
    func trapRainWater(_ heightMap: [[Int]]) -> Int {
        // 必须3*3以上才可以接水
        if heightMap.count <= 2 || heightMap[0].count <= 2 {
            return 0
        }
        let m = heightMap.count
        let n = heightMap[0].count
        // 四个边界
        let path = [(0, -1), (-1, 0), (0, 1), (1, 0)]
        // 变量
        var map = heightMap
        var stack = [Node]()
        // 是否访问过
        var visit = Array(repeating: [Bool](repeating: false, count: n), count: m)
        // 先把最外边一圈放入队列并排序
        for i in 0..<m {
            for j in 0..<n {
                if i == 0 || j == 0 || i == m-1 || j == n-1 {
                    visit[i][j] = true
                    stack.append(Node(i: i, j: j, height: heightMap[i][j]))
                }
            }
        }
        // 排序: 最终从最小的节点开始走
        stack.sort(by: >)
        
        var res = 0
        while !stack.isEmpty {
            let node = stack.popLast()!
            let minHeight = node.height
            // 查看四周相邻格子, 是否可以灌水
            for p in path {
                let i = node.i + p.0, j = node.j + p.1
                // 超出边界或者已处理过
                if i < 0 || i >= m || j < 0 || j >= n || visit[i][j] {
                    continue
                }
                let curheight = map[i][j]
                // 格子有差值, 说明可以灌水
                if minHeight > curheight {
                    // 灌水
                    res += minHeight - curheight
                    // 将邻居家灌满水
                    map[i][j] = minHeight
                }
                // 该节点加入队列
                stack.append(Node(i: i, j: j, height: map[i][j]))
                // 排序, 插入排序
                stack.sort(by: >)
                // 标记已处理过
                visit[i][j] = true
            }
        }
        return res
    }
}

let lists_1 = [[1, 4, 3, 1, 3, 2], [3, 2, 1, 3, 2, 4], [2, 3, 3, 2, 3, 1]]
let lists_2 = [[3, 3, 3, 3, 3], [3, 2, 2, 2, 3], [3, 2, 1, 2, 3], [3, 2, 2, 2, 3], [3, 3, 3, 3, 3]]

print(Solution().trapRainWater(lists_1))
print(Solution().trapRainWater(lists_2))

