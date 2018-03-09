//
//  RNNoServiceViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/31.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNNoServiceViewController: UIViewController {
    
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var completeDButton: UIButton!
    @IBOutlet weak var noCompletedButton: UIButton!
    @IBAction func selectStyle(_ sender: UIButton) {
        
        if sender.tag == styleSelectedIndex {
            return
        }
        
        if styleSelectedIndex == 0 {
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            styleSelectedIndex = sender.tag
        }else{
            
            let btn = selectView.viewWithTag(styleSelectedIndex) as! UIButton
            btn.setImage(UIImage(named: "other_unSelected"), for: .normal)
            
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            
            styleSelectedIndex = sender.tag
        }
        
    }
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmAction(_ sender: UIButton) {
        
        if self.currentType == 1, !isShowTipView{
            showTip()
            return
        }
        if params() {
           callService()
        //print("无服务完成")
        }
    }
    
    var model: OrderDetail
    var styleSelectedIndex = 0  // 按钮索引, 100-上门完成, 200-未上门完成
    var isExplainPH = true
    
    var isShowTipView = false
    var parameter = [String: Any]()
    
    // 退机单处理
    var currentType: Int = -1 // 1: 退机弹提示
    var window: UIWindow?
    
    init(model detail: OrderDetail) {
        self.model = detail
        
        super.init(nibName: "RNNoServiceViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "订单详情", target: self, action: #selector(popBack))]
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
       // confirmButton.layer.shouldRasterize = true
        
        textView.delegate = self
        
        guard let type = model.serviceItem, type != "" else{
            RNNoticeAlert.showError("提示", body: "未获取到订单类型, 对退机单是否入库问题无法处理", duration: 3.0)
            return
        }
        
        if let tuple = ServiceItemDictionary[type]{ //
            self.currentType = tuple.code
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showTip()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       // showTip()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func params() -> Bool{
        
        guard let id = model.orderId else {
            RNNoticeAlert.showError("提示", body: "未获取到订单 id")
            return false
        }
        
        if styleSelectedIndex == 0 {
            RNNoticeAlert.showError("提示", body: "请选择完成方式")
            return false
        }
        
        parameter["orderid"] = id
        
        if styleSelectedIndex == 100 {   
            parameter["service"] = NoServiceCompleted.arrived.rawValue
        }else if styleSelectedIndex == 200 {
            parameter["service"] = NoServiceCompleted.noArrive.rawValue
        }
        
        guard let text = textView.text, text != ""  else{
            RNNoticeAlert.showError("提示", body: "请填写备注说明")
            return false
        }
        parameter["remark"] = text
        return true
    }
    
    func callService() {
       
        self.textView.endEditing(true)
        // TO DO: 保存 -10009参数错误
        RNHud().showHud(nil)
        OrderServicer.noServicerFinishedOrder(parameter, successClourue: {
            RNHud().hiddenHub()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NoServiceFinishOrderNotification), object: nil) // 发送通知
            RNNoticeAlert.showSuccessWithForever("提示", body: "订单已完成", buttonTapHandler: { [weak self](_) in
                RNNoticeAlert.hideMessage()
                self?.dismiss(animated: true, completion: {})
            })
            
        }, failureClousure: { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        })

    }
    
    
    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }

    
    func showTip(){
        if self.currentType == 1 {
            // 弹退机提示
            window = UIWindow(frame: UIScreen.main.bounds)
            let tjVC = RNTjViewController()
            window?.windowLevel = UIWindowLevelNormal
            window?.rootViewController = tjVC
            
            tjVC.appWindow = UIApplication.shared.keyWindow
            
            tjVC.callBack = {  [weak self] (dic) in
                self?.window = nil
                self?.isShowTipView = true
                for d in dic {
                    self?.parameter[d.key] = d.value
                }
            }
            
            window?.makeKeyAndVisible()
        }
    }
}

//MARK: -  UITextViewDelegate
extension RNNoServiceViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if isExplainPH {
            explainLabel.isHidden = true
            isExplainPH = false
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            explainLabel.isHidden = true
            isExplainPH = true
        }
       
    }
    
}

