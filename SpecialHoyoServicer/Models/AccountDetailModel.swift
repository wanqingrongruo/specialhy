//
//  AccountDetailModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/25.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class AccountDetailModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    @objc dynamic var id: String?
    @objc dynamic var userId: String?
    @objc dynamic var payId: String?
    @objc dynamic var money: String?
    @objc dynamic var way: String?
    @objc dynamic var remark: String?
    @objc dynamic var createTime: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
}
