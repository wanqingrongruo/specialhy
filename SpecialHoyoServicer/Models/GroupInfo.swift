//
//  GroupInfo.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class GroupInfo: Object { // 小组信息
    
    @objc dynamic var groupId: String?
    @objc dynamic var groupName: String?
    @objc dynamic var groupNumber: String?
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var address: String?
    @objc dynamic var memberState: String?
    @objc dynamic var deposit: String?
    @objc dynamic var createTime: String?
    @objc dynamic var modifyTime: String?
    @objc dynamic var partnerType: String?
    @objc dynamic var memberScope: String?
    @objc dynamic var wareHouse: String?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    let serviceArea = List<ServiceAreaDetail>()
    
    override static func primaryKey () -> String? {
        
        return "groupId" // 主键-写入数据库后不可更改
    }
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
