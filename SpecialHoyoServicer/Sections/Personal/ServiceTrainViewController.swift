//
//  ServiceTrainViewController.swift
//  HoyoServicer
//
//  Created by 赵兵 on 16/6/1.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit

class ServiceTrainViewController: RNBaseInputViewController {
    
    @IBOutlet weak var GuidTextField: UITextField!
    @IBOutlet weak var MachineKindTextField: UITextField!
    @IBOutlet weak var MachineBrandTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBAction func SubmitClick(_ sender: AnyObject) {
        
        if cherkText() {
            linkService()
        }

    }
    
    fileprivate var selfGuid: String
    fileprivate var selfMachineKind: String
    fileprivate var selfMachineBrand: String
    fileprivate var selfPhone: String
   
   init(Guid:String,MachineKind:String,MachineBrand:String,Phone:String) {

        selfGuid=Guid
        selfMachineKind=MachineKind
        selfMachineBrand=MachineBrand
        selfPhone=Phone
    
        super.init(nibName: "ServiceTrainViewController", bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var paramter: [String: Any] = {
        return [String: Any]()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "服务直通车", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("服务记录", target: self, action: #selector(serviceRecord))

        
        GuidTextField.text=selfGuid
        MachineKindTextField.text=selfMachineKind
        MachineBrandTextField.text=selfMachineBrand
        PhoneTextField.text=selfPhone
        GuidTextField.delegate=self
        MachineKindTextField.delegate=self
        MachineBrandTextField.delegate=self
        PhoneTextField.delegate=self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false

    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.navigationBar.isTranslucent = true
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ServiceTrainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ServiceTrainViewController {
    
    @objc func serviceRecord() {
        guard let id = GuidTextField.text, id != "" else {
            RNNoticeAlert.showError("提示", body: "guid 不能为空")
            return
        }

        let recordVC = RNHistoryServiceViewController(servicecode: id)
        self.navigationController?.pushViewController(recordVC, animated: true)
        
    }
    
    func cherkText() -> Bool {
        
        guard let id = GuidTextField.text, id != "" else {
            RNNoticeAlert.showError("提示", body: "guid 不能为空")
            return false
        }
        
        guard let kind = MachineKindTextField.text, kind != "" else {
            RNNoticeAlert.showError("提示", body: "型号不能为空")
            return false
        }
        
        guard let brand = MachineBrandTextField.text, brand != "" else {
            RNNoticeAlert.showError("提示", body: "品牌不能为空")
            return false
        }
        
        guard let phone = PhoneTextField .text, phone != "" else {
            RNNoticeAlert.showError("提示", body: "手机号不能为空")
            return false
        }
        
        paramter = ["serviceid": id, "MachineKind": kind, "MachineBrand": brand, "UserPhone": phone]
        return true
    }
    
    func linkService() {
        
        RNHud().showHud(nil)
        UserServicer.updateServiceTrain(paramter, successClourue: { 
           RNHud().hiddenHub()
            let alert = UIAlertController(title: "提示", message: "提交成功", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
                 self?.dismissFromVC()
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
    
    @objc func dismissFromVC(){
        _ = self.dismiss(animated: true, completion: nil)
    }
    
}

