//
//  AuthIndoModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class AuthInfoModel: Object {
    
    
    @objc dynamic var name: String?
    @objc dynamic var cardId: String?
    @objc dynamic var imageFront: String?
    @objc dynamic var imageBehind: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    @objc dynamic var remark04: String?
    @objc dynamic var remark05: String?
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    
}
