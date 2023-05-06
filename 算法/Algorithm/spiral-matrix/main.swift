//
//  main.swift
//  spiral-matrix
//
//  Created by Putao0474 on 2022/6/30.
//
/**
 ***LeetCode: 54. 螺旋矩阵
 *https://leetcode.cn/problems/spiral-matrix
 给你一个 m 行 n 列的矩阵 matrix ，请按照 顺时针螺旋顺序 ，返回矩阵中的所有元素。

 示例 1：
 输入：matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
 * 1  ->  2  ->  3
 *               ↓
 * 4  ->  5      6
 * ↑             ↓
 * 7  <-  8  <-  9
 * https://assets.leetcode.com/uploads/2020/11/13/spiral1.jpg
 输出：[1,2,3,6,9,8,7,4,5]
 
 示例 2：
 输入：matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
 * https://assets.leetcode.com/uploads/2020/11/13/spiral.jpg
 输出：[1,2,3,4,8,12,11,10,9,5,6,7]
  
 提示：
 m == matrix.length
 n == matrix[i].length
 1 <= m, n <= 10
 -100 <= matrix[i][j] <= 100
 */
import Foundation

let lists_1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
let lists_2 = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]

class Solution {
    
    // 可以模拟螺旋矩阵的路径。初始位置是矩阵的左上角，初始方向是向右，当路径超出界限或者进入之前访问过的位置时，顺时针旋转，进入下一个方向。
    // 判断路径是否进入之前访问过的位置需要使用一个与输入矩阵大小相同的辅助矩阵visited，其中的每个元素表示该位置是否被访问过。当一个元素被访问时，将visited 中的对应位置的元素设为已访问
    func spiralOrder_1(_ matrix: [[Int]]) -> [Int] {
        let m = matrix.count
        let n = matrix[0].count
        let path = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        var visit = Array(repeating: [Bool](repeating: false, count: n), count: m)
        var results = [Int]()
        var x = 0, y = 0, index = 0
        for _ in  0..<m * n {
            results.append(matrix[x][y])
            visit[x][y] = true
            let nextX = x + path[index].0
            let nextY = y + path[index].1
            if nextX < 0 || nextX >= m || nextY < 0 || nextY >= n || visit[nextX][nextY] {
                index = (index + 1) % 4
            }
            x += path[index].0
            y += path[index].1
        }
        return results
    }
    
    // 回字形一层一层遍历
    func spiralOrder_2(_ matrix: [[Int]]) -> [Int] {
        let m = matrix.count
        let n = matrix[0].count
        var l = 0, r = n-1, t = 0, b = m-1
        var result = [Int]()
        while l <= r && t <= b {
            for i in stride(from: l, through: r, by: 1) {
                result.append(matrix[t][i])
            }
            for i in stride(from: t + 1, through: b, by: 1) {
                result.append(matrix[i][r])
            }
            // 边界缩减
            if l < r && t < b {
                for i in stride(from: r, through: l+1, by: -1) {
                    result.append(matrix[b][i])
                }
                for i in stride(from: b, through: t+1, by: -1) {
                    result.append(matrix[i][l])
                }
            }
            l += 1
            r -= 1
            t += 1
            b -= 1
        }
        return result
    }
}

print(Solution().spiralOrder_2(lists_1)) // [1, 2, 3, 6, 9, 8, 7, 4, 5]
print(Solution().spiralOrder_2(lists_2)) // [1, 2, 3, 4, 8, 12, 11, 10, 9, 5, 6, 7]
