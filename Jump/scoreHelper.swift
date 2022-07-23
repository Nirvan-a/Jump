//
//  scoreHelper.swift
//  Jump
//
//  Created by nirvana on 2022/7/23.
//

import Foundation

struct Statistic: Comparable, Equatable, Codable {
    var score: Int
    var time: String
    static func < (lhs: Statistic, rhs: Statistic)-> Bool {
            return lhs.score < rhs.score
        }
}

class ScoreHelper: Codable {
    static let scoreHeplper = ScoreHelper()
    
    var list: [Statistic] = []
    
    static func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateStr = dateFormatter.string(from: Date())
        return dateStr
    }
    //排序后的分数
    var orderList: [Statistic] {
        return list.sorted(by: >)
    }
    //存储方法
    static var archiveURL: URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentsDirectory.appendingPathComponent("record_array").appendingPathExtension("plist")
        }
        
        static func saveToFile(record: [Statistic]){
            let propertyListEncoder = PropertyListEncoder()
            let encodedEmoji = try? propertyListEncoder.encode(record)
            try? encodedEmoji?.write(to: archiveURL, options: .noFileProtection)
        }
        
        static func loadFromFile()-> [Statistic] {
            let propertyListDecoder = PropertyListDecoder()
            if let retrieveData = try? Data(contentsOf: archiveURL) {
                let decodeEmojis = try? propertyListDecoder.decode([Statistic].self, from: retrieveData)
                return decodeEmojis!
            }else {
                return []
            }
            
        }
}
