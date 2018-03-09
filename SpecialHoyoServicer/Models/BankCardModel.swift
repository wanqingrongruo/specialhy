//
//  BankCardModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/25.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class BankCardModel: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    @objc dynamic var bankLogo: String?
    @objc dynamic var bankName: String?
    @objc dynamic var bankType: String?
    @objc dynamic var bindTime: String?
    @objc dynamic var cardId: String?
    @objc dynamic var cardPhone: String?
    @objc dynamic var id: String?
    @objc dynamic var userName: String?
    @objc dynamic var bankId: String?
    @objc dynamic var bankBranch: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "id" // 主键-写入数据库后不可更改
    }
}


extension BankCardModel: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let b = BankCardModel()
        b.bankLogo = bankLogo
        b.bankName = bankName
        b.bankType = bankType
        b.bindTime = bindTime
        b.cardId = cardId
        b.cardPhone = cardPhone
        b.id = id
        b.userName = userName
        b.bankId = bankId
        b.bankBranch = bankBranch
        b.remark01 = remark01
        b.remark02 = remark02
        b.remark03 = remark03
        
        return b
    }
}
