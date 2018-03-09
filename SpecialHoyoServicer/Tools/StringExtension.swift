//
//  StringExtension.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation

extension String {
    
    func sizeWithText(text: NSString, font: UIFont, size: CGSize) -> CGRect {
        let attributes = [NSAttributedStringKey.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect;
    }
    
    func sizeWithAttributes(text: NSString, with dic: [NSAttributedStringKey: Any], and size: CGSize) -> CGRect{
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = text.boundingRect(with: size, options: option, attributes: dic, context: nil)
        return rect;
    }
    
    // 数字加字母
    func isLettersOrNumbers() -> Bool {
        
        if self.count <= 0 {
            return false
        }
        
        let expression = "^[A-Za-z0-9-]+$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: self, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.count))
        return numberOfMatches != 0
    }
    
    // 非负小数
    func isDecimal() -> Bool {
        if self.count <= 0 {
            return false
        }
        
        let expression = "^\\d+(.\\d+)?$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: self, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.count))
        return numberOfMatches != 0
    }
    
    // 非负整数
    func isUnInterger() -> Bool {
        if self.count <= 0 {
            return false
        }
        
        let expression = "^\\d+$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: self, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.count))
        return numberOfMatches != 0
    }
}
