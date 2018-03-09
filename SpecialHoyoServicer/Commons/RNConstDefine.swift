//
//  RNConstDefine.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/27.
//  Copyright © 2017年 roni. All rights reserved.
//


/// ## 全局常量

import Foundation
import UIKit

// 关于版本
let AppStoreAddress = "https://itunes.apple.com/cn/app/SpecialHoyoServicer/id1276976640?mt=8" // 应用商店地址

// 关于屏幕
let SCREEN_BOUNDS = UIScreen.main.bounds
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let NAVIBAR_HEIGHT: CGFloat = 64.0

// 关于颜色
let MAIN_THEME_COLOR = UIColor(red: 78/255.0, green: 172/255.0, blue: 220/255.0, alpha: 1.0) // 主色
   // UIColor(displayP3Red: 78/255.0, green: 172/255.0, blue: 220/255.0, alpha: 1.0)
  //UIColor(colorLiteralRed: 78/255.0, green: 172/255.0, blue: 220/255.0, alpha: 1.0) // 主色
let BACKGROUND_COLOR = UIColor(red: 73/255.0, green: 160/255.0, blue: 213/255.0, alpha: 1.0) //
let BUTTONCOLOR =  UIColor(red: 0/255.0, green: 172/255.0, blue: 235/255.0, alpha: 1.0) // 按钮背景
let BASEBACKGROUNDCOLOR = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0) // 基础背景

// 关于尺寸(屏幕以外)
let DRAWERWIDTH = UIScreen.main.bounds.width * 0.85 // 抽屉显示的宽度


// 关于订单类型
let ServiceItemDictionary: [String: (description: String, image: String, code: Int)] = ["123000001" : ("退机", "order_quit", 1),
                                                                                        "123000002" : ("换机", "order_exchangeG", 2),
                                                                                        "123000003" : ("移机", "order_move", 3),
                                                                                        "123000004" : ("充水", "order_water", 4),
                                                                                        "123000005" : ("整改", "order_do", 5),
                                                                                        "123000006" : ("安装", "order_install", 6),
                                                                                        "123000007" : ("维修维护", "order_fix", 7),
                                                                                        "123000008" : ("换芯", "order_exchangX", 8),
                                                                                        "123000009" : ("送货", "order_send", 9),
                                                                                        "123000010" : ("水质检测", "order_check", 10),
                                                                                        "123000011" : ("现场勘测", "order_survey", 11),
                                                                                        "123000012" : ("清洁消毒", "order_clean", 12),
                                                                                        "123000013" : ("拆机维护", "order_clean", 13), // 目前不存在
                                                                                        "123000014": ("充水+空调清洗", "order_condition", 14)]  // 14 = 7 界面与7相同

// 关于本地通知
let LOCATIONUPDATESUCCESS = "locationUpdateSuccess" // 位置更新成功
let LOCATIONUPDATEFAIL = "locationUpdateFail" // 位置更新成功
let GETORDER = "getOrder" // 抢单界面刷新通知
let NoServiceFinishOrderNotification = "noServicerFinishedOrderNotification" // 无服务完成订单通知
let TransferOrderSuccessNofitication = "transferOrderSuccessNofiticatio" // 转单成功
let FinishedOrderSuccessNotification = "finishedOrderSuccessNotification" // 结单成功
let GetOrderSuccessNotification = "GetOrderSuccessNotification" // 抢单成功
let SubscibeSuccessNotification = "SubscibeSuccessNotification" // 预约成功
let PaySuccessNotification = "PaySuccessNotification" // 支付成功
let CountDownTime = "CountDownTime" // 抢单倒计时
let ListCountNotification = "ListCountNotification" // 未处理已预约数目
let LoginSuccess = "LOGINSUCCESS" // 登陆成功

// 关于极光消息通知
//let JPushKey = "3643547ec0884d09cb26a136" // key
let JPushKey = "86e24d9d810e92ba441066b6"
let JPChannel = "App Store" // 统计平台
let JPBadge = "JPBadge" // 角标数
let MessageNotification = "MessageNotification" // 指派订单通知
let ScoreNotification = "ScoreNotification"
let  OrderPushNotification = "HomeOrderNotification" // 可抢订单
let OrderPushNotificationString = "NewMessageNotification" // 浩优推送普通消息
let MessageNotificationForPush = "MessageNotificationForPush" // 指派订单通知-- 再转发
let OrderPushNotificationForPush = "OrderPushNotificationForPush" // 可抢订单通知---再转发
let StringPushNotificationForPush = "StringPushNotificationForPush" // 浩优通知---再转发

// 个人信息更新
let PersonalInfoUpdate = "PersonalInfoUpdate" // 个人信息更新


// 关于 Udesk
let AppDomain = "ozner.udesk.cn" // domain
let AppKey = "febf3e9e46efbc6c18f9f29f15219400" // key
let AppId = "25e348d4a00f2f8a" // id

// 关于 bugly
let BuglyAppKey = "09812c49-c63e-4c35-819b-ba80694be4cf" // key
let BuglyAppId = "80f764a471" // app id

// 关于微信支付
let wxPayAppId = "wx309d0e7a55c365c9" //appid
let wxPayDesc = "浩优服务家支付" // 描述
let wxPayAppSecret = "f698b36e63eb9bd38a2fbd9fef7cf9f8" //
let wxPayKey = "pt0qjlep689anbrtuvkozazwg251d2qe" // 支付秘钥
let WEIXINPAYSUCCESS = "WEIXINPAYSUCCESS" // 支付成功
let WEIXINPAYFAIL = "WEIXINPAYFAIL" //支付失败

// UserDefaults 相关
let noConfirmTime = "noConfirmTime"  // 未确定时间的待定提示

// 关于协议
let RegisterProtocol = BASEURL + "/static/TeamAgreement.html"  // 注册协议
let TeamProtocol = BASEURL + "/static/TeamAgreement.html"  // 加入团队协议
let GroupProtocol = BASEURL + "/static/TeamAgreement.html"  // 加入小组协议

