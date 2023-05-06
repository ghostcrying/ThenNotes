//
//  main.swift
//  get-watched-videos-by-your-friends
//
//  Created by 大大 on 2022/7/6.
//
/*:
 ***LeetCode: 1311. 获取你好友已观看的视频
 * https://leetcode.cn/problems/get-watched-videos-by-your-friends/
 有 n 个人，每个人都有一个  0 到 n-1 的唯一 id 。

 给你数组 watchedVideos 和 friends ，其中 watchedVideos[i]  和 friends[i] 分别表示 id = i 的人观看过的视频列表和他的好友列表。
 Level 1 的视频包含所有你好友观看过的视频，level 2 的视频包含所有你好友的好友观看过的视频，以此类推。一般的，Level 为 k 的视频包含所有从你出发，最短距离为 k 的好友观看过的视频。
 给定你的 id  和一个 level 值，请你找出所有指定 level 的视频，并将它们按观看频率升序返回。如果有频率相同的视频，请将它们按字母顺序从小到大排列。

 示例 1：
 https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2020/01/03/leetcode_friends_1.png
 输入：watchedVideos = [["A","B"],["C"],["B","C"],["D"]], friends = [[1,2],[0,3],[0,3],[1,2]], id = 0, level = 1
 输出：["B","C"]
 解释：
 你的 id 为 0（绿色），你的朋友包括（黄色）：
 id 为 1 -> watchedVideos = ["C"]
 id 为 2 -> watchedVideos = ["B","C"]
 你朋友观看过视频的频率为：
 B -> 1
 C -> 2
 
 示例 2：
 https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2020/01/03/leetcode_friends_2.png
 输入：watchedVideos = [["A","B"],["C"],["B","C"],["D"]], friends = [[1,2],[0,3],[0,3],[1,2]], id = 0, level = 2
 输出：["D"]
 解释：
 你的 id 为 0（绿色），你朋友的朋友只有一个人，他的 id 为 3（黄色）。
  
 提示：
 n == watchedVideos.length == friends.length
 2 <= n <= 100
 1 <= watchedVideos[i].length <= 100
 1 <= watchedVideos[i][j].length <= 8
 0 <= friends[i].length < n
 0 <= friends[i][j] < n
 0 <= id < n
 1 <= level < n
 如果 friends[i] 包含 j ，那么 friends[j] 包含 i
 */

import Foundation

class Solution {
    
    func watchedVideosByFriends(_ watchedVideos: [[String]], _ friends: [[Int]], _ id: Int, _ level: Int) -> [String] {
        // 记录视频观看次数
        var videosCounter = [String: Int]()
        // 记录将要处理层的朋友id (int)
        var quene: [Int] = [id]
        // 记录该层是否被记录过
        var visited = [Bool](repeating: false, count: friends.count)
        visited[id] = true
        
        var depth = 0
        while !queue.isEmpty && depth <= level {
            // 记录下一层朋友: visited防止重复
            var nextLevel = [Int]()
            queue.forEach {
                if depth == level {
                    // 最终level层更新视频观看数
                    watchedVideos[$0].forEach {
                        videosCounter.updateValue((videosCounter[$0] ?? 0) + 1, forKey: $0)
                    }
                } else {
                    friends[$0].forEach {
                        // 防止重复记录
                        if !visited[$0] {
                            visited[$0] = true
                            nextLevel.append($0)
                        }
                    }
                }
            }
            queue = nextLevel
            depth += 1
        }
        // 排序
        let sortedVideoCounter = videosCounter.sorted { (argv1, argv2) -> Bool in
            if argv1.value == argv2.value {
                return argv1.key < argv2.key
            }
            return argv1.value < argv2.value
        }
        //
        return sortedVideoCounter.map { $0.key }
    }
}

