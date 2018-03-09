//
//  RNCheckoutManager.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation

struct RNCheckoutManager {
    
    // 是否为空
    static func isEmpty(_ text: String?) -> Bool {
        
        guard let t = text, t != "" else{
            return false
        }
        
        return true
    }
    
    
    //是否全为数字
    static func isAllNumber(_ text: String?) -> Bool{
    
        guard isEmpty(text) else{
            
            return false
        }
        return true
    }
    
    
    // 是否为手机号
    static func isPhoneNumer(_ phone: String?) -> Bool {
        
        guard isEmpty(phone) else {
            
            return false
        }
        
        guard phone!.characters.count == 11 else {
            
            return false
        }
        
        let expression =  "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: phone!, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (phone! as NSString).length))
        return numberOfMatches != 0
    }
}


extension UITextField {
    
    /**
     校验数字的数字(例如钱金额),保留小数点几位----方法放在func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool 这个代理方法里
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     - parameter remian:            保留小数点后几位
     
     - returns: 输入符合要求true,反之false
     */
    func moneyFormatCheck(_ text: String, range: NSRange, replacementString: String, remian: Int) -> Bool {
        
        //限制输入框只能输入数字(最多两位小数)
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "^[0-9]*((\\.)[0-9]{0,\(remian)})?$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
        
    }
    
    /**
     限制输入框只能输入数字
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     
     - returns: 输入符合要求true,反之false
     */
    func digitFormatCheck(_ text: String, range: NSRange, replacementString: String) -> Bool{
        
        //限制输入框只能输入数字
        // let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: replacementString)
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "^[0-9]*$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
    }
    
    /**
     手机号码校验
     
     - parameter text:              需要处理的字符串
     - parameter range:             正在输入为的范围
     - parameter replacementString: 正在输入的字符
     
     - returns: 输入符合要求true,反之false
     */
    func phoneFormatCheck(_ text: String, range: NSRange, replacementString: String) -> Bool {
        
        let newString = (text as NSString).replacingCharacters(in: range, with: replacementString)
        let expression = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
    }

}
