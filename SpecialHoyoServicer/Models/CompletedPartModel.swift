//
//  CompletedPartModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class CompletedPartModel: Object {
    
    @objc dynamic var productId: String?
    @objc dynamic var productName: String?
    @objc dynamic var productModel: String?
    @objc dynamic var productPrice: String?
    @objc dynamic var productImageUrl: String?
    @objc dynamic var productAmount: Int = 0
    @objc dynamic var productOne: String?
    @objc dynamic var productTwo: String?
    @objc dynamic var productThree: String?
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?

    
    override static func primaryKey () -> String? {
        
        return "productId" // 主键-写入数据库后不可更改
    }
    
}

extension CompletedPartModel: NSCopying{
    
    func copy(with zone: NSZone? = nil) -> Any {
        let p = CompletedPartModel()
        p.productId = productId
        p.productName = productName
        p.productModel = productModel
        p.productPrice = productPrice
        p.productImageUrl = productImageUrl
        p.productAmount = productAmount
        p.productOne = productOne
        p.productTwo = productTwo
        p.productThree = productThree
        
        p.remark01 = remark01
        p.remark02 = remark02
        p.remark03 = remark03
        
        return p
    }
}
