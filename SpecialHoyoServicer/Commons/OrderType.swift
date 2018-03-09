//
//  OrderType.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation


// 订单类型枚举  3-0-1-2 => 数据库中的标记
enum OrderType: String{
    case getOrder = "抢单" // 抢单 0
    case waitingDealing = "未处理" // 未处理 1
    case subscibe = "已预约" // 已预约 2
    case completed = "已完成" // 已完成 3
    case waitPay = "待支付" // 待支付 4
    case commented = "已评价" // 已评价 5
}


// 支付状态枚举
enum PayState: String{
    case paied = "128010020" // 已支付
    case noPay = "128000010" // 未支付
}

// 送装信息
enum SendWay: String{
    case sendTogether = "送装一体" // sendWay: 1
    case sendSeperator = "送装分离" // sendWay: 2
}

// 无服务
enum NoServiceCompleted: String{
    case noArrive = "130000015" // 无服务未上门完成
    case arrived = "130000013" // 无服务上门完成
    case checked = "130000012" // 无服务上门完成待审核
    case noCheck = "130000014" // 无服务未上门完成待审核
}

// 支付方式
enum PayWay: String {
    case Wx = "124010020"  // 微信支付
    case Pos = "124010001" // pos 机支付
    case Cash = "124020040" // 现金支付 -- 需要工程师通过微信把钱转到公司账户
    case NoPay = "124010040" // 不需要支付
    case Alipay = "124010010" // 支付宝
    case BankOnline = "124010030" // 网银
    case BzCard = "124040040" // 保障卡
    case Partner = "124030040" // 扣合作方账款
    case Scan = "124050040" // 扫码支付
    case HelpPay = "124060040" // 售后代付
}

// 推送类型
enum PushType {
    case string /// 普通
    case score  /// 积分
    case ordernotify  /// 指派订单
    case orderrob  /// 可抢订单
}

// 订单状态信息
enum OrderState: String {
    case waitingGet = "未被抢" // 未被抢
    case outDate = "过期" // 过期
    case waitingDeal = "未处理" // 未处理
    case subscibed = "已预约" // 已预约
    case completed = "已完成" // 已完成
    case waitingPay = "待支付" // 待支付
}

//  支付结果
enum PayResult: Int {
    case success = 0 // 支付成功
    case fail = 1 // 支付失败
    case appBack = 2 // 点击应用返回按钮返回
}

enum PayKind: Int {
    case urgentFee = 1_000_00 //加急费用
    case serviceFee = 2_000_00 //服务费用
    case rewardFee = 3_000_00 //打赏费用
    case engineerPayFee = 4_000_00 //工程师支付费用
    case otherFee = 5_000_00 //其他费用
    case carFee = 6_000_00 //行车距离费用
    case partFee = 7_000_00 //配件费用
    case waterFee = 8_000_00 //净水服务费用
    case cleanFee = 9_000_00 //清洁费用
}
