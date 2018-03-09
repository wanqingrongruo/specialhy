//
//  RNTimeConfirmViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/24.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNTimeConfirmViewController: UIViewController {
    
    var model: OrderDetail
    var type: OrderType
    var actionType: String // 操作类型
    var orderModel: Order
    var isShowSeg = true // 是不是显示 seg
    
    init(_ model: OrderDetail, type: OrderType, actionType: String, orderModel: Order) {
        self.model = model
        self.type = type
        self.actionType = actionType
        self.orderModel = orderModel
        
        super.init(nibName: "RNTimeConfirmViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    
    @IBOutlet weak var reasonView: UIView!
    @IBOutlet weak var reasonPlaceholderLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var appointmentTimeLabel: RNMultiFunctionLabel!
    
    @IBOutlet weak var installInfoView: UIView!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var togetherButton: UIButton!
    @IBOutlet weak var seperatorButton: UIButton!
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var explainTextView: UITextView!
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
    
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmAction(_ sender: UIButton) {
        
        if !parameters(){
            return
        }
        // 改约接口
        RNHud().showHud(nil)
        OrderServicer.changeAppointment(parameter, successClourue: {
            
            RNHud().hiddenHub()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SubscibeSuccessNotification), object: nil) // 发送通知
            self.skipAction()
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    
    @IBOutlet weak var timeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var installInfoViewHeight: NSLayoutConstraint!
    
    var selectedIndex: Int = 0  // segment 索引
    var styleSelectedIndex = 0  // 按钮索引, 100-送装一体, 200-送装分离
    var isShowInstallInfo = false // 安装或换机为 true
    
    var isReasonPH = true
    var isExplainPH = true
    var isTimeSelected = false
    var isConfirmTime = true
    
    var parameter = [String: Any]()
    
    var callBack: ((_ appointment: String?) -> ())?  // 回调预约时间
    
    var waitDealCallback: ((_ appointment: String?, _ isComfirmTime: Bool) -> ())? // 待处理进入的回调
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "上门时间", target: self, action: #selector(popBack))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItem("order_history", target: self, action: #selector(historyAction))
        
        if !isShowSeg {
            optionsSegment.isHidden = true
        }
        
        if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 6 || tuple.code == 2 { // 安装或换机单需要选择送装信息
            self.isShowInstallInfo = true
        }
        
        
        showInType()
        optionsSegment.addTarget(self, action: #selector(selectStyle(seg:)), for: UIControlEvents.valueChanged)
        optionsSegment.tintColor = MAIN_THEME_COLOR
        
        reasonTextView.delegate = self
        explainTextView.delegate = self
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
        //  confirmButton.layer.shouldRasterize = true
        
        labelAction()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


//MARK: - custom methods

extension RNTimeConfirmViewController {
    
    func labelAction() {
        
        appointmentTimeLabel.isOpenTapGesture = true
        appointmentTimeLabel.tapClosure = { gesture in
            
            self.view.endEditing(true)
            
            let min = Date()
            //  let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
            let picker = DateTimePicker.show(minimumDate: min, maximumDate: nil)
            picker.highlightColor = MAIN_THEME_COLOR //UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
            picker.darkColor = UIColor.darkGray
            picker.doneButtonTitle = "确定"
            picker.todayButtonTitle = "今天"
            picker.cancelButtonTitle = "取消"
            picker.is12HourFormat = false
            picker.dateFormat = "YYYY.MM.dd HH:mm"
            picker.doneButtonBackgroundColor = MAIN_THEME_COLOR
            picker.doneButtonFont = 17
            //        picker.isDatePickerOnly = true
            picker.completionHandler = { date in
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY.MM.dd HH:mm"
                self.appointmentTimeLabel.text = formatter.string(from: date)
                self.isTimeSelected = true
            }
        }
    }
    
    func showInType() {
        
        if !isShowInstallInfo {
            
            installInfoView.isHidden = true
            installInfoViewHeight.constant = 0
        }
    }
    
    @objc func selectStyle(seg: UISegmentedControl) {
        
        if seg.selectedSegmentIndex == selectedIndex {
            return
        }
        
        if seg.selectedSegmentIndex == 0 {
            
            timeView.isHidden = false
            timeViewHeight.constant = 85
            installInfoView.isHidden = false
            installInfoViewHeight.constant = 125
        }else{
            timeView.isHidden = true
            timeViewHeight.constant = 0
            installInfoView.isHidden = true
            installInfoViewHeight.constant = 0
        }
        
        selectedIndex = seg.selectedSegmentIndex
        
    }
    
    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func historyAction() {
        
        guard let orderId = model.orderId else {
            RNNoticeAlert.showError("提示", body: "未获取到订单 id,无法获取历史修改记录")
            return
        }
        
        let historyVC = RNHistoryViewController(orderId)
        self.navigationController?.pushViewController(historyVC, animated: true)
    }
    
    
    func parameters() -> Bool{
        
        guard let id = model.orderId else {
            RNNoticeAlert.showError("提示", body: "未获取到订单 id")
            return false
        }
        parameter["orderid"] = id
        
        guard let reason = reasonTextView.text, reason != "" else {
            RNNoticeAlert.showError("提示", body: "请填写申请理由")
            return false
        }
        parameter["applyreason"] = reason
        
        if selectedIndex == 0 {
            
            if !isTimeSelected {
                RNNoticeAlert.showError("提示", body: "请选择上门时间")
                return false
                
            }
            isConfirmTime  = true
            parameter["hometime"] = appointmentTimeLabel.text
        }else{
            isConfirmTime = false
        }
        
        // 安装单
        if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 6 {
            
            if selectedIndex == 0 { // 确定时间才需要确认送装方式
                if styleSelectedIndex == 100 {
                    parameter["sendway"] = "1"
                }else if styleSelectedIndex == 200 {
                    parameter["sendway"] = "2"
                }else{
                    RNNoticeAlert.showError("提示", body: "请选择送装方式")
                    return false
                }
                
                if let explain = explainTextView.text, explain != "" {
                    parameter["sendreamrk"] = explain
                }
            }
        }
        
        if selectedIndex == 0 {
            parameter["actiontype"] = actionType
        }else{
            parameter["actiontype"] = "NoTimeAppointment"
        }
        
        
        return true
    }
    
    func skipAction() {
        
        if type == OrderType.subscibe {
            // 改约 - 返回
            var text = self.appointmentTimeLabel.text
            if selectedIndex != 0 {
                text = "暂无"
            }
            
            callBack?(text)
            
            _ = navigationController?.popViewController(animated: true)
        }else{
            
            var text = self.appointmentTimeLabel.text
            if selectedIndex != 0 {
                text = "暂无"
            }
            waitDealCallback?(text, isConfirmTime)
            
            _ = navigationController?.popViewController(animated: true)
            //            // 跳转下一界面 -- type是以已预约的身份进入
            //            let commonDetailVC = RNCustomOrderDetailViewController(model: orderModel, type: OrderType.subscibe)
            //            commonDetailVC.isDownload = true
            //            self.navigationController?.pushViewController(commonDetailVC, animated: true)
        }
        
    }
}


//MARK: -  UITextViewDelegate
extension RNTimeConfirmViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == reasonTextView {
            if isReasonPH {
                reasonPlaceholderLabel.isHidden = true
                isReasonPH = false
            }
        }
        if textView == explainTextView {
            
            if isExplainPH {
                explainLabel.isHidden = true
                isExplainPH = false
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == reasonTextView, textView.text.isEmpty {
            reasonPlaceholderLabel.isHidden = false
            isReasonPH = true
        }
        
        if textView == explainTextView, textView.text.isEmpty {
            explainLabel.isHidden = false
            isExplainPH = true
        }
    }
    
}
