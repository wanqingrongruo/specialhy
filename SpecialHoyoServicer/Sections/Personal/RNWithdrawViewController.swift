//
//  RNWithdrawViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift

class RNWithdrawViewController: RNBaseInputViewController {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var moneyTextField: UITextField!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var allGetButton: UIButton!
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBAction func selectAction(_ sender: UIButton) {
        
        if banks.count > 0 {
            
            var array = [(String, String)]()
            for item in banks {
                
                let t = ("other_list", linkBankInfo(item))
                array.append(t)
            }
            
            RNActionSheet.creatYoutobe(viewController: self, titles: array) { (index) in
                
                DispatchQueue.main.async {
                    self.selectButton.setTitle(array[index].1, for: .normal)
                    self.currentModel = self.banks[index]
                }
                
            }
            
        }else{
            
            self.showBanks()
        }
    }
    
    @IBAction func allAction(_ sender: UIButton) {
        
        moneyTextField.text = String(format: "%.2lf",myBalance)
    }
    
    @IBAction func withdrawAction(_ sender: UIButton) {
        
        if checkISEmpty() {
            
            if moneyTextField.text!.hasPrefix(".") {//是否已"."开头
                
                let tmp = (("0" + moneyTextField.text!) as NSString).doubleValue
                moneyTextField.text = String(format: "%.2f",tmp)
                if (moneyTextField.text! as NSString).doubleValue > myBalance {
                    RNNoticeAlert.showError("提示", body: "余额不足")
                }
                else if (moneyTextField.text! as NSString).doubleValue <= 0{
                    
                    RNNoticeAlert.showError("提示", body: "提现金额不能为0")
                    
                }
                else{
                    
                    self.withDrawWithSer()
                }
                
            }else if moneyTextField.text!.hasSuffix("."){
                RNNoticeAlert.showError("提示", body: "提现金额不能以小数点结尾")
                
            }
            else if (moneyTextField.text! as NSString).doubleValue <= 0{
                
                RNNoticeAlert.showError("提示", body: "提现金额不能为0")
                
            }
            else if (moneyTextField.text! as NSString).doubleValue > myBalance{
                RNNoticeAlert.showError("提示", body: "余额不足")
            }else{
                self.withDrawWithSer()
            }
            
            
        }
    }
    
    
    lazy var queue: OperationQueue = {
        return OperationQueue()
    }()
    
    let group = DispatchGroup()
    
    lazy var myAccount: AccountModel = {
        return AccountModel()
    }()
    
    lazy var banks: [BankCardModel] = {
        
        let array = realmQueryResults(Model: BankCardModel.self)
        
        var arr = [BankCardModel]()
        for item in array {
            
            arr.append(item)
        }
        
        return arr.map({ (model) -> BankCardModel in
            return model.copy() as! BankCardModel
        })
        
    }()
    
    
    var myBalance:Double = 0.00{ //我的零钱余额
        
        didSet{
            
            balanceLabel.text = String(format: "%.2lf,",myBalance)
        }
    }
    
    var currentModel:BankCardModel? //选中的model
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "申请提现", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItem("person_bank", target: self, action: #selector(showBanks))
        
        
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.cornerRadius = 5
        
        selectButton.isEnabled = false
        allGetButton.isEnabled = false
        withdrawButton.isEnabled = false
        
        moneyTextField.delegate = self
        
        //        let op = BlockOperation {
        //
        //            RNHud().showHud(nil)
        //            self.getBalance()
        //
        //            if self.banks.count == 0 {
        //                self.getBanks()
        //            }else{
        //
        //                DispatchQueue.main.async {
        //                    self.selectButton.isEnabled = true
        //                    self.currentModel = self.banks.first
        //                    let fisrtCard = self.linkBankInfo(self.banks.first!)
        //                    self.selectButton.setTitle(fisrtCard, for: .normal)
        //                }
        //            }
        //        }
        //
        //
        //        op.completionBlock = {
        //
        //            DispatchQueue.main.async {
        //                RNHud().hiddenHub()
        //                self.withdrawButton.isEnabled = true
        //            }
        //        }
        //
        //        queue.addOperation(op)
        
        RNHud().showHud(nil)
        self.getBalance()
        if self.banks.count == 0 {
            self.getBanks()
        }else{
            
            DispatchQueue.main.async {
                self.selectButton.isEnabled = true
                self.currentModel = self.banks.first
                let fisrtCard = self.linkBankInfo(self.banks.first!)
                self.selectButton.setTitle(fisrtCard, for: .normal)
            }
        }
        
        group.notify(queue: .main) {
            RNHud().hiddenHub()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: event response
extension RNWithdrawViewController {
    
    @objc func showBanks() {
        
        let banksVC = RNBanksViewController()
        banksVC.callBack = { [weak self] in
            self?.getBanks()
        }
        navigationController?.pushViewController(banksVC, animated: true)
    }
    
    @objc func dismissFromVC(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension RNWithdrawViewController {
    
    func getBanks() {
        
        let queue = DispatchQueue(label: "getBanks", qos: .default, attributes: .concurrent)
        group.enter()
        queue.async(group: group, execute: {
            FinancialServicer.getOwnBankCards(successClourue: { (results) in
                
                self.banks =  results.map({ (model) -> BankCardModel in
                    return model.copy() as! BankCardModel
                })
                
                DispatchQueue.main.async {
                    self.selectButton.isEnabled = true
                    
                    if results.count == 0 {
                        
                        self.selectButton.setTitle("添加银行卡", for: .normal)
                    }else{
                        
                        self.currentModel = results.first
                        let fisrtCard = self.linkBankInfo(results.first!)
                        self.selectButton.setTitle(fisrtCard, for: .normal)
                    }
                }
                self.group.leave()
                
            }) { (msg, code) in
                RNNoticeAlert.showError("提示", body: msg)
                self.group.leave()
            }
        })
    }
    
    func getBalance() {
        let queue = DispatchQueue(label: "getBalance", qos: .default, attributes: .concurrent)
        group.enter()
        queue.async(group: group, execute: {
            FinancialServicer.getOwnMoney(successClourue: { (model) in
                
                self.myAccount = model
                
                //显示余额
                if let bla = model.balance, let tmp = Double(bla){
                    self.myBalance = tmp
                }else{
                    self.myBalance = 0.0
                }
                
                DispatchQueue.main.async {
                    
                    self.allGetButton.isEnabled = true
                }
                
                self.group.leave()
            }) { (msg, code) in
                RNNoticeAlert.showError("提示", body: msg)
                self.group.leave()
            }
        })
        
    }
    
    // 拼接尾号
    func linkBankInfo(_ model:BankCardModel) -> String {
        // 建设银行 尾号(5555)
        var resultString:String = ""
        resultString += model.bankName!
        resultString += " "
        
        var tempStr:String = "尾号("
        var count = 0
        for item in (model.cardId?.characters)! {
            count += 1
            if count > ((model.cardId?.characters.count)! - 4) {
                tempStr.append(item)
            }
        }
        tempStr += ")"
        
        resultString += tempStr
        
        return resultString
    }
    
    
    func checkISEmpty() -> Bool {
        
        guard let text = moneyTextField.text, text.characters.count > 0 else {
            RNNoticeAlert.showError("提示", body: "提现金额不能为空")
            return false
        }
        
        return true
    }
    
    func withDrawWithSer() {
        
        self.view.endEditing(true)
        guard let bankid = currentModel?.bankId else {
            RNNoticeAlert.showError("提示", body: "未获取到银行卡号")
            return
        }
        guard let money = moneyTextField.text, money != "" else {
            RNNoticeAlert.showError("提示", body: "未获取到提现金额")
            return
        }
        
        let paramter = ["blankid": bankid, "WDMoney": money]
        
        RNHud().showHud(nil)
        FinancialServicer.withDraw(paramter, successClourue: { 
            RNHud().hiddenHub()
            
            let alert = UIAlertController(title: "提现成功", message: "请等待审核,7-10个工作日内到账", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(deletaButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.present(alert, animated: true, completion: nil)
            }
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}

// MARK: - UITextFieldDelegate
extension RNWithdrawViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //限制输入框只能输入数字(最多两位小数)
        return  textField.moneyFormatCheck(textField.text!, range: range, replacementString: string, remian: 2)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        moneyTextField.resignFirstResponder()
        return true
    }
    
    
}
