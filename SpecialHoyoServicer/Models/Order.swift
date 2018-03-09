//
//  Order.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/6.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class Order: Object {
    
    @objc dynamic var crmId: String?
    @objc dynamic var state: Int = -1  // 订单状态 - 用于从表中检索, 默认0:待处理, 1:已预约, 2:已完成,  3: 抢单 -- 可抢订单不保存到数据库, 应该不用该字段
    @objc dynamic var clientName: String?
    @objc dynamic var clientMobile: String? // 座机号
    @objc dynamic var userPhone: String? // 手机号
    @objc dynamic var serviceItem: String? // 订单类型
    
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var address: String?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    @objc dynamic var productInfo: ProductInfo?
    
    @objc dynamic var createTime: String?
    
    // 新接口没有的字段
    @objc dynamic var checkState: String?
   
    @objc dynamic var describle: String?
    @objc dynamic var modifyTime: String?
    @objc dynamic var appointmentTime: String?
    @objc dynamic var headimageurl: String?
    @objc dynamic var distance: String?
    @objc dynamic var devicetype: String? // 机器类型
    
    @objc dynamic var actionType: String? // 是否已处理过(0:否;1:是)
    
    @objc dynamic var countdownTime : Int    = 0
    @objc dynamic var countdownString: String?
    
    @objc dynamic var remark011: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    @objc dynamic var remark04: String?
    
    override static func primaryKey () -> String? {
        
        return "crmId" // 主键-写入数据库后不可更改
    }
    
    override static func ignoredProperties() -> [String] {
        return ["countdownTime" ,"countdownString"]
    }
    
}

// 重写 浅复制方法
// TO DO: 这样的复杂操作是否可以简化
extension Order: NSCopying{

    func copy(with zone: NSZone? = nil) -> Any {
        let o = Order()
        o.crmId = crmId
        o.state = state
        o.clientName = clientName
        o.clientMobile = clientMobile
        o.userPhone = userPhone
        o.serviceItem = serviceItem
        o.province = province
        o.city = city
        o.country = country
        o.address = address
        o.latitude = latitude
        o.longitude = longitude
        o.productInfo = productInfo
        o.createTime = createTime
        o.checkState = checkState
        o.describle = describle
        o.modifyTime = modifyTime
        o.appointmentTime = appointmentTime
        o.headimageurl = headimageurl
        o.distance = distance
        o.devicetype = devicetype
        o.actionType = actionType
        
        o.remark011 = remark011
        o.remark02 = remark02
        o.remark03 = remark03
        o.remark04 = remark04
        
        o.countdownTime = countdownTime
        o.countdownString = countdownString
                
        return o
    }
    
    func countDown() { // 倒计时
        
//        let realm = try! Realm()
//        realm.beginWrite()
        
        countdownTime = countdownTime - 1
        
        if countdownTime <= 0 {
            countdownString = "过期"
        }else{
            
            let timeString = Double(countdownTime)
            let minute = String(format: "%02d", Int(timeString / 60))
            let second = String(format: "%02d", Int(timeString.truncatingRemainder(dividingBy: 60)))
                
            countdownString = minute + ":" + second
           
        }
        
//        do {
//          try realm.commitWrite()
//        }catch{
//            print("倒计时修改错误")
//        }
    }
}
