//
//  DestinationLocation.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/24.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class DestinationLocation: Object {
    
    @objc dynamic var crmId: String?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var remark011: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "crmId" // 主键-写入数据库后不可更改
    }

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

extension DestinationLocation: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let d = DestinationLocation()
        d.crmId = crmId
        d.latitude = latitude
        d.longitude = longitude
        d.remark011 = remark011
        d.remark02 = remark02
        d.remark03 = remark03
        return d
    }
}
