//
//  main.swift
//  sum-of-distances-in-tree
//
//  Created by Putao0474 on 2022/7/7.
//
/*:
 ***LeetCode: 834. 树中距离之和
 *https://leetcode.cn/problems/sum-of-distances-in-tree/
 
 给定一个无向、连通的树。树中有 n 个标记为 0...n-1 的节点以及 n-1 条边 。

 给定整数 n 和数组 edges ， edges[i] = [ai, bi]表示树中的节点 ai 和 bi 之间有一条边。

 返回长度为 n 的数组 answer ，其中 answer[i] 是树中第 i 个节点与所有其他节点之间的距离之和。


 示例 1:
 https://assets.leetcode.com/uploads/2021/07/23/lc-sumdist1.jpg
 输入: n = 6, edges = [[0,1],[0,2],[2,3],[2,4],[2,5]]
 输出: [8,12,6,10,10,10]
 解释: 树如图所示。
 我们可以计算出 dist(0,1) + dist(0,2) + dist(0,3) + dist(0,4) + dist(0,5)
 也就是 1 + 1 + 2 + 2 + 2 = 8。 因此，answer[0] = 8，以此类推。
 
 示例 2:
 输入: n = 1, edges = []
 输出: [0]
 
 示例 3:
 输入: n = 2, edges = [[1,0]]
 输出: [1,1]
  

 提示:
 1 <= n <= 3 * 104
 edges.length == n - 1
 edges[i].length == 2
 0 <= ai, bi < n
 ai != bi
 给定的输入保证为有效的树

 */

import Foundation

class Solution {
    
    private var sz = [Int]()  // sz[u]表示以 u 为根的子树的节点数量
    private var dp = [Int]()  // dp[u]表示以 u 为根的子树，它的所有子节点到它的距离之和
    private var ans = [Int]() //
    
    func sumOfDistancesInTree(_ n: Int, _ edges: [[Int]]) -> [Int] {
        var graph = Array(repeating: [Int](), count: n)
        // 建立邻接表，由于是无向树，因此两个节点互相邻接
        for edge in edges {
            let a = edge[0], b = edge[1]
            graph[a].append(b)
            graph[b].append(a)
        }
        sz  = [Int](repeating: 0, count: n)
        dp  = [Int](repeating: 0, count: n)
        ans = [Int](repeating: 0, count: n)
        
        dfs1(u: 0, f: -1, graph: graph)
        
        dfs2(u: 0, f: -1, graph: graph)
        
        return ans
    }
    // 对根节点 0 执行树状dp
    // u: 当前节点，f: 当前节点的“根”节点
    private func dfs1(u: Int, f: Int, graph: [[Int]]) {
        sz[u] = 1
        dp[u] = 0
        for v in graph[u] {
            // 邻接点不允许为u的根节点
            if v == f {
                continue
            }
            dfs1(u: v, f: u, graph: graph)
            dp[u] += dp[v] + sz[v]
            sz[u] += sz[v]
        }
    }
    // 执行换根操作
    private func dfs2(u: Int, f: Int, graph: [[Int]]) {
        // 记录节点u的结果
        ans[u] = dp[u]
        // 对u的相邻边进行换根
        for v in graph[u] {
            // 邻接点不允许为u的根节点
            if v == f { continue }
            // 暂时储存 等待u换为v之后再还原
            // 因为u有很多v要换 这些值需要重复使用
            let pu = dp[u], pv = dp[v]
            let su = sz[u], sv = sz[v]
            // 换根递推式
            dp[u] -= dp[v] + sz[v]
            sz[u] -= sz[v]
            dp[v] += dp[u] + sz[u]
            sz[v] += sz[u]
            // 记录v的值 并且对v的邻边进行换根
            dfs2(u: v, f: u, graph: graph)
            // 还原
            dp[u] = pu
            dp[v] = pv
            sz[u] = su
            sz[v] = sv
        }
    }
}

let lists = [[0,1],[0,2],[2,3],[2,4],[2,5]]

print(Solution().sumOfDistancesInTree(6, lists))

