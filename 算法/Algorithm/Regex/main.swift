//
//  main.swift
//  Regex
//
//  Created by Putao0474 on 2022/7/20.
//

import Foundation

/*:
 元字符转义:
 ^ $ . * + ? | \ / ( ) [ ] { } = ![]: - ,
 
 需要用\\转义
 */

//func regex_special() {
//    let regex = "\\^\\$\\.\\*\\+\\?\\|\\\\\\/\\[\\]\\{\\}\\=\\!\\:\\-\\,"
//    let validate = "^$.*+?|\\/[]{}=!:-,"
//    let result = RegularExpression(regex: regex, validateString: validate)
//    print(result)
//    //["^$.*+?|\\/[]{}=!:-,"]
//
//    let regex1 = "\\[abc]"
//    let validate1 = "[abc]"
//    let result1 = RegularExpression(regex: regex, validateString: validate)
//    print(result)
//    //["[abc]"]
//}

extension String {
    
    func firstMatch(_ pattern: String) -> NSRange? {
        guard let regular = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = regular.rangeOfFirstMatch(in: self, range: NSRange(location: 0, length: count))
        if range.length == 0 {
            return nil
        }
        return range
    }
    
    func subString(_ range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let ended = index(startIndex, offsetBy: range.location + range.length)
        return String(self[start..<ended])
    }
}

extension String {
    /// 正则匹配
    ///
    /// - Parameters:
    ///   - regex: 匹配规则
    ///   - validateString: 匹配对test象
    /// - Returns: 返回结果
    func RegularExpression (regex: String, validateString: String) -> [String] {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))
            
            var data:[String] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }
            
            return data
        }
        catch {
            return []
        }
    }


    /// 字符串的替换
    ///
    /// - Parameters:
    ///   - validateString: 匹配对象
    ///   - regex: 匹配规则
    ///   - content: 替换内容
    /// - Returns: 结果
    func replace(validateString:String, regex:String,content:String) -> String {
        do {
            let RE = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let modified = RE.stringByReplacingMatches(in: validateString, options: .reportProgress, range: NSRange(location: 0, length: validateString.count), withTemplate: content)
            return modified
        }
        catch {
            return validateString
        }
       
    }

}

/// \字符的匹配在swift中需要转义: \\\\
func regex_Special() {
    let threeDoubleQuotes = """
    \\\\Escaping the first quote
    """
    // 字符串中\\是转义之后的\
    print(threeDoubleQuotes) // \\Escaping the first quote
    let reg = """
    [\\\\][\\\\][a-z]+
    """
    if let range = threeDoubleQuotes.firstMatch(reg) {
        print(range)
        print(threeDoubleQuotes.subString(range))
    }
}
regex_Special()

/// 忽略大小写匹配
/// 修饰语 i 用于忽略大小写。 例如，表达式 /The/gi 表示在全局搜索 The，在后面的 i 将其条件修改为忽略大小写，则变成搜索 the 和 The，g 表示全局搜索。
func regex_CaseInsensitive() {
    let reg = """
    [The]\\/gi
    """
    let str = "The fat cat sat on the mat."
    if let range = str.firstMatch(reg) {
        print(range)
    }
}
regex_CaseInsensitive()

/// \d  [0-9]    表示是一位数字  其英文是digit（数字）
/// \D  [^0-9] 表示除数字外的任意字符
/// \w  [0-9a-zA-Z_]表示数字、大小写字母和下划线 w是word的简写，也称单词字符
/// \W  [^0-9a-zA-Z_] 非单词字符
/// \s   [ \t\v\n\r\f]表示空白符，包括空格、水平制表符、垂直制表符、换行符、回车符、换页符 s是space character的首字母
/// \S  [^ \t\v\n\r\f] 非空白符
/// .    [^\n\r\u2028\u2029]通配符，表示几乎任意字符。换行符、回车符、行分隔符和段分隔符除外
func regex_Character() {
    let reg = """
    \\W
    """
    let str = "The fat cat sat on the mat. 87298"
    if let range = str.firstMatch(reg) {
        print(range)
    }
}
// regex_Character()


/// 量词: 出现次数
/// {m,} 表示至少出现m次
/// {m} 等价于{m,m}，表示出现m次
/// ? 等价于{0,1}，表示出现或者不出现。记忆方式：问号的意思表示，有吗？
/// + 等价于{1,}，表示出现至少一次。记忆方式：加号是追加的意思，得先有一个，然后才考虑追加。
/// * 等价于{0,}，表示出现任意次，有可能不出现。记忆方式：看看天上的星星，可能一颗没有，可能零散有几颗，可能数也数不过来。
func regex_number() {
    let reg = """
    a{2}
    """
    let str = "The faat cat sat on the mat."
    if let range = str.firstMatch(reg) {
        print(range)
    }
}

let test1 = "++ 【非个人信息的收集和使用】--"
// #"[【][.{1, 50}][】]"#
let regex1 = "【(.*)】"
print(test1.firstMatch(regex1)?.length)
// regex_number()
