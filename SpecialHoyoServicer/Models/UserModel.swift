//
//  UserModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class UserModel: Object {
    
    // Specify properties to ignore (Realm won't persist these)
    
    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
    @objc dynamic var id: String?
    @objc dynamic var userId: String?
    @objc dynamic var userToken: String?
    @objc dynamic var openId: String?
    @objc dynamic var name: String?
    @objc dynamic var realName: String?
    @objc dynamic var nickName: String? // 使用这个 name
    @objc dynamic var mobile: String?
    @objc dynamic var headImageUrl: String?
    @objc dynamic var sex: String? // 0: 女 1:男 2&"": 保密
    @objc dynamic var score: String?
    @objc dynamic var scope: String?
    @objc dynamic var isReal: Int = 0
    @objc dynamic var ctime: String?
    
    // 地址
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    // 坐标
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    @objc dynamic var language: String?
    @objc dynamic var orderAbout: String?
    
    @objc dynamic var bannnerImgs: String?
    @objc dynamic var backgroundImgs: String?
    
    @objc dynamic var groupDetails: GroupInfo? //小组详情
    
    @objc dynamic var teamId: String? // 小组id
    
    @objc dynamic var income: String?
    @objc dynamic var expenditure: String?
    @objc dynamic var finishOrder: String?
    @objc dynamic var waitOrder: String?
        
    override static func primaryKey () -> String? {
    
        return "userId" // 主键-写入数据库后不可更改
    }
}


/**
 * ## 关于 realm 的一些 tips
 * String、NSDate 以及 NSData 类型的属性都可以添加可选值。Object 类型的属性必须设置为可选...  Double等类型必须有初始值,如上所示
 * List 和 RealmOptional 应当始终声明为 let
 * 带有主键的模型更新 realm.add(user, update: true)
 */
