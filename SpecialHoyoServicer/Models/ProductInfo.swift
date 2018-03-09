//
//  ProductInfo.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class ProductInfo: Object {
    
    @objc dynamic var companyID: String?
    @objc dynamic var companyName: String?
    @objc dynamic var productNumber: String?
    @objc dynamic var productModel: String?
    @objc dynamic var productName: String?
    @objc dynamic var image: String?
    @objc dynamic var productKind: String?
    
//    override static func primaryKey () -> String? {
//        
//        return "companyID" // 主键-写入数据库后不可更改
//    }
}
