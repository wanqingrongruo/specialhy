//
//  DoubleExtension.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2018/2/1.
//  Copyright © 2018年 roni. All rights reserved.
//

import Foundation

extension Double {
    
    // 元转分
    var cent: Double {
        get {
            return self * 100
        }
    }
    
    // 分转元
    var yuan: Double {
        get {
            return self / 100.0
        }
    }
}
