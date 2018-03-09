//
//  TeamMembers.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/1.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class TeamMembers: Object {
    
    @objc dynamic var nickname: String?
    @objc dynamic var headimageurl: String?
    @objc dynamic var mobile: String?
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var Scope: String?
    @objc dynamic var MemberState: String?
    @objc dynamic var GroupNumber:String?
    @objc dynamic var userid:String?
    @objc dynamic var title: String?
    
    let serviceArea = List<ServiceAreaDetail>()

    override static func primaryKey () -> String? {
        
        return "userid" // 主键-写入数据库后不可更改
    }

}
