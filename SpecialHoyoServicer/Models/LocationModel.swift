//
//  LocationModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/12.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class LocationModel: Object { // 个人位置缓存
    
    @objc dynamic var id: String?
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    
    override static func primaryKey () -> String? {
        
        return "id" // 主键-写入数据库后不可更改
    }

    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
