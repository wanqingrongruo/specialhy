//
//  RNLoginViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/30.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNLoginViewController: RNBaseInputViewController {

    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func clickAction(_ sender: UIButton) {
        
        
        switch sender.tag {
        case 100:
            // 登录
            
            loginAction()
            
            break
        case 200:
            // 忘记密码
            let findPswVC = RNFindPSwViewController(nibName: "RNFindPSwViewController", bundle: nil)
            self.navigationController?.pushViewController(findPswVC, animated: true)
            
            break
        case 300:
            // 还没有账号
            registerAction()
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 20.0
        
        let userImageView = UIImageView(frame: CGRect(x: 0, y: 15, width: 20, height: 20))
        //userImageView.sizeToFit()
        userImageView.image = UIImage(named: "log_user")
        userImageView.contentMode = .scaleAspectFit
        phoneTextField.leftView = userImageView
        phoneTextField.leftViewMode = .always
        phoneTextField.contentVerticalAlignment = .center
        
        let psdImageView = UIImageView(frame: CGRect(x: 0, y: 15, width: 20, height: 20))
        //psdImageView.sizeToFit()
        psdImageView.image = UIImage(named: "log_psw")
        psdImageView.contentMode = .scaleAspectFit
        passwordTextField.leftView = psdImageView
        passwordTextField.leftViewMode = .always
        passwordTextField.contentVerticalAlignment = .center
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        if let mobile = UserDefaults.standard.object(forKey: UserMobile) {
            phoneTextField.text = mobile as! String
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// MARK: - private methods

extension RNLoginViewController {
    
    fileprivate func checkParam() -> Bool {
        
        if !RNCheckoutManager.isPhoneNumer(phoneTextField.text) {
            
            RNNoticeAlert.showError("提示", body: "手机号格式错误或为空")
            
            return false
        }
        
        if !RNCheckoutManager.isEmpty(passwordTextField.text) {
            RNNoticeAlert.showError("提示", body: "密码不能为空")
            
            return false
        }
        
        return true
    }
    
    fileprivate func loginAction() {
        guard  checkParam() else {
            return
        }

        self.view.endEditing(true)
        RNHud().showHud(nil)
        UserServicer.login(phoneTextField.text!, password: passwordTextField.text!, successClourue: { (model) in

            RNHud().hiddenHub()

            globalAppDelegate.isValidToken = true
           // self.getCurrentuserInfo() // 获取当前用户信息

            self.showMainViewController()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: LoginSuccess), object: nil) // 登陆成功发出通知
            })

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
            
//            // 别名绑定
//            var seq: Int = 1001010086
//            if let id = model.id, let s = Int(id) {
//                seq = s
//            }
//            else if let moble = model.mobile, let s = Int(moble) {
//                seq = s
//            }
//            JPUSHService.setAlias("", completion: { (resCode, iAlias, seq) in
//                //
//            }, seq: seq)

        }) { (msg, code) in

            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func showMainViewController() {
        
      //  self.dismiss(animated: false) {
             globalAppDelegate.showMainViewController()
      //  }
       
//        globalAppDelegate.mainViewController = RNMainViewController.shared
//        self.present( globalAppDelegate.mainViewController!, animated: true, completion: nil)
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
    
}

//MARK: - register

extension RNLoginViewController{
    
    func registerAction(){
        let registerVC = RNRegisterViewController(nibName: "RNRegisterViewController", bundle: nil)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
}
extension RNLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginAction()
        textField.resignFirstResponder()
        return true
    }
}
