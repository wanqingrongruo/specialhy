//
//  RNNewAddBankViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/26.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit


class RNNewAddBankViewController: RNBaseInputViewController {
    
    @IBOutlet weak var bankNameTextField: UITextField!
    
    @IBOutlet weak var branchNameTextField: UITextField!
    
    @IBOutlet weak var bankCodeTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBAction func selectBank(_ sender: UIButton) {
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        bingdingBankCard()
    }
    
    var params = [String: Any]() //参数列表
    
    var callBack: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "添加银行卡", target: self, action: #selector(dismissFromVC))]
        
        saveButton.layer.cornerRadius = 20
        bankCodeTextField.delegate = self
        phoneTextField.delegate = self
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - UITextFieldDelegate

extension RNNewAddBankViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === self.phoneTextField || textField == self.bankCodeTextField {
            
            if textField.digitFormatCheck(textField.text!, range: range, replacementString: string) {
                return true
            }else{
                
                RNNoticeAlert.showError("提示", body: "只能输入数字")
                return false
            }
        }
        
        return true
    }
    
}


//MARK: - private methods

extension RNNewAddBankViewController {
    
    func setUI(){
        
    }
    
    func mergeparams() -> Bool {
        
        guard let bankName = bankNameTextField.text, bankName != "" else {
            showErrorTips("请填写银行名称", "确定", "提示")
            return false
        }
        
        guard let branchName = branchNameTextField.text, branchName != "" else {
            showErrorTips("请填写支行名称", "确定", "提示")
            return false
        }
        
        guard let bankCode = bankCodeTextField.text, bankCode != "" else {
            showErrorTips("请填写银行卡号", "确定", "提示")
            return false
        }
        
        guard let name = nameTextField.text, name != "" else {
            showErrorTips("请填写姓名", "确定", "提示")
            return false
        }
        
        // 手机号码校验
        //  (phoneTextField!.characters.count == 11) && phoneTextField!.phoneFormatCheck()
        
        guard let phone = phoneTextField.text, RNCheckoutManager.isPhoneNumer(phoneTextField.text) else {
            showErrorTips("手机号码格式错误或未填", "确定", "提示")
            return false
        }
        
        
        params["openingbank"] = bankName
        params["branchbank"] = branchName
        params["cardid"] = bankCode
        params["realname"] = name
        params["cardphone"] = phone
        
        self.view.endEditing(true)
        
        return true
        
    }
    
    // 错误提示
    func showErrorTips(_ errorInfo: String, _ title: String, _ tip: String){
        RNNoticeAlert.showError("提示", body:  tip)
    }
    
    func bingdingBankCard() -> Void {
        //绑定验证
        
        if mergeparams() {
            
            RNHud().showHud(nil)
            FinancialServicer.bindingBankCard(params, successClourue: { 
                 RNHud().hiddenHub()
                let alert = UIAlertController(title: "提示", message: "绑定银行卡成功", preferredStyle: .alert)
                let deletaButton = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
                    self?.callBack?()
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(deletaButton)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.present(alert, animated: true, completion: nil)
                }

            }, failureClousure: { (msg, code) in
                RNHud().hiddenHub()
                RNNoticeAlert.showError("提示", body: msg)
            })
            
        }
        
    }
    
}

//MARK: - event response

extension RNNewAddBankViewController {
    
    @objc func dismissFromVC(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
