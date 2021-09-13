//
//  Message.swift
//  GeuniVideoStream
//
//  Created by Yeongeun Song on 2021/09/13.
//

import Foundation

struct Message:Codable {
    var id:String
    var message:String
}

extension Encodable {
    func toJSONString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
    
}
