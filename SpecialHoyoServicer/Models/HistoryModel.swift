//
//  HistoryModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/23.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryModel: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var homeTime: String?
    @objc dynamic var creatTime: String?
    @objc dynamic var orderId: String?
    @objc dynamic var remark: String?
    @objc dynamic var userId: String?
    @objc dynamic var way: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "id" // 主键-写入数据库后不可更改
    }
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}


extension HistoryModel {
    
    override func copy() -> Any {
        let h = HistoryModel()
        h.id = id
        h.homeTime = homeTime
        h.creatTime = creatTime
        h.orderId = orderId
        h.remark = remark
        h.userId = userId
        h.way = way
        
        h.remark01 = remark01
        h.remark02 = remark02
        h.remark03 = remark03
        
        return h
    }
}
