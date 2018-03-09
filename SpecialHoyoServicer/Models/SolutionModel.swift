//
//  SolutionModel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class SolutionModel: Object {
    
    @objc dynamic var reason: String?
    @objc dynamic var solution: String?
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

extension SolutionModel: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let s = SolutionModel()
        s.reason = reason
        s.solution = solution
        s.remark01 = remark01
        s.remark02 = remark02
        s.remark03 = remark03
        
        return s
    }
}
