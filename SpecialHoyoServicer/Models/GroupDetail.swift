//
//  GroupDetail.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/2.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class GroupDetail: Object {
    
    @objc dynamic var groupId: String?
    @objc dynamic var groupName: String?
    @objc dynamic var leaderId: String?
    @objc dynamic var leaderName: String?
    @objc dynamic var mobile: String?
    @objc dynamic var title: String?
    
    let serviceArea = List<ServiceAreaDetail>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
