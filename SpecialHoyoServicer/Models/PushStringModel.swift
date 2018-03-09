//
//  PushStringModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/27.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class PushStringModel: Object {
    
    @objc dynamic var msgId: String? // 消息 id
    @objc dynamic var orderId: String?
    @objc dynamic var sendUserId: String?
    @objc dynamic var recvUserId: String?
    @objc dynamic var sendNickName: String?
    @objc dynamic var messageType: String?
    @objc dynamic var sendImageUrl: String?
    @objc dynamic var messageCon: String?
    @objc dynamic var createTime: String?
    @objc dynamic var messageNum: String?
    @objc dynamic var serviceItem: String?
    @objc dynamic var other02: String?
    @objc dynamic var other03: String?
    
    override static func primaryKey () -> String? {
        
        return "msgId" // 主键-写入数据库后不可更改
    }

}
