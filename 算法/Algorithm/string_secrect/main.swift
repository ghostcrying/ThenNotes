//
//  main.swift
//  string_secrect
//
//  Created by Putao0474 on 2022/7/11.
//

/*:
 算法: 加密__内部的字符串
 - 只有_ " 数字 字符串组成
 - 字符串连续__加密后只有一个_
 - ""成对出现, 可以是内部作为加密的字符串显示, 也可以表示空字符串
 - 没有加密返回"Error"
 
 例子1:
 saoaasda_ssa324223_timeout_100
 加密后: -> saoaasda_******_timeout_100
 
 例子2:
 2321_"sada43f3223"_timeout__100_""
 加密后: -> 2321_******_timeout_100_""
 */

import Foundation

class Solution {
    /// k: 从下标N开始检索加密字符串
    /// str: 需要检索加密的字符串
    func secrect(_ k: Int, _ str: String ) -> String {
        let n = str.count
        guard k < n else { return "Error" }
        let prefix = [Character](str)[0..<k].map { String($0) }.joined()
        // 作为替换字符串
        var operate = [Character](str)[k..<n].map { String($0) }.joined()
        /// 先替换带有_"的表达式
        let reg1 = """
        [_]+["][a-z0-9]+["][_]+
        """
        /// 再替换带有_xxx_的表达式
        let reg2 = "[_]+[a-z0-9]+[_]+"
        let regs = [reg1, reg2]
        regs.forEach {
            while let range = operate.firstMatch($0) {
                let start = operate.index(operate.startIndex, offsetBy: range.location)
                let ended = operate.index(operate.startIndex, offsetBy: range.location + range.length)
                operate.replaceSubrange(start..<ended, with: "+")
            }
        }
        guard operate.contains("+") else {
            return "Error"
        }
        return prefix + operate.replacingOccurrences(of: "+", with: "_******_")
    }
}

extension String {
    
    func isMatch(_ reg: String) -> Bool {
        let p = NSPredicate(format: "SELF MATCHES %@", reg)
        return p.evaluate(with: self)
    }
    
    func firstMatch(_ pattern: String) -> NSRange? {
        guard let reg = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        let range = reg.rangeOfFirstMatch(in: self, range: NSRange(location: 0, length: self.count))
        if range.length == 0 {
            return nil
        }
        return range
    }
}

func testRegs() {
    let reg1 = """
    [_]+["][a-z0-9]+["][_]+
    """
    let reg2 = """
    [_]+[a-z0-9]+[_]+
    """
    var codes = """
    32asas_scasa121_8093jkdjio_dw
    """
    if let range = codes.firstMatch(reg2) {
        let start = codes.index(codes.startIndex, offsetBy: range.location)
        let ended = codes.index(codes.startIndex, offsetBy: range.location + range.length)
        codes.replaceSubrange(start..<ended, with: "+")
        print(codes)
    }

    let str1 = "dfss11erfre"
    if let reg = try? NSRegularExpression(pattern: "[1-9]", options: []) {
        print(reg.rangeOfFirstMatch(in: str1, range: NSRange(location: 0, length: str1.count)))
    }
}

func testRegs1() {
    /// swift中的正则表达式对于特殊字符: []{} 需要增加\\前缀作为转义
    let reg2 = "[1-9][\\[][a-z]+[\\]]"
    var codes = "2[v]s2[f2[d]]"
    while let range = codes.firstMatch(reg2) {
        let start = codes.index(codes.startIndex, offsetBy: range.location)
        let ended = codes.index(codes.startIndex, offsetBy: range.location + range.length)
        let a = Array(String(codes[start..<ended])).map { String($0) }
        let value = a[2..<(range.length - 3 + 2)].joined()
        // 临时字符串
        var tmp = ""
        for _ in 0..<Int(a[0])! {
            tmp += value
        }
        codes.replaceSubrange(start..<ended, with: tmp)
    }
    print(codes)
}

//let str1 = "saoaasda_ssa324223_timeout_100"
//let str2 = """
//2321_"sada43f3223"_timeout__100_""
//"""
//print(Solution().secrect(10, str2))


extension Solution {
    /// 解密消息
    /// https://leetcode.cn/problems/decode-the-message/
    func decodeMessage(_ key: String, _ message: String) -> String {
        let lows = [Character]("abcdefghijklmnopqrstuvwxyz")
        var map = [Character: Character]()
        var idx = 0
        for c in key {
            guard c != " " else {
                continue
            }
            guard map[c] == nil else {
                continue
            }
            map[c] = lows[idx]
            idx += 1
            guard map.keys.count > 26 else { break }
        }
        return String(message.map { map[$0] ?? " " })
    }
    
    /// 不使用运算符计算两数之和
    /// 无进位和 与 异或运算 规律相同，进位 和 与运算 规律相同（并需左移一位）
    func add(_ a: Int, _ b: Int) -> Int {
        var l = a, r = b
        while r != 0 { // 当进位位0时, 跳出循环
            let c = (l & r) << 1  // 进位
            l = l^r   // l = 无进位和
            r = c     // r = 进位
        }
        return l
    }
    ///  1 1 1 1 0 0
    ///  1 0 1 0 1 0
    /// &1 0 1 0 0 0  << 1 -> 1 0 1 0 0 0 0
    /// ^0 1 0 1 1 0
    
    
    /// 解码异或后的排列
    /// https://leetcode.cn/problems/decode-xored-permutation/
    /// 输入：encoded = [ 6, 5, 4, 6 ]
    /// 输出：[2, 4, 1, 5, 3]
    /// a^b = b^a
    /// a^b^a = a^a^b = b
    /// a^0 = a
    /*:
     我们可以使用A, B, C, D, E代表整数数组perm，注意：它是前 n 个正整数的排列，且 n 是奇数。
     为了表达的方便，可以这么定义：将A XOR B（A和B进行异或运算）简写为AB。
     encoded[i] = perm[i] ^ perm[i + 1]
     encoded[i-1] = perm[i-1] ^ perm[i] // (i >= 1)  encoded[0] = perm[0]^perm[1]
     encoded[i-1] ^ perm[i-1] = perm[i-1] ^ perm[i] ^ perm[i-1]
     encoded[i-1] ^ perm[i-1] = perm[i]

     思路步骤：
     - 既然我们知道了perm = [A, B, C, D, E]，那么encoded = [AB, BC, CD, DE]；
     - 根据perm，我们可以得到ABCDE,根据encoded的BC和DE，我们可以得到BCDE；
     - 将ABCDE和BCDE进行异或运算，得到A，即perm的第一个元素
     */
    func decode(_ encoded: [Int]) -> [Int] {
        // 原始数组长度
        let n = encoded.count + 1
        // 原始数组亦或值
        var t1 = 0
        for i in 1...n {
            t1 ^= i
        }
        var t2 = 0
        for i in stride(from: 1, to: n - 1, by: 2) {
            t2 ^= encoded[i]
        }
        var results = [Int](repeating: 0, count: n)
        results[0] = t1 ^ t2
        for i in 1..<n {
            results[i] = results[i - 1] ^ encoded[i - 1]
        }
        return results
    }
    
    // print(3^3^2) // 0 1 1 ^ 0 1 0 -> 0 0 1 ^ 0 1 1  -> 0 1 0
    // print(3^3)   // 0 1 1 ^ 0 1 1 -> 0     就是0
    // print(3^0)   // 0 1 1 ^ 0 0 0 -> 0 1 1 就是他本身
    
}



