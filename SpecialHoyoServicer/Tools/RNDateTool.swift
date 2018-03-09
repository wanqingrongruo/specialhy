//
//  RNDateTool.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation

struct RNDateTool {
    
    /**
     判断是不是空或null
     */
    func MSRIsNilOrNull(_ object: Any?) -> Bool {
        return object == nil || object is NSNull
        
    }
    
    /**
     服务器时间戳转换成ios日期格式：例如："\Date(121300032190)\"->NSDate
     
     - parameter TimeStamp: "\Date(121300032190)\"
     
     - returns: NSDate
     */
    static func dateFromServiceTimeStamp(_ timeStamp: String) -> Date? {
        if timeStamp.characters.count < 10 {
            
            let date = Date()
//            let timeZone = TimeZone.current
//            let timeInterval = timeZone.secondsFromGMT(for: date)
//            let currentDate = date.addingTimeInterval(TimeInterval(timeInterval))

            return date
        }
        var tmpStr = timeStamp as NSString
        tmpStr = tmpStr.substring(from: 6) as NSString
        tmpStr = tmpStr.substring(to: tmpStr.length-2) as NSString
        let tmpTimeStr = TimeInterval(tmpStr.longLongValue/1000)
        
//        let date = Date()
//        let timeZone = TimeZone.current
//        let timeInterval = timeZone.secondsFromGMT(for: date)
        return Date(timeIntervalSince1970: tmpTimeStr) //.addingTimeInterval(TimeInterval(timeInterval))
    }
    /**
     服务器时间戳转换成ios时间戳：例如："\Date(121300032190)\"->121300032
     
     - parameter TimeStamp: "\Date(121300032190)\"
     Interval
     - returns: NSTimeInterval
     */
    static func TimeIntervalFromServiceTimeStamp(_ timeStamp:String)->TimeInterval? {
        if timeStamp.characters.count < 10
        {
            return Date().timeIntervalSince1970
        }
        var tmpStr = timeStamp as NSString
        
        tmpStr = tmpStr.substring(from: 6) as NSString
        tmpStr = tmpStr.substring(to: tmpStr.length-2) as NSString
        let tmpTimeStr = TimeInterval(tmpStr.intValue/1000)
        return tmpTimeStr
    }
    
    static func stringFromDate(_ date:Date,dateFormat:String)->String {
        let tmpDate = DateFormatter()
        tmpDate.dateFormat = dateFormat
        return tmpDate.string(from: date)
    }
    
    static func dateFromString(_ dateString:String,dateFormat:String)->Date {
        let tmpDate = DateFormatter()
        tmpDate.dateFormat = dateFormat
        return tmpDate.date(from: dateString)!
    }
    
    /**
     日期转化为星期
     
     - parameter date: iOS日期
     
     - returns: 星期时间
     */
    static func dayOfweek(_ date: Date) -> String {
        let interval = date.timeIntervalSince1970
        let days = Int(interval/86400)
        let day = (days - 3) % 7
        switch day {
        case 0:
            return "星期日"
        case 1:
            return "星期一"
        case 2:
            return "星期二"
        case 3:
            return "星期三"
        case 4:
            return "星期四"
        case 5:
            return "星期五"
        case 6:
            return "星期六"
        default :
            break
            
        }
        return " "
    }

}
