//
//  OrderServicer.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

// 有关 订单 的网络请求

struct OrderServicer {
    
    
    /// 获取订单列表
    ///
    /// - Parameters:
    ///   - parameter: 参数 - 不同类型订单的入参不同 ["action": "xxxx"] => 抢单: kqaction, 未处理:  "yqaction",  已预约: , 已完成:
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func orderList(_ parameter: [String: Any], successClourue: (([Order]) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        
        let _ = RNNetworkManager.shared.post(GetOrderList, parameters: parameter, successClourue: { (result) in
            // -- 请求成功 且是 下拉刷新 => 先从数据库中移除对应类型的 数据
            if parameter["pageindex"] as! Int == 1 {
                
                // 移除数据库数据
                let type = self.getOrderType(action: parameter["actiontype"] as! String)
                if (type == 0){ // 过滤抢单界面 || (type == 2)
                    
                }else{
                    
                    realmDeleteObjects(Model: Order.self, condition: { (results) -> Results<Order>? in
                        return results.filter("state = \(type)")
                    })
                }
            }
            
            
            let data = result["data"].array
            if let items = data {
                
                var array = [Order]()
                for item in items {
                    
                    let order = Order()
                    
                    order.state = self.getOrderType(action: parameter["actiontype"] as! String) // 在数据库中标记状态 => 便于以后查找 和删除
                    
                    order.crmId = item["CRMID"].stringValue
                    order.serviceItem = item["ServiceItem"].stringValue
                    order.clientName = item["ClientName"].stringValue
                    order.clientMobile = item["ClientMobile"].stringValue
                    order.userPhone = item["UserPhone"].stringValue
                    order.createTime = item["CreateTime"].stringValue
                    
                    let time = item["HomeTime"].stringValue
                    let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
                    let dataFormat = DateFormatter()
                    dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
                    
                    if let t = timeStamp {
                        let dateString = dataFormat.string(from: t)
                        order.appointmentTime = dateString
                    }else{
                        order.appointmentTime = time
                    }
                    
                    order.province = item["Province"].stringValue
                    order.city = item["City"].stringValue
                    order.country = item["Country"].stringValue
                    order.address = item["Address"].stringValue
                    order.describle = item["Describe"].stringValue
                    order.latitude = item["Lat"].doubleValue
                    order.longitude = item["Lng"].doubleValue
                    order.actionType = item["ActionType"].stringValue
                    
                    let productInfo = item["productinfo"]
                    order.productInfo = ProductInfo()
                    order.productInfo?.companyID = productInfo["CompanyID"].stringValue
                    order.productInfo?.companyName = productInfo["CompanyName"].stringValue
                    order.productInfo?.productNumber = productInfo["ProductNumber"].stringValue
                    order.productInfo?.productModel = productInfo["ProductModel"].stringValue
                    order.productInfo?.productName = productInfo["ProductName"].stringValue
                    order.productInfo?.image = productInfo["Image"].stringValue
                    order.productInfo?.productKind = productInfo["ProductKind"].stringValue
                    
                    
                    //                    order.checkState = item["CRMCheck"].stringValue
                    //                    order.productName = item["productinfo"]["ProductName"].stringValue
                    //                    order.productModel = item["productinfo"]["ProductModel"].stringValue
                    
                    //                    order.modifyTime = item["ModifyTime"].stringValue
                    //                    order.distance = item["distance"].stringValue
                    //                    order.devicetype = item["DeviceType"].stringValue
                    
                    
                    //                    let homeTime = item["hometime"]
                    //                    if homeTime.stringValue == "" {
                    //                        order.appointmentTime = item["ServiceTime"].stringValue
                    //
                    //                    }else{
                    //                        order.appointmentTime = item["hometime"].stringValue
                    //                    }
                    //
                    //                    let url = item["user"]["headimageurl"].stringValue
                    //
                    //                    if url == ""{
                    //                        order.headimageurl = url
                    //                    }else{
                    //
                    //                        if url.contains("http") {
                    //
                    //                            order.headimageurl = url
                    //                        }else{
                    //
                    //                            order.headimageurl = BASEURL + url
                    //                        }
                    //                    }
                    
                    let type00 = self.getOrderType(action: parameter["actiontype"] as! String)
                    if (type00 == 0){ // 过滤抢单界面 || (type == 2)
                        
                        if let time =  order.createTime {
                            let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
                            
                            if let timeSt = timeStamp  {
                                
                                let date = Date()
                                //                                let timeZone = TimeZone.current
                                //                                let timeInterval = timeZone.secondsFromGMT(for: date)
                                //                                let currentDate = date.addingTimeInterval(TimeInterval(timeInterval))
                                
                                let timeInter = date.timeIntervalSince(timeSt)
                                var leftTime:Double = 3600 //3600 // 60分钟过期
                                if timeInter > 0{
                                    leftTime = leftTime - timeInter
                                }
                                
                                order.countdownTime = Int(leftTime)
                                
                            }
                        }
                        
                    }
                    
                    array.append(order)
                }
                
                let type = self.getOrderType(action: parameter["actiontype"] as! String)
                let keyword = parameter["Keyword"]
                if (type == 0 || keyword != nil){ // 过滤抢单界面 || (type == 2) -- 过滤搜索界面
                    
                }else{
                    
                    realmWirteModels(models: array)
                }
                
                successClourue?(array.map({ (model) -> Order in
                    return model.copy() as! Order
                }))
                
            }else{
                let array = [Order]()
                successClourue?(array)
            }
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 订单详情 -- 抢单-待处理-已预约
    ///
    /// - Parameters:
    ///   - parameter: 入参 crmId
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func orderDetail(_ parameter: [String: Any], successClourue: ((OrderDetail) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        let _ = RNNetworkManager.shared.post(GetOrderDetail, parameters: parameter, isToken: true, successClourue: { (result) in
            
            let data = result["data"]["OrderInfo"]
            
            let orderDetail = OrderDetail()
            
            orderDetail.crmId = data["CRMID"].stringValue
            orderDetail.orderId = data["OrderId"].stringValue
            orderDetail.documentNo = data["DocumentNo"].stringValue
            orderDetail.serviceItem = data["ServiceItem"].stringValue
            orderDetail.userName = data["UserName"].stringValue
            orderDetail.clientName = data["ClientName"].stringValue
            orderDetail.clientMobile = data["ClientMobile"].stringValue
            orderDetail.userPhone = data["UserPhone"].stringValue
            orderDetail.createTime = data["CreateTime"].stringValue
            orderDetail.province = data["Province"].stringValue
            orderDetail.city = data["City"].stringValue
            orderDetail.country = data["Country"].stringValue
            orderDetail.address = data["Address"].stringValue
            orderDetail.latitude = data["Lat"].doubleValue
            orderDetail.longitude = data["Lng"].doubleValue
            
            orderDetail.aimAddress = data["DesAddress"].stringValue // 目的地址
            
            orderDetail.homeTime = data["HomeTime"].stringValue
            orderDetail.areaCode = data["AreaCode"].stringValue
            orderDetail.decribe = data["Describe"].stringValue
            orderDetail.payTitle = data["PayTitle"].stringValue
            orderDetail.payState = data["PayState"].stringValue
            orderDetail.money = data["Money"].stringValue
            orderDetail.sendWay = data["SendWay"].stringValue
            
            orderDetail.expressCode = data["InventoryInfo"].stringValue
            //            let inventoryInfo = data["InventoryInfo"]
            //            let code = inventoryInfo["code"].intValue
            //            if code == 1{
            //
            //                let trades = inventoryInfo["tradeStatuss"].array
            //                if let ts = trades, let lastItem = ts.last{
            //                    orderDetail.expressCode = lastItem["trackNumber"].stringValue // 快递单号,后续可能不同
            //                }
            //            }else{
            //                orderDetail.expressCode = "暂无"
            //            }
            
            // 移机单
            orderDetail.yjCompany = data["NewName"].stringValue
            orderDetail.yjLinker = data["NewContact"].stringValue
            orderDetail.yjMobile = data["NewMobile"].stringValue
            orderDetail.yjPhone = data["NewTel"].stringValue
            
            let payMoney = Double(data["PayMoney"].intValue / 100) // 支付金额
            orderDetail.payMoney = payMoney
           // orderDetail.payWay = data["PayWay"].stringValue
            
            orderDetail.documentNumber = data["DocumentNumber"].stringValue
            orderDetail.serviceType = data["ServiceType"].stringValue
            
            let productInfo = data["productinfo"]
            orderDetail.productInfo = ProductInfo()
            orderDetail.productInfo?.companyID = productInfo["CompanyID"].stringValue
            orderDetail.productInfo?.companyName = productInfo["CompanyName"].stringValue
            orderDetail.productInfo?.productNumber = productInfo["ProductNumber"].stringValue
            orderDetail.productInfo?.productModel = productInfo["ProductModel"].stringValue
            orderDetail.productInfo?.productName = productInfo["ProductName"].stringValue
            orderDetail.productInfo?.image = productInfo["Image"].stringValue
            orderDetail.productInfo?.productKind = productInfo["ProductKind"].stringValue
            
            
            realmWirte(model: orderDetail)
            
            
            successClourue?(orderDetail.copy() as! OrderDetail)
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 已完成(待支付)详情
    ///
    /// - Parameters:
    ///   - parameter: 入参 crmId
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func orderDetailForCompletedOreder(_ parameter: [String: Any], successClourue: ((CompletedOrderDetail) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        let _ = RNNetworkManager.shared.post(GetOrderDetail, parameters: parameter, isToken: true, successClourue: { (result) in
            
            let data = result["data"]["OrderInfo"]
            let orderDetail = CompletedOrderDetail()
            
            orderDetail.crmId = data["CRMID"].stringValue
            orderDetail.orderId = data["OrderId"].stringValue
            orderDetail.documentNo = data["DocumentNo"].stringValue
            orderDetail.serviceItem = data["ServiceItem"].stringValue
            orderDetail.userName = data["UserName"].stringValue
            orderDetail.clientName = data["ClientName"].stringValue
            orderDetail.clientMobile = data["ClientMobile"].stringValue
            orderDetail.userPhone = data["UserPhone"].stringValue
            orderDetail.createTime = data["CreateTime"].stringValue
            orderDetail.province = data["Province"].stringValue
            orderDetail.city = data["City"].stringValue
            orderDetail.country = data["Country"].stringValue
            orderDetail.address = data["Address"].stringValue
            orderDetail.latitude = data["Lat"].doubleValue
            orderDetail.longitude = data["Lng"].doubleValue
            
            orderDetail.homeTime = data["HomeTime"].stringValue
            orderDetail.areaCode = data["AreaCode"].stringValue
            orderDetail.decribe = data["Describe"].stringValue
            orderDetail.payTitle = data["PayTitle"].stringValue
            orderDetail.payState = data["PayState"].stringValue
            orderDetail.money = data["Money"].stringValue
            orderDetail.sendWay = data["SendWay"].stringValue
            
            orderDetail.aimAddress = data["DesAddress"].stringValue // 目的地址
            
            orderDetail.expressCode = data["InventoryInfo"].stringValue
            //            let inventoryInfo = data["InventoryInfo"]
            //            let code = inventoryInfo["code"].intValue
            //            if code == 1{
            //
            //                let trades = inventoryInfo["tradeStatuss"].array
            //                if let ts = trades, let lastItem = ts.last{
            //                    orderDetail.expressCode = lastItem["trackNumber"].stringValue // 快递单号,后续可能不同
            //                }
            //            }else{
            //                orderDetail.expressCode = "暂无"
            //            }
            
            // 移机单
            orderDetail.yjCompany = data["NewName"].stringValue
            orderDetail.yjLinker = data["NewContact"].stringValue
            orderDetail.yjMobile = data["NewMobile"].stringValue
            orderDetail.yjPhone = data["NewTel"].stringValue
            
            let payMoney = Double(data["PayMoney"].doubleValue.yuan) // 支付金额
            orderDetail.payMoney = payMoney
          //  orderDetail.payWay = data["PayWay"].stringValue
            
            orderDetail.documentNumber = data["DocumentNumber"].stringValue
            orderDetail.serviceType = data["ServiceType"].stringValue
            
            let productInfo = data["productinfo"]
            orderDetail.productInfo = ProductInfo()
            orderDetail.productInfo?.companyID = productInfo["CompanyID"].stringValue
            orderDetail.productInfo?.companyName = productInfo["CompanyName"].stringValue
            orderDetail.productInfo?.productNumber = productInfo["ProductNumber"].stringValue
            orderDetail.productInfo?.productModel = productInfo["ProductModel"].stringValue
            orderDetail.productInfo?.productName = productInfo["ProductName"].stringValue
            orderDetail.productInfo?.image = productInfo["Image"].stringValue
            orderDetail.productInfo?.productKind = productInfo["ProductKind"].stringValue
            
            
            
            let finishInfo = result["data"]["FinishInfo"]
            
            //            if finishInfo == .null { // 判空
            //                realmWirte(model: orderDetail)
            //                successClourue?(orderDetail)
            //                return
            //            }
            orderDetail.machineType = finishInfo["MachineType"].stringValue
            orderDetail.machineCode = finishInfo["MachineCode"].stringValue
            orderDetail.ICCID = finishInfo["ICCID"].stringValue
            orderDetail.macAddress = finishInfo["MacAddress"].stringValue
            orderDetail.serviceCode = finishInfo["ServiceCode"].stringValue
            orderDetail.installConfirmNum = finishInfo["InstallConfirmNum"].stringValue
            orderDetail.shuiya = finishInfo["shuiya"].stringValue
            orderDetail.isOpenBox = finishInfo["IsOpenBox"].stringValue
            orderDetail.residualSZ = finishInfo["ResidualSZ"].stringValue
            orderDetail.SZUnit = finishInfo["SZunit"].stringValue
            orderDetail.y_TDS = finishInfo["Y_TDS"].stringValue
            orderDetail.z_TDS = finishInfo["Z_TDS"].stringValue
            orderDetail.payWay = finishInfo["PayWay"].stringValue
            orderDetail.serviceReason = finishInfo["ServiceReasons"].stringValue
            orderDetail.problemComponent = finishInfo["ProblemComponent"].stringValue
            orderDetail.distance = finishInfo["Distance"].stringValue
            orderDetail.remark = finishInfo["Remark"].stringValue // 备注描述 -- 不知道
            orderDetail.comment = finishInfo["UserEvaluation"].stringValue // 评价
            
            let soluInfo = finishInfo["SolutionInfo"].array
            if let ss = soluInfo {
                for item in ss{
                    let model = SolutionModel()
                    model.reason = item["Reason"].stringValue
                    model.solution = item["Solution"].stringValue
                    
                    orderDetail.solutionInfo.append(model)
                }
            }
            let products = finishInfo["products"].array
            if let ps = products {
                for item in ps{
                    let model = CompletedPartModel()
                    model.productId = item["ProductID"].stringValue
                    model.productName = item["CompanyName"].stringValue
                    model.productPrice = item["Price"].stringValue
                    model.productAmount = item["ProductNum"].intValue
                    
                    orderDetail.products.append(model)
                }
            }
            let moneyList = finishInfo["moneylist"].array
            if let ms = moneyList {
                for item in ms{
                    let model = MoneyModel()
                    model.title = item["title"].stringValue
                    model.money = item["money"].doubleValue
                    model.remark = item["remark"].stringValue
                    
                    orderDetail.moneyList.append(model)
                }
            }
            let images = finishInfo["Images"].array
            if let ims = images {
                for item in ims{
                    let model = ImageModel()
                    model.imageId = item["Id"].stringValue
                    model.imageName = item["ImageName"].stringValue
                    
                    let tmp = item["ImageUrl"].stringValue
                    var headImageUrl = tmp
                    if headImageUrl.contains("http") == false {
                        headImageUrl = BASEURL + headImageUrl
                    }
                    model.imageUrl = headImageUrl
                    
                    model.imageType = item["Type"].stringValue
                    model.imageAction = item["Action"].stringValue
                    model.userId = item["Userid"].stringValue
                    model.orderId = item["Orderid"].stringValue
                    model.createTime = item["CreateTime"].stringValue
                    orderDetail.images.append(model)
                }
                
            }
            
            realmWirte(model: orderDetail)
            successClourue?(orderDetail.copy() as! CompletedOrderDetail)
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    
    /// 记录工程师拨打客户电话时间
    ///
    /// - Parameters:
    ///   - parameter: 参数, CallTime,CRMID, OrderId(可选)
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func recordSubscribeInfo(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(RecordCallMsg, parameters: parameter, isToken: true, successClourue: { (_) in
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 工程师改约
    ///
    /// - Parameters:
    ///   - parameter: 操作类型actiontype说明: 预约操作	Appointment	售后联系客户，确定上门时间以及送装方式后点击工单预约按钮触发，提交成功后工单即预约成功; 未确定时间备注操作	NoTimeAppointment 售后联系客户未确定上门时间，备注联系信息，供以后查看，提交成功后工单仍为待处理状态; 改约操作	ChangeTimeAppointment	售后因各种原因，需要更改上门时间时调用
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func changeAppointment(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(SubmitHomeTime, parameters: parameter, isToken: true, successClourue: { (result) in
            
            //  print(result["state"].stringValue)
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 无服务完成
    ///
    /// - Parameters:
    ///   - parameter: ["orderid":orderid, "service":service]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func noServicerFinishedOrder(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(NoServicerFinishedOrder, parameters: parameter, successClourue: { (data) in
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 完成订单
    ///
    /// - Parameters:
    ///   - parameter: 参数列表
    ///   - imageDatas: 图片数据
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func finishedOrder(_ parameter: [String: Any], imageDatas: [UIImage], successClourue: ((Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.upload(FinishedOrder, parameters: parameter, multipartFormData: { (multipartData) in
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let name = formatter.string(from: Date())
            let fileName = NSString(format: "%@", name)
            
            for (index, item) in imageDatas.enumerated() {
                let imageData = UIImageJPEGRepresentation(item, 0.1)
                
                if let data = imageData{
                    multipartData.append(data, withName:String(format: "%@%d", fileName,index), fileName: "updataImage", mimeType: "image/png")
                }
                
            }
            for (key, value) in parameter{
                
                if let v = (value as? String), let r = v.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    multipartData.append(r, withName: key)
                    
                }
            }
            
            
        }, progressClousure: { (pregress) in
            //
        }, successClourue: { (result) in
            let state = result["state"].intValue
            successClourue?(state)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取配件信息
    ///
    /// - Parameters:
    ///   - parameter: 参数列表 ["Pageindex":index ,"Pagesize" :pagesize, "search": searchString ?? ""]
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func getPartInfo(_ parameter: [String: Any], successClourue: (([PartModel]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(PartInfo, parameters: parameter, successClourue: { (result) in
            
            // -- 请求成功 且是 下拉刷新 => 先从数据库中移除对应类型的 数据
            if parameter["Pageindex"] as! Int == 1 {
                
                realmDeleteObjectsWithoutCondition(Model: PartModel.self)
            }
            
            
            let data = result["data"].array
            var array = [PartModel]()
            if let items = data {
                
                for item in items {
                    let model = PartModel()
                    model.productId = item["ID"].stringValue
                    model.productName = item["Name"].stringValue
                    model.productPrice = item["PJPrice"].stringValue
                    model.productAmount = 0 // 默认为0
                    model.productModel = item["PJCode"].stringValue // 自动未确定
                    let imageUrl = item["imageId"].stringValue
                    if (imageUrl != "") && (imageUrl.contains("http") == true) {
                        model.productImageUrl = imageUrl
                    }else{
                        let url = BASEURL + imageUrl
                        model.productImageUrl = url
                    }
                    
                    array.append(model)
                }
            }
            
            realmWirteModels(models: array)
            
            successClourue?(array.map({ (model) -> PartModel in
                return model.copy() as! PartModel
            }))
            
        })  { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 转单
    ///
    /// - Parameters:
    ///   - parameter: CRMID:需要转派的工单CRM编号; ReceiveEngID: 接收工单的工程师ID
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func transferOrder(_ parameter: [String: Any], successClourue: ((Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(TransferOrderByEng, parameters: parameter, successClourue: { (result) in
            let state = result["state"].intValue
            successClourue?(state)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 抢单
    ///
    /// - Parameters:
    ///   - parameter: ["orderid":orderid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func robOrder(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(RobOrder, parameters: parameter, successClourue: { (_) in
            successClourue?()
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取订单待支付详情
    ///
    /// - Parameters:
    ///   - parameter: ["orderid":orderid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOrderPayDetails(_ parameter: [String: Any], successClourue: ((RNPayOrderModel, Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(OrderShouldPayMoney, parameters: parameter, successClourue: { (result) in
            
            
            let orderPayModel = RNPayOrderModel()
            orderPayModel.payInfos = [RNPAYDetailModel]()
            
            orderPayModel.orderId = result["Orderid"].stringValue
            orderPayModel.orderName = result["PayTitle"].stringValue
            orderPayModel.payMoney = result["PayMoney"].floatValue
            
            let isNeedPay = result["state"].intValue
            
            let json = result["data"].array
            
            var dataSource = [RNPAYDetailModel]()
            
            if json != nil {
                
                for item in json!{
                    let model = RNPAYDetailModel()
                    
                    model.id = item["id"].stringValue
                    model.orderId = item["OrderId"].stringValue
                    model.PayTitle = item["PayTitle"].stringValue
                    model.UserId = item["UserId"].stringValue
                    model.Money = item["Money"].floatValue
                    model.OriMoney = item["OriMoney"].floatValue
                    model.PayState = item["PayState"].stringValue
                    model.Payway = item["Payway"].stringValue
                    
                    dataSource.append(model)
                }
                
                
            }
            
            orderPayModel.payInfos = dataSource
            
            successClourue?(orderPayModel,isNeedPay)
            
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取微信支付所需要的字段信息
    ///
    /// - Parameters:
    ///   - parameter: ["orderid":orderid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getWxPayInfos(_ parameter: [String: Any], successClourue: ((RNWeixinModel) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(WeChatAppPrePay, parameters: parameter, successClourue: { (result) in
            
            let item = result["data"]
            let weixinModel = RNWeixinModel()
            weixinModel.queryid = item["queryid"].stringValue
            weixinModel.noncestr = item["noncestr"].stringValue
            weixinModel.appid = item["appid"].stringValue
            weixinModel.sign = item["sign"].stringValue
            weixinModel.partnerid = item["partnerid"].stringValue
            weixinModel.timestamp = item["timestamp"].stringValue
            weixinModel.prepayid = item["prepayid"].stringValue
            weixinModel.pkg = item["package"].stringValue
            
            
            successClourue?(weixinModel)
            
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
        
    }
    
    
    /// 获取订单状态
    ///
    /// - Parameters:
    ///   - parameter: ["CRMID":orderid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOrderState(_ parameter: [String: Any], successClourue: ((String) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(GetOrderState, parameters: parameter, successClourue: { (result) in
            
            let msg = result["msg"].stringValue
            
            successClourue?(msg)
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取预约时间修改列表
    ///
    /// - Parameters:
    ///   - parameter: ["orderid":orderid]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getHomeTimeList(_ parameter: [String: Any], successClourue: (([HistoryModel]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.post(HomeTimeList, parameters: parameter, successClourue: { (result) in
            
            let data = result["data"].array
            var array = [HistoryModel]()
            if let items = data {
                for item in items {
                    let model = HistoryModel()
                    model.id = item["id"].stringValue
                    model.homeTime = item["hometime"].stringValue
                    model.creatTime = item["createtime"].stringValue
                    model.orderId = item["orderid"].stringValue
                    model.remark = item["remark"].stringValue
                    model.userId = item["userid"].stringValue
                    model.way = item["way"].stringValue
                    array.append(model)
                }
            }
            
            realmWirteModels(models: array)
            
            let temp = array.map({ (model) -> HistoryModel in
                return model.copy() as! HistoryModel
            })
            successClourue?(temp)
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 判断订单是否可以结单
    ///判断说明
    /// 仅安装和换机单有该限制
    ///仅浩泽来源工单有该限制
    ///仅需要发货的工单有该限制，渠道平台判断
    ///仅出库查询功能开启时有该限制
    /// - Parameters:
    ///   - parameter: CRMID
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func canFinishedOrder(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.post(CanFinishedOrder, parameters: parameter, successClourue: { (_) in
            successClourue?()
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取已预约未处理订单数目
    ///
    /// - Parameters:
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOrderListCount(successClourue: ((ListCountModel) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        RNNetworkManager.shared.post(ListCount, parameters: nil, successClourue: { (result) in
            let data = result["data"]
            let model = ListCountModel()
            model.untreated = data["Untreated"].intValue
            model.reserved = data["Reserved"].intValue
            successClourue?(model)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取订单金额
    ///
    /// - Parameters:
    ///   - parameter: [CRMID: ""]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOrderMoney(_ parameter: [String: Any], successClourue: ((AllFee) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.post(GetOrderMoney, parameters: parameter, successClourue: { (result) in
            let data = result["data"]
            var allfee = AllFee()
            allfee.crmId = data["CRMID"].stringValue
            allfee.payState = data["PayState"].stringValue
            allfee.payMode = data["PayMode"].stringValue
            var detailFees = [DetailFee]()
            if let list = data["moneylist"].array {
                for item in list {
                    
                    //                    let title = item["title"].stringValue
                    //                    if title == "配件服务费" {
                    //                        continue
                    //                    }
                    var model = DetailFee()
                    model.title = item["title"].stringValue
                    model.url = item["imgurl"].stringValue
                    model.money = Double(item["money"].doubleValue.yuan)
                    model.remark = item["remark"].stringValue
                    model.payKind = item["paykind"].stringValue
                    model.validity = item["validity"].stringValue
                    model.isPaid = item["paystate"].stringValue
                    detailFees.append(model)
                }
                allfee.deatilFees = detailFees
            }
            successClourue?(allfee)
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    /// 上传 pos 刷卡凭票
    ///
    /// - Parameters:
    ///   - parameter: [CRMID: "", PayModel: ""]
    ///   - imageData: <#imageData description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func uploadPosImage(_ parameter: [String: Any], imageData: UIImage, successClourue: ((Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
       RNNetworkManager.shared.upload(UploadPosImage, parameters: parameter, multipartFormData: { (multipartData) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let name = formatter.string(from: Date())
            let fileName = NSString(format: "%@", name)
            let imageData = UIImageJPEGRepresentation(imageData, 0.1)
            if let data = imageData{
                multipartData.append(data, withName:String(format: "%@", fileName), fileName: "posImage", mimeType: "image/png")
            }
            
            for (key, value) in parameter{
                if let v = (value as? String), let r = v.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    multipartData.append(r, withName: key)
                }
            }
        }, progressClousure: { (pregress) in
            //
        }, successClourue: { (result) in
            let state = result["state"].intValue
            successClourue?(state)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 扫码支付
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func scanToPayOrderMoney(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.post(ScanToPayOrderMoney, parameters: parameter, successClourue: { (result) in
            successClourue?()
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    /// 冲水-----完成订单
    ///
    /// - Parameters:
    ///   - parameter: 参数列表
    ///   - imageDatas: 图片数据
    ///   - successClourue: 成功回调
    ///   - failureClousure: 失败回调
    static func waterFinishedOrder(_ parameter: [String: Any], imageDatas: [UIImage], successClourue: ((Int) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        let _ = RNNetworkManager.shared.upload(FinshFillWaterOrder, parameters: parameter, multipartFormData: { (multipartData) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let name = formatter.string(from: Date())
            let fileName = NSString(format: "%@", name)
            
            for (index, item) in imageDatas.enumerated() {
                let imageData = UIImageJPEGRepresentation(item, 0.1)
                
                if let data = imageData{
                    multipartData.append(data, withName:String(format: "%@%d", fileName,index), fileName: "updataImage", mimeType: "image/png")
                }
                
            }
            for (key, value) in parameter{
                
                if let v = (value as? String), let r = v.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    multipartData.append(r, withName: key)
                    
                }
            }
        }, progressClousure: { (pregress) in
            //
        }, successClourue: { (result) in
            let state = result["state"].intValue
            successClourue?(state)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 是否开启冲水服务
    ///
    /// - Parameters:
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getIsEnable(_ parameter: [String: Any], successClourue: ((Bool) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        let _ = RNNetworkManager.shared.post(GetIsEnable, parameters: parameter, successClourue: { (result) in
             let data = result["data"].boolValue
            successClourue?(data)
        }){ (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
}


//MARK: - custom methods
extension OrderServicer {
    
    /// 获取订单类型
    ///
    /// - Parameter action: 请求的行为 -- 不同入参代表不同行为
    /// - Returns: 订单类型
    static func getOrderType(action: String) -> Int {
        
        switch action {
        case OrderType.getOrder.rawValue :
            return 0
        case OrderType.waitingDealing.rawValue:
            return 1
        case OrderType.subscibe.rawValue:
            return 2
        case OrderType.completed.rawValue:
            return 3
        case OrderType.waitPay.rawValue:
            return 4
        case OrderType.commented.rawValue:
            return 5
        default:
            return -1
            
        }
        
    }
    
}
