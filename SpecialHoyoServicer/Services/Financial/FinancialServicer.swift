//
//  FinancialServicer.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/25.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import SwiftyJSON

// 财务管理
struct FinancialServicer {
    
    
    /// 获取账户信息
    ///
    /// - Parameters:
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOwnMoney(successClourue: ((AccountModel) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        RNNetworkManager.shared.post(OwnMoney, parameters: nil, successClourue: { (result) in
            
            let data = result["data"]
            let model = AccountModel()
            model.id = data["id"].stringValue
            model.balance = data["money"].stringValue //可提现
            model.income = data["IncomeMoney"].stringValue //总收入
            model.totalAssets = data["ExpenditureMoney"].stringValue //总支出
            successClourue?(model)
            
        }, failureClousure: { (msg, code) in
            failureClousure?(msg, code)
        })
    }
    
   
    /// 账户详情
    ///
    /// - Parameters:
    ///   - parameter: [pagesize: , index: ,moneytype: ]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func  ownMoneyDetail(_ parameter: [String: Any], successClourue: (([AccountDetailModel]) -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(OwnMoneyDetail, parameters: parameter, successClourue: { (result) in
            
            let data = result["data"].array
            var array = [AccountDetailModel]()
            if let content = data {
                for item in content {
                    
                    let model = AccountDetailModel()
                    model.id = item["ID"].stringValue
                    model.payId = item["OrderNo"].stringValue
                    model.money = item["Money"].stringValue
                    model.way = item["MoneyType"].stringValue
                    model.remark = item["ReMarks"].stringValue
                    let time = item["CreateTime"].stringValue
                    if time != "" {
                        let date = RNDateTool.dateFromServiceTimeStamp(time)
                        if let d = date {
                            model.createTime = RNDateTool.stringFromDate(d, dateFormat: "yyyy年MM月dd日 HH:mm")
                        }else{
                            model.createTime = ""
                        }
                    }else{
                        model.createTime = time
                    }
                    
                    array.append(model)
                }
            }
            
            successClourue?(array)
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 获取银行卡列表
    ///
    /// - Parameters:
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func getOwnBankCards(successClourue: (([BankCardModel]) -> Void)?, failureClousure: ((String, Int) -> Void)?) {
        
        RNNetworkManager.shared.post(OwnBankCards, parameters: nil, successClourue: { (result) in
            
            let data = result["data"].array
            var array = [BankCardModel]()
            if let content = data{
                
                for item in content {
                    let model = BankCardModel()
                    model.id = item["id"].stringValue
                    model.bankName = item["OpeningBank"].stringValue
                    model.cardId = item["CardId"].stringValue
                    model.bindTime = item["BindTime"].stringValue
                    model.userName = item["CardUserName"].stringValue
                    model.cardPhone = item["ReservedPhoneNum"].stringValue
                    model.bankBranch = item["BranchBank"].stringValue
                    model.bankId = item["id"].stringValue
                    array.append(model)
                }
               
            }
            
            realmWirteModels(models: array)
            successClourue?(array.map({ (model) -> BankCardModel in
                return model.copy() as! BankCardModel
            }))
        }) { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 提现
    ///
    /// - Parameters:
    ///   - parameter: [blankid: , WDMoney: ]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func withDraw(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(WithDraw, parameters: parameter, successClourue: { (result) in
            successClourue?()
        })  { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 绑定银行卡
    ///
    /// - Parameters:
    ///   - parameter: <#parameter description#>
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func bindingBankCard(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(BindingBankCard, parameters: parameter, successClourue: { (result) in
            successClourue?()
        })  { (msg, code) in
            failureClousure?(msg, code)
        }
    }
    
    
    /// 删除银行卡
    ///
    /// - Parameters:
    ///   - parameter: [cid: ]
    ///   - successClourue: <#successClourue description#>
    ///   - failureClousure: <#failureClousure description#>
    static func deleteBankCard(_ parameter: [String: Any], successClourue: (() -> Void)?, failureClousure: ((String, Int) -> Void)?){
        
        RNNetworkManager.shared.post(DeleteBankCard, parameters: parameter, successClourue: { (result) in
            successClourue?()
        })  { (msg, code) in
            failureClousure?(msg, code)
        }
    }
}









