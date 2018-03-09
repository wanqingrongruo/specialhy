//
//  RNRegisterViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/30.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Rswift

class RNRegisterViewController: RNBaseInputViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var secondPasswordTextField: UITextField!
    @IBOutlet weak var inviteCodeTextField: UITextField!
    
    @IBOutlet weak var verificationButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var secondPasswordButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var protocolButton: UIButton!
    @IBOutlet weak var protocolLabel: RNMultiFunctionLabel!
    
    @IBAction func getVerificatioCode(_ sender: UIButton) {
        // 获取验证码
        sendPhoneCode()
    }
    
    @IBAction func protocolAction(_ sender: UIButton) { // 协议
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected { // 同意
            isAgreeProtocol = true
            protocolButton.setImage(UIImage(named:"log_agree"), for: .normal)
        }else{
            isAgreeProtocol = false
            protocolButton.setImage(UIImage(named: "log_disagree"), for: .normal)
        }
    }
    @IBAction func changeIcon(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            isShowPsd = !isShowPsd
            if isShowPsd {
                passwordButton.setImage(UIImage(named: "log_psdShow"), for: .normal)
                passwordTextField.isSecureTextEntry = false
            }else{
                passwordButton.setImage(UIImage(named: "log_psdHidden"), for: .normal)
                passwordTextField.isSecureTextEntry = true
            }
            
            break
        case 200:
            isConfirmShowpsd = !isConfirmShowpsd
            if isConfirmShowpsd {
                secondPasswordButton.setImage(UIImage(named: "log_psdShow"), for: .normal)
                secondPasswordTextField.isSecureTextEntry = false
            }else{
                secondPasswordButton.setImage(UIImage(named: "log_psdHidden"), for: .normal)
                secondPasswordTextField.isSecureTextEntry = true
            }

            break
        default:
            break
        }
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        // 确定
        self.submit()
       // self.skipAuth()
    }
    
    
    //MARK: properties
    var isShowPsd = false // 显示密码
    var isConfirmShowpsd = false
    lazy var paramters = {
        return [String: Any]()
    }()
    var isAgreeProtocol = false
    
    //NARK: - 关于验证码
    
    //倒计时剩余的时间
    var remainingSeconds = 0{
        
        willSet{
            
            verificationButton.setTitle("(\(newValue)s)", for: UIControlState())
            
            if newValue <= 0 {
                verificationButton.setTitle("重新获取", for: UIControlState())
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
            
            verificationButton.isEnabled = !newValue
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 20.0
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "登录", target: self, action: #selector(dismissFromVC))]

        let tap01 = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        protocolLabel.addGestureRecognizer(tap01)
        
        
        protocolLabel.isOpenTapGesture = true
        protocolLabel.tapClosure = { tap in
            
            let webVC = RNWebUrlViewController(url: RegisterProtocol, title: "注册")
            self.navigationController?.pushViewController(webVC, animated: true)
        }
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


    @objc func dismissFromVC() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: custom

extension RNRegisterViewController{
    
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
        
        guard let psd = passwordTextField.text, psd != "", psd.characters.count > 5 else {
            RNNoticeAlert.showError("提示", body: "密码需要五位以上数字或字母")
            return false
        }
        guard let psd2 = secondPasswordTextField.text, psd2 != "", psd2 == psd else {
            RNNoticeAlert.showError("提示", body: "两次密码输入不同")
            return false
        }
        
        if !isAgreeProtocol {
            RNNoticeAlert.showError("提示", body: "必须同意《浩优服务家协议》")
            return false
        }

        paramters["mobile"] = phoneTextField.text!
        paramters["code"] = verificationTextField.text!
        paramters["password"] = passwordTextField.text!
        
        if let yq = inviteCodeTextField.text, yq != "" {
            paramters["yqCode"] = yq
        }
        
        return true
       
    }
    
    func sendPhoneCode(){
        
        if !checkPhone() { return }
        UserServicer.sendPhoneCode(["mobile": phoneTextField.text!,"order": "register","scope":"engineer"], successClourue: {
            
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
        UserServicer.register(paramters, successClourue: { (model) in
            
            RNHud().hiddenHub()
            
            self.getCurrentuserInfo() // 获取当前用户信息
            
            //绑定极光
            guard let _ = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey), let _ =  UserDefaults.standard.object(forKey: UserIdKey) else {
                return
            }
            UserServicer.bingJpush(["notifyid": JPUSHService.registrationID()], successClourue: {
                print("极光 => 绑定通知成功")
            }) { (msg, code) in
                //RNNoticeAlert.showError("提示", body: msg)
                print("极光 => 绑定失败: code = \(code)")
            }
            
            // 跳转
            self.skipAuth()

        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)

        }
    }
    
    func getCurrentuserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil) // 个人信息更新通知发出通知
            
            // 初始化 Udesk
            let organization = UdeskOrganization.init(domain: AppDomain, appKey: AppKey, appId: AppId)
            
            let customer = UdeskCustomer()
            guard let token = user.userId else{
                
                RNNoticeAlert.showError("提示", body: "未获取到用户id,聊天功能无法使用")
                return
            }
            customer.sdkToken = token
            
            if let name = user.realName {
                customer.nickName = name
            }else{
                customer.nickName = "未获取到姓名"
            }
            UdeskManager.initWith(organization!, customer: customer)
            
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
            print("错误提示: \(msg) + \(code)")
        }
    }
    
    func skipAuth() {
        
        let identifierVC = RNIdentityViewController(nibName: "RNIdentityViewController", bundle: nil)
        self.navigationController?.pushViewController(identifierVC, animated: true)
    }

}

//MARK: event response

extension RNRegisterViewController {
    
    //计时器事件
    @objc func updateTime() -> Void {
        
        remainingSeconds -= 1
    }
    
    @objc func tapAction() {
        
        // 协议跳转事件
    }

}
