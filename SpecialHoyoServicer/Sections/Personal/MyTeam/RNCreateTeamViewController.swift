//
//  RNCreateTeamViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/24.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RNCreateTeamViewController: UIViewController {

    
    @IBOutlet weak var teamNameTextField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func selectLocation(_ sender: UIButton) {
        
        let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
        let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
        let tmpObject: AnyObject?
        do{
            tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        }
        let adressArray = tmpObject as! NSMutableArray
        var provinceArr = [String]()
        for item in adressArray {
            let str = (item as AnyObject)["name"] as! String
            provinceArr.append(str)
        }
        let selectAreaVC = RNSelectAreaTableViewController(index: 0, data: provinceArr, location: "", selected:"")
        selectAreaVC.delegate = self
        selectAreaVC.isThreeEdge = true
        let nav = RNBaseNavigationController(rootViewController: selectAreaVC)
        self.present(nav, animated: true, completion: nil)
        
    }
    @IBOutlet weak var specificAddressTextView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBAction func joinAction(_ sender: UIButton) {
        
        
        if makeParams() {
            
            RNHud().showHud(nil)
            UserServicer.createTeam(params, successClourue: { 
                RNHud().hiddenHub()
                
                RNNoticeAlert.showSuccessWithForever("提示", body: "申请成功, 请等待审核", buttonTapHandler: { [weak self](_) in
                    RNNoticeAlert.hideMessage()
                    self?.getCurrentuserInfo()
                    self?.dismiss(animated: true, completion: {})
                })
            }, failureClousure: { (msg, code) in
                RNHud().hiddenHub()
                RNNoticeAlert.showError("提示", body:  msg)
            })
            
        }
    }
    
    
    var hasPlaceHolder = true // placeHolderLabel 是否存在
    
    var params = [String: Any]() //参数列表
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "创建团队", target: self, action: #selector(dismissFromVC))]
        
        specificAddressTextView.delegate = self
        joinButton.layer.cornerRadius = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
    }

}

// MARK: - RNSelectAreaTableViewControllerDelegate

extension RNCreateTeamViewController: RNSelectAreaTableViewControllerDelegate {
    
    func reloadInstallInfoUI(_ loaction: String) {
        self.locationLabel.text = loaction // 更新区域信息
    }
}


// MARK: - UITextViewDelegate

extension RNCreateTeamViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if hasPlaceHolder {
            placeHolderLabel.isHidden = true
            hasPlaceHolder = false
        }
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
            hasPlaceHolder = true
        }
    }

}

//MARK: - private methods

extension RNCreateTeamViewController {
    
    func makeParams() -> Bool {
        guard let teamName = teamNameTextField.text, teamName != "" else {
            showErrorTips("请输入团队名称", "确定", "提示")
            return false
        }
        
        guard let address = locationLabel.text, address != "所在地区", address != "" else {
            showErrorTips("请选择地区", "确定", "提示")
            return false
        }
        
        let areas = address.components(separatedBy: " ")
        if areas.count < 3 {
            showErrorTips("地区选择不完整", "确定", "提示")
            return false
        }
        
        guard let specificAddress = specificAddressTextView.text, specificAddress != "" else {
            showErrorTips("请输入详细地址", "确定", "提示")
            return false
        }
        
        params["groupname"] = teamName
        params["province"] = areas[0]
        params["city"] = areas[1]
        params["country"] = areas[2]
        params["address"] = specificAddress
        
        self.view.endEditing(true)
        
        return true
    }
    
    // 错误提示
    func showErrorTips(_ errorInfo: String, _ title: String, _ tip: String){
        RNNoticeAlert.showError("提示", body: errorInfo)
    }
}

//MARK: - event response

extension RNCreateTeamViewController {
    
    @objc func dismissFromVC(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    // 获取个人信息
    func getCurrentuserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil) // 个人信息更新通知发出通知
            
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
            print("错误提示: \(msg) + \(code)")
        }
    }

    
}
