//
//  ImageModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class ImageModel: Object {
    
    @objc dynamic var imageId: String?
    @objc dynamic var imageName: String?
    @objc dynamic var imageUrl: String?
    @objc dynamic var imageType: String?
    @objc dynamic var imageAction: String?
    @objc dynamic var userId: String?
    @objc dynamic var orderId: String?
    @objc dynamic var createTime: String?
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "imageId" // 主键-写入数据库后不可更改
    }
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}


extension ImageModel: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let i = ImageModel()
        i.imageId = imageId
        i.imageName = imageName
        i.imageUrl = imageUrl
        i.imageType = imageType
        i.imageAction = imageAction
        i.userId = userId
        i.orderId = orderId
        i.createTime = createTime
        
        i.remark01 = remark01
        i.remark02 = remark02
        i.remark03 = remark03
        
        return i
    }
}
