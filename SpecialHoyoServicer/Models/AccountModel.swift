//
//  AccountModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/25.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class AccountModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    @objc dynamic var id: String?
    @objc dynamic var balance: String?
    @objc dynamic var income: String?
    @objc dynamic var totalAssets: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
}
