//
//  BaseAPI.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/27.
//  Copyright © 2017年 roni. All rights reserved.
//


/// ## 关于网络的自定义常量字段

import Foundation


//MARK: - base
//let BASEURL = "http://wechat.hoyofuwu.com" // 正式 -- 使用
let BASEURL = "http://test.hoyofuwu.net" // 测试域名 -- 使用

// MARK: Key
let UserDefaultsUserTokenKey = "UserToken" // token
let UserIdKey = "UserIdKey"  // userid
let UserMobile = "UserMobile" // mobile


//MARK: - error code
let TokenFailCode = -10015  // token 失效错误码
let successCode = 0 // 大于0是算请求成功


// 接口 path

//MARK: - 用户相关
let APPLogin = "/FamilyAccount/AppLogin" // 登陆
let GetCurrentUserInfo = "/AppInterface/GetCurrentUserInfoV2" // 当前用户信息
let BingJpushId = "/Command/BingJgNotifyId" // 绑定极光推送 id
let NewVersion = "/command/NewVersion" // app版本更新
let UpdateUserInfo = "/FamilyAccount/UpdateUserInfo" // 个人信息更新
let APPRegister = "/AppInterface/AppUserRegisterV2" // 注册
let SendPhoneCode = "/Command/SendPhoneCode" // 获取验证码
let UploadAuthInfo = "/AppInterface/UploadRealnameAuthinfoV2" // 上传实名认证
let GetAuthInfo = "/AppInterface/GetCurrentRealNameInfoV2" // 获取实名认证信息
let ResetPassword = "/FamilyAccount/ResetPassword" // 修改密码
let Examination = "/AppInterface/GetExamination" // 我的考试
let ServiceTrain = "/AppInterface/CheckServiceTrain" // 直通车信息
let UpdateServiceTrain = "/AppInterface/UpdateServiceTrainMachine" // 更新直通车信息
let ServiceTrainRecord = "/AppInterface/GetServiceRecordByServiceTrainV2" //直通车记录


//MARK: - 订单相关
let GetOrderList = "/AppInterface/GetOrderListV2" // 订单列表
let GetOrderDetail = "/AppInterface/GetOrderDetailsV2" // 订单详情
let RecordCallMsg = "/AppInterface/RecordCallMsg" // 记录拨打电话时间
let SubmitHomeTime = "/AppInterface/SubmitHomeTimeV2" // 工程师预约改约
let NoServicerFinishedOrder = "/AppInterface/NoServiceFinshOrderV2" // 无服务完成订单
let FinishedOrder = "/AppInterface/FinshOrderV3" // 完成订单
let PartInfo = "/Command/GetPriceTableByCRM" // 配件信息
let TransferOrderByEng = "/AppInterface/TransferOrderByEng" // 转单
let RobOrder = "/AppInterface/RobOrderV2" // 抢单
let OrderShouldPayMoney = "/AppInterface/GetOrderShouldPayMoney" // 需要支付订单详情
let WeChatAppPrePay = "/AppInterface/WeChatAppPrePay" // 微信支付详情
let GetOrderState = "/AppInterface/GetOrderState" // 获取订单状态信息
let HomeTimeList = "/AppInterface/GetHomeTimeList" // 预约时间历史修改
let CanFinishedOrder = "/AppInterface/IsCanFinishOrder" // 判断工单是否允许结单
let ListCount = "/AppInterface/GetOrderListCount" // 未处理 and 已预约订单数目
let GetOrderMoney = "/AppInterface/GetOrderMoney" // 获取订单金额
let UploadPosImage = "/AppInterface/PosUpImg" // 上传凭条
let ScanToPayOrderMoney = "/AppInterface/PayOrderMoney" // 扫码支付
let FinshFillWaterOrder = "/AppInterface/FinshFillWaterOrder" // 充水单结单
let GetIsEnable = "/AppInterface/GetIsEnable" // 是否开启冲水服务

//MARK: - 团队相关
let MemberIdentifier = "/Group/GetNowAuthorityDetail" // 身份标识
let TeamList = "/Group/GetTeamList" // 团队的小组列表
let MemberList = "/Group/GetTeamMemberList" // 成员列表
let GroupDetails = "/Group/GetGroupDetails" // 团队详情
let TeamDetail = "/Group/GetTeamDetails" // 小组详情
let MemberDetail = "/Group/GetTeamMemberDetails" //成员详情
let JoinTeam = "/Group/JoinTeam" // 加入团队
let SignOutTeam = "/Group/SignOutTeam" // 移除成员
let CreateTeam = "/Group/CreateTeam" // 创建小组
let CreateGroup = "/Group/CreateGroup" // 创建团队
let QueryTeamList = "/Group/QueryTeamList" // 搜索团队列表

// 财务管理
let OwnMoney = "/AppInterface/GetOwenMoney" // 财务信息
let OwnMoneyDetail = "/AppInterface/GetOwenMoneyDetails" // 财务详情
let OwnBankCards = "/Command/GetOwenBindBlankCard" // 我的银行卡
let WithDraw = "/AppInterface/WithDraw" // 提现
let BindingBankCard = "/Command/BindNewBlankCardV2" // 绑定银行卡
let DeleteBankCard = "/Command/DelOwenBindBlankCard" // 删除银行卡
