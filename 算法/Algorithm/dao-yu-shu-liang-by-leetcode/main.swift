//
//  main.swift
//  dao-yu-shu-liang-by-leetcode
//
//  Created by Putao0474 on 2022/7/8.
//
/*:
 ***LeetCode: 200. 岛屿数量
 *https://leetcode.cn/problems/number-of-islands/
 
 给你一个由 '1'（陆地）和 '0'（水）组成的的二维网格，请你计算网格中岛屿的数量。

 岛屿总是被水包围，并且每座岛屿只能由水平方向和/或竖直方向上相邻的陆地连接形成。

 此外，你可以假设该网格的四条边均被水包围。

 示例 1：
 输入：grid = [
   ["1","1","1","1","0"],
   ["1","1","0","1","0"],
   ["1","1","0","0","0"],
   ["0","0","0","0","0"]
 ]
 输出：1
 
 示例 2：
 输入：grid = [
   ["1","1","0","0","0"],
   ["1","1","0","0","0"],
   ["0","0","1","0","0"],
   ["0","0","0","1","1"]
 ]
 输出：3
  
 提示：
 m == grid.length
 n == grid[i].length
 1 <= m, n <= 300
 grid[i][j] 的值为 '0' 或 '1'
 
 */
import Foundation

class Solution {
    /// 逐个遍历
    func numIslands(_ grid: [[Character]]) -> Int {
        var grid = grid
        let paths = [(0, -1), (0, 1), (1, 0), (-1, 0)]
        let m = grid.count
        let n = grid[0].count
        var iland = 0
        for i in 0..<m {
            for j in 0..<n {
                if grid[i][j] == "1" {
                    iland += 1
                    combinelane(&grid, i: i, j: j, paths: paths)
                }
            }
        }
        return iland
    }
    
    private func combinelane(_ grid: inout [[Character]], i: Int, j: Int, paths: [(Int, Int)]) {
        if i < 0 || i >= grid.count || j < 0 || j >= grid[0].count || grid[i][j] == "0" {
            return
        }
        // 修改当前节点位0，继续向附近遍历
        grid[i][j] = "0"
        paths.forEach {
            combinelane(&grid, i: i + $0.0 , j: j + $0.1, paths: paths)
        }
    }
}

let lists: [[Character]] = [["1","1","1","1","0"],
                            ["1","1","0","1","0"],
                            ["1","1","0","0","0"],
                            ["0","0","0","0","0"]]

let lists2: [[Character]] = [["1","1","0","0","0"],
                             ["1","1","0","0","0"],
                             ["0","0","1","0","0"],
                             ["0","0","0","1","1"]]
print("岛屿数量: \(Solution().numIslands(lists))")
print("岛屿数量: \(Solution().numIslands(lists2))")

/// LeetCode:  207. 课程表I
/// https://leetcode.cn/problems/course-schedule/
/// - 返回能否修完当前
/// LeetCode: 210. 课程表II
/// https://leetcode.cn/problems/course-schedule-ii/
///  - 返回当前修课程的数组(1个即可, 没有返回为[])
extension Solution {
    // numCourses: 总课程数目
    // 能否完成课程
    // [[1, 0], [0, 2]]
    // 课程1依赖课程0修完才可以修,0依赖2才可以修
    func canFinish(_ numCourses: Int, _ prerequisites: [[Int]]) -> Bool {
        let n = prerequisites.count
        // 入度数组: 每个课程对应的被依赖
        var degree = [Int](repeating: 0, count: numCourses)
        // 邻接表
        var map = [Int: [Int]]()
        for i in 0..<n {
            // 求课的初始入度值: 被依赖
            degree[prerequisites[i][0]] += 1
            // 当前课是否已经存在于邻接表: [1]就是被依赖课, 也需要更新
            if map[prerequisites[i][1]] != nil {
                // 添加依赖它的后续课: 就是当前课程修完后可以修的课
                map[prerequisites[i][1]] = map[prerequisites[i][1]]! + [prerequisites[i][0]]
            } else {
                // 当前课不存在于邻接表
                map[prerequisites[i][1]] = [prerequisites[i][0]]
            }
        }
        var quene = [Int]()
        // 所有入度为0的课入列: 可以单独修完的课程
        for i in 0..<numCourses {
            if degree[i] == 0 {
                quene.append(i)
            }
        }
        var count = 0
        while quene.count > 0 {
            // 当前选的课，出列
            let selected = quene.removeFirst()
            // 选课数+1
            count += 1
            // 获取这门课对应的后续课
            if let toCourse = map[selected], toCourse.count > 0 {
                // 确实有后续课
                for course in toCourse {
                    // 依赖它的后续课的入度-1: 前面已修完一门, 依赖减少1
                    degree[course] -= 1
                    // 判断是否可以直接修
                    if degree[course] == 0 {
                        // 没有需要前置的课程, 直接入队列, 可以修完了
                        quene.append(course)
                    }
                }
            }
        }
        // 选了的课等于总课数，true，否则false
        return count == numCourses
    }
    
    // 返回课程顺序列表
    func findOrder(_ numCourses: Int, _ prerequisites: [[Int]]) -> [Int] {
        // 依赖数目表: 下标就是课程
        var degree = [Int](repeating: 0, count: numCourses)
        // 邻接表: 当前课程的接下来的课程
        var map = [Int: [Int]]()
        for prerequisite in prerequisites {
            // 依赖+1
            degree[prerequisite[0]] += 1
            // 给课程添加对应的: 修完可修的课程
            if let value = map[prerequisite[1]] {
                map[prerequisite[1]] = value + [prerequisite[0]]
            } else {
                map[prerequisite[1]] = [prerequisite[0]]
            }
        }
        
        // 修课队列
        var deque = [Int]()
        for (i, v) in degree.enumerated() {
            // 把所有不需要依赖的课程先入列, 就是可以直接修完的课程
            if v == 0 {
                deque.append(i)
            }
        }
        
        // 选修课程列表
        var selects = [Int]()
        // 开始修课
        while deque.count > 0 {
            // 课程
            let selected = deque.removeFirst()
            selects.append(selected)
            // 当前课程修完, 可以修后续课程(有被依赖的课程)
            if let courses = map[selected], courses.count > 0 {
                // 遍历后续课程
                for course in courses {
                    // 把课程的入度-1: 就是依赖数目-1
                    degree[course] -= 1
                    // 判断是否可以直接修了
                    if degree[course] == 0 {
                        // 放入修课队列
                        deque.append(course)
                    }
                }
            }
        }
        return selects.count == numCourses ? selects : []
    }
}

print(Solution().findOrder(4, [[1,0],[2,0],[3,1],[3,2]]))

/// LeetCode: 克隆图
/// https://leetcode.cn/problems/clone-graph/solution/xu-yao-yi-ge-ha-xi-biao-cun-chu-yi-jing-tan-suo-gu/
/// 规则:
/// - 节点数不超过 100 。
/// - 每个节点值 Node.val 都是唯一的，1 <= Node.val <= 100。
/// - 无向图是一个简单图，这意味着图中没有重复的边，也没有自环。
/// - 由于图是无向的，如果节点 p 是节点 q 的邻居，那么节点 q 也必须是节点 p 的邻居。
/// - 图是连通图，你可以从给定节点访问到所有节点。
extension Solution {

    public class Node {
        public var val: Int
        public var neighbors: [Node?]
        public init(_ val: Int) {
            self.val = val
            self.neighbors = []
        }
    }
    
    func cloneGraph(_ node: Node?) -> Node? {
        // 用于标记
        var map = [Int: Node?]()
        
        func clone(_ node: Node?) -> Node? {
            guard let n = node else {
                return nil
            }
            // 每个节点值都不一致, hash查找到了, 就返回
            if let last = map[n.val] {
                return last
            }
            // 复制
            let cloneNode = Node(n.val)
            map[n.val] = cloneNode
            // 拷贝邻居节点
            for neighbor in n.neighbors {
                cloneNode.neighbors.append(clone(neighbor))
            }
            return cloneNode
        }
        
        return clone(node)
    }
}

