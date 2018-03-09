//
//  RNWaitingDealingCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import CoreLocation

protocol RecordProtocol {
    func beginDailNumber(_ order: Order?, orderDetail: OrderDetail?) // 两个参数,, 订单页面用第一个, 详情页用第二个
}

class RNWaitingDealingCell: UITableViewCell { // 未处理 cell
    
    var state: Int = 0  // 未处理:1, 已预约2, 用于显示未确定时间的订单
    var model: Order?
    var delegate: (RNActionSheetProtocol & MapViewControllerProtocol & RecordProtocol)?
    var vc: UIViewController?
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var orderId: RNMultiFunctionLabel!
    @IBOutlet weak var linkerLabel: UILabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    @IBOutlet weak var addressLabel: RNMultiFunctionLabel!
    @IBOutlet weak var dailButton: UIButton!
    @IBOutlet weak var timeLabel: RNMultiFunctionLabel!
    
     @IBOutlet weak var addressView: UIView!
       
    
    
    @IBAction func dailAction(_ sender: UIButton) {        
        
        delegate?.beginDailNumber(model, orderDetail: nil) // 记录拨打动作
        
        var numbers = [(image: String, title: String)]()
        if let client = model?.clientMobile, client != ""{
            let item = ("other_list", client)
            numbers.append(item)
        }
        if let mobile = model?.userPhone, mobile != "" {
            let item = ("other_list", mobile)
            numbers.append(item)

        }
        
       // numbers.append(("other_list","17621627328"))
        
        switch numbers.count {
        case 0:
            RNNoticeAlert.showError("提示", body: "没有号码可拨打")
        case 1:
            dailing(number: numbers.first!.title)
        case 2:
            //
            delegate?.showYoutobeActionView(array: numbers)
            break
        default:
            break
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 性能优化 -
        // 1. 去图层混合
        orderId.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        orderId.layer.masksToBounds = true
        linkerLabel.backgroundColor = UIColor.white
        linkerLabel.layer.masksToBounds = true
        contentLabel.backgroundColor = UIColor.white
        contentLabel.layer.masksToBounds = true
        addressLabel.backgroundColor = UIColor.white
        addressLabel.layer.masksToBounds = true
        timeLabel.backgroundColor = UIColor.white
        timeLabel.layer.masksToBounds = true
        
        
        let alertTap = UITapGestureRecognizer(target: self, action: #selector(showTips))
        stateImageView.addGestureRecognizer(alertTap)

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMap(gesture:)))
        addressView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    internal func config(model: Order) {
        
        if model.isInvalidated {
            return
        }
        self.model = model
        
        if let type = model.serviceItem, type != "" {
            
            if let tuple = ServiceItemDictionary[type] {
                typeImageView.image = UIImage(named: tuple.image)
            }else{
                typeImageView.image = UIImage(named:"order_unknow")
            }
            
        }else{
            typeImageView.image = UIImage(named:"order_unknow")
        }

        
        orderId.text = model.crmId
        linkerLabel.text = model.clientName
        contentLabel.text = (model.productInfo?.productModel ?? "") + (model.productInfo?.productName ?? "")
        var s = (model.province ?? "")
        s += (model.city ?? "")
        s += (model.country ?? "")
        s += (model.address ?? "")
        addressLabel.text = s
      
//        if let time = model.appointmentTime, time != "" {
//            let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
//            let dataFormat = DateFormatter()
//            dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
//
//            if let t = timeStamp {
//                let dateString = dataFormat.string(from: t)
//                timeLabel.text = dateString
//            }else{
//                timeLabel.text = time
//            }
//
//        }else{
//            self.timeLabel.text = "暂无"
//        }
        timeLabel.text = model.appointmentTime

        if let type = model.actionType, type == "1"{
            stateImageView.isHidden = false
        }else{
            stateImageView.isHidden = true
        }
        // 复制
        orderId.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.orderId.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.orderId.pressAction(whichLabel: (self?.orderId)!)                }
                
            }
        }

        contentLabel.pressClosure = { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)
                }
                
            }
        } 
        addressLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.addressLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.addressLabel.pressAction(whichLabel: (self?.addressLabel)!)                }
                
            }
        }
        
    }
    
    @objc func showMap(gesture: UITapGestureRecognizer) {
        
        //        guard  let m = model else {
        //            RNNoticeAlert.showError("提示", body: "未拿到目的地坐标")
        //            return
        //        }
        
        guard let ad = self.addressLabel.text else {
            RNNoticeAlert.showError("提示", body: "未拿到目的地地址")
            return
        }
        
        globalAppDelegate.locationManager?.getCoordinate(address: ad) { (coordinate) in
            
            // 跳转地图
            let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.delegate?.showMapView(destinationLocation: location, destinationString: ad)
        }
        
    }
    
    @objc func showTips() {
       
        if let showTips = UserDefaults.standard.object(forKey: noConfirmTime) as? Bool, showTips == true {
           // 不做反应
        }else{
            
            let alert = UIAlertController(title: "提示", message: "待定是指未处理订单在预约操作时未能与客户确定具体上门时间(备注: 此提示只出现一次) ", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title:"确定", style: .default, handler: nil)
            alert.addAction(deletaButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.vc?.present(alert, animated: true, completion: nil)
            }

            UserDefaults.standard.set(true, forKey: noConfirmTime)
        }
    }
    
}
