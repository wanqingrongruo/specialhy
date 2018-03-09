//
//  RNFindPSwViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/30.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFindPSwViewController: RNBaseInputViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var getCodeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var psdShow: UIButton!
    
    @IBAction func getCodeAction(_ sender: UIButton) { // 获取验证码
        
        // 获取验证码
        sendPhoneCode()
    }
    @IBAction func comfirmAction(_ sender: UIButton) { // 确定
        
        // 确定
        self.submit()
    }
    
    @IBAction func isShow(_ sender: UIButton) { // 是否显示密码
        
        isShowPsd = !isShowPsd
        if isShowPsd {
            psdShow.setImage(UIImage(named: "log_psdShow"), for: .normal)
            newPasswordTextField.isSecureTextEntry = false
        }else{
            psdShow.setImage(UIImage(named: "log_psdHidden"), for: .normal)
            newPasswordTextField.isSecureTextEntry = true
        }

    }
    
    //MARK: properties
    var isShowPsd = false // 显示密码
    lazy var paramters = {
        return [String: Any]()
    }()

    //NARK: - 关于验证码
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            getCodeButton.setTitle("(\(newValue)s)", for: UIControlState())
            
            if newValue <= 0 {
                getCodeButton.setTitle("重新获取", for: UIControlState())
                isCounting = false
            }
        }
    }
    
    //计时器
    var countDownTimer:Timer?
    
    //用于开启和关闭定时器
    var isCounting:Bool = false{
        
        willSet{
            if  newValue {
                countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats:true)
                
                // verificationButton.backgroundColor = UIColor.gray
            }else
            {
                countDownTimer?.invalidate()
                countDownTimer = nil
                
                // verificationButton.backgroundColor = UIColor.brown
            }
            
            getCodeButton.isEnabled = !newValue
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 20.0
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "修改密码", target: self, action: #selector(dismissFromVC))]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}

extension RNFindPSwViewController {
    
    func checkPhone() -> Bool {
        
        guard let phone = phoneTextField.text, phone != "" else{
            RNNoticeAlert.showError("提示", body: "请输入手机号码")
            return false
        }
        
        guard RNCheckoutManager.isPhoneNumer(phone) else {
            RNNoticeAlert.showError("提示", body: "请输入正确的手机号码")
            return false
        }
        return true
    }

    func checkAllParams() -> Bool {
        
        guard checkPhone() else{
            return false
        }
        
        guard let sendCode = verificationTextField.text, sendCode != "" else {
            RNNoticeAlert.showError("提示", body: "请输入验证码")
            return false
        }
        
        guard let psd = newPasswordTextField.text, psd != "", psd.characters.count > 5 else {
            RNNoticeAlert.showError("提示", body: "密码需要五位以上数字或字母")
            return false
        }
        
        paramters["phone"] = phoneTextField.text!
        paramters["code"] = verificationTextField.text!
        paramters["password"] = newPasswordTextField.text!
        return true
        
    }

    
    func sendPhoneCode(){
        
        if !checkPhone() { return }
        UserServicer.sendPhoneCode(["mobile": phoneTextField.text!,"order": "ResetPassword"], successClourue: {
            
            //启动计时器
            self.remainingSeconds = 60
            self.isCounting = true
            
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func submit() {
        
        if !checkAllParams() { return }
        
        self.view.endEditing(true)
        RNHud().showHud(nil)
        UserServicer.resetPassword(paramters, successClourue: { () in
            
            RNHud().hiddenHub()
            
            let alert = UIAlertController(title: "提示", message: "修改成功,去登录", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                
                 self.navigationController?.popViewController(animated: true)
            })
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

//MARK: event response

extension RNFindPSwViewController {
    
    //计时器事件
    @objc func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
    
    @objc func dismissFromVC() {
        self.navigationController?.popViewController(animated: true)
    }

}

