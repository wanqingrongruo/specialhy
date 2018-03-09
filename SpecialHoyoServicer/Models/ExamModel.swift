//
//  ExamModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class ExamModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    @objc dynamic var id: String?
    @objc dynamic var subject: String?
    @objc dynamic var userName: String?
    @objc dynamic var fullName: String?
    @objc dynamic var department: String?
    @objc dynamic var post: String?
    @objc dynamic var score: String?
    @objc dynamic var isPass: String?
    @objc dynamic var testDate: String?
    @objc dynamic var createTime: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "id" // 主键-写入数据库后不可更改
    }

    
}

extension ExamModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let e = ExamModel()
        e.id = id
        e.subject = subject
        e.userName = userName
        e.fullName = fullName
        e.department = department
        e.post = post
        e.score = score
        e.isPass = isPass
        e.testDate = testDate
        e.createTime = createTime
        e.remark01 = remark01
        e.remark02 = remark02
        e.remark03 = remark03
        
        return e
    }
}
