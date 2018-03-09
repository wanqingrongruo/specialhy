//
//  RNColorExtension.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/29.
//  Copyright © 2017年 roni. All rights reserved.
//


/// ## UIcolor 扩展

import UIKit

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat(1.0) / CGFloat(255.0) * CGFloat(red),
            green: CGFloat(1.0) / CGFloat(255.0) * CGFloat(green),
            blue: CGFloat(1.0) / CGFloat(255.0) * CGFloat(blue),
            alpha: alpha)
    }
}
