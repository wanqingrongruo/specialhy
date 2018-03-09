//
//  UserIdentifier.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/1.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class UserIdentifier: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var userId: String?
    @objc dynamic var groupId: String?
    @objc dynamic var identifier: String?
    @objc dynamic public var scope: String?
    @objc dynamic public var state: String?
    
    override static func primaryKey () -> String? {
        
        return "userId" // 主键-写入数据库后不可更改
    }

}
