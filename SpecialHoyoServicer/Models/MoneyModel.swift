//
//  MoneyModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class MoneyModel: Object {
    
    @objc dynamic var title: String?
    @objc dynamic var money: Double = 0
    @objc dynamic var remark: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?

    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

extension MoneyModel: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let m = MoneyModel()
        m.title = title
        m.money = money
        m.remark = remark
        m.remark01 = remark01
        m.remark02 = remark02
        m.remark03 = remark03
        
        return m
    }
}
