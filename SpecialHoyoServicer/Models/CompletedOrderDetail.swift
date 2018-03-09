//
//  CompletedOrderDetail.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift

class CompletedOrderDetail: Object { // 已完成订单详情
    
    @objc dynamic var crmId: String? // crmid
    @objc dynamic var orderId: String? // 订单 id
    @objc dynamic var documentNo: String? // 浩泽 id
    @objc dynamic var state: Int = -1  // 订单状态 - 用于从表中检索, 默认0:待处理, 1:已预约, 2:已完成,  3: 抢单
    @objc dynamic var userName: String? // 客户姓名(为公司时即公司名)
    @objc dynamic var clientName: String? // 联系人名称
    @objc dynamic var clientMobile: String? // 座机号
    @objc dynamic var userPhone: String? // 手机号
    @objc dynamic var serviceItem: String? // 订单类型
    
    @objc dynamic var createTime: String?
    
    @objc dynamic var province: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var address: String?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    @objc dynamic var aimAddress: String? // 目的地址
    @objc dynamic var comment: String? // 评价
    
    @objc dynamic var homeTime: String? // 可为空
    @objc dynamic var decribe: String?
    @objc dynamic var areaCode: String? // 区域代码
    @objc dynamic var payTitle: String? // 费用名称
    @objc dynamic var money: String? // 实际支付金额
    @objc dynamic var payState: String? // 支付状态
    @objc dynamic var sendWay: String? // 送货信息, 1为送装一体，2为送装分离
    @objc dynamic var expressCode: String? // 快递单号
    
    @objc dynamic var productInfo: ProductInfo?
    
    
    @objc dynamic var machineType: String? // 设备管理号(机器 ID)
    @objc dynamic var machineCode: String? // IMEI
    @objc dynamic var ICCID: String? // ICCID
    @objc dynamic var macAddress: String? //mac
    @objc dynamic var serviceCode: String? // 直通车编号
    @objc dynamic var installConfirmNum: String? // 安装确认单号
    @objc dynamic var shuiya: String? // 水压
    @objc dynamic var isOpenBox: String? // 开箱状态
    @objc dynamic var residualSZ: String? // 剩余水值
    @objc dynamic var SZUnit: String? // 水值单位
    @objc dynamic var y_TDS: String? // 源水 tds
    @objc dynamic var z_TDS: String? // 活水 tds
    @objc dynamic var payWay: String? //支付方式
    @objc dynamic var serviceReason: String? // 服务原因
    @objc dynamic var problemComponent: String? // 问题备注
    @objc dynamic var distance: String? // 结单距离
    @objc dynamic var remark: String? // 备注描述
    
    var solutionInfo = List<SolutionModel>()
    var products = List<CompletedPartModel>()
    var moneyList = List<MoneyModel>()
    var images = List<ImageModel>()
    
    // 移机单
    @objc dynamic var yjCompany: String?
    @objc dynamic var yjLinker: String?
    @objc dynamic var yjPhone: String?
    @objc dynamic var yjMobile: String?
    
    @objc dynamic var payMoney: Double = 0.0 // 支付金额
    
    @objc dynamic var documentNumber: String?  // 开户单号
    @objc dynamic var serviceType: String? // 保修类型
    
    @objc dynamic var remark01: String?
    @objc dynamic var remark02: String?
    @objc dynamic var remark03: String?
    
    override static func primaryKey () -> String? {
        
        return "crmId" // 主键-写入数据库后不可更改
    }

    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

extension CompletedOrderDetail: NSCopying{
    
    func copy(with zone: NSZone? = nil) -> Any {
        let o = CompletedOrderDetail()
        o.crmId = crmId
        o.orderId = orderId
        o.documentNo = documentNo
        o.state = state
        o.userName = userName
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
        o.homeTime = homeTime
        o.decribe = decribe
        o.areaCode = areaCode
        o.payTitle = payTitle
        o.money = money
        o.payState = payState
        o.sendWay = sendWay
        o.expressCode = expressCode
        o.productInfo = productInfo
        
        o.machineType = machineType
        o.machineCode = machineCode
        o.ICCID = ICCID
        o.macAddress = macAddress
        o.serviceCode = serviceCode
        o.installConfirmNum = installConfirmNum
        o.shuiya = shuiya
        o.isOpenBox = isOpenBox
        o.residualSZ = residualSZ
        o.SZUnit = SZUnit
        o.y_TDS = y_TDS
        o.z_TDS = z_TDS
        o.payWay = payWay
        o.serviceReason = serviceReason
        o.problemComponent = problemComponent
        o.distance = distance
        o.solutionInfo = solutionInfo
        o.products = products
        o.moneyList = moneyList
        o.images = images
        o.remark01 = remark01
        o.remark02 = remark02
        o.remark03 = remark03
        
        o.aimAddress = aimAddress
        o.comment = comment
        
        // 移机单
        o.yjCompany = yjCompany
        o.yjLinker = yjLinker
        o.yjPhone = yjPhone
        o.yjMobile = yjMobile
        
        o.payMoney = payMoney
        
        o.documentNumber = documentNumber
        o.serviceType = serviceType
        
        return o
    }
}

