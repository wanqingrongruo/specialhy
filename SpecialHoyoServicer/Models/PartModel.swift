//
//  PartModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class PartModel: Object {
    
    @objc dynamic var productId: String?
    @objc dynamic var productName: String?
    @objc dynamic var productModel: String?
    @objc dynamic var productPrice: String?
    @objc dynamic var productImageUrl: String?
    @objc dynamic var productAmount: Int = 0
    
    @objc dynamic var productOne: String?
    @objc dynamic var productTwo: String?
    @objc dynamic var productThree: String?
    
    override static func primaryKey () -> String? {
        
        return "productId" // 主键-写入数据库后不可更改
    }
    
// Specify properties to ignore (Realm won't persist these)
    
  override static func ignoredProperties() -> [String] {
    return ["productAmount"]
  }
}

extension PartModel: NSCopying{
    
    func copy(with zone: NSZone? = nil) -> Any {
        let p = PartModel()
        p.productId = productId
        p.productName = productName
        p.productModel = productModel
        p.productPrice = productPrice
        p.productImageUrl = productImageUrl
        p.productAmount = productAmount
        
        p.productOne = productOne
        p.productTwo = productTwo
        p.productThree = productThree
        
        return p
    }
}
