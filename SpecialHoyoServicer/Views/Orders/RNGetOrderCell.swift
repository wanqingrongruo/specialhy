//
//  RNGetOrderCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import RealmSwift

protocol RNGetOrderCellProtocol {
    func removeExpiredOrder(_ expiredOrer: Order, index: IndexPath?, callBack: ()->()) // 移除过期订单
}

class RNGetOrderCell: UITableViewCell { // 抢单 cell
    
    var model: Order?
    var index: IndexPath?
    var delegate: (RNGetOrderCellProtocol & MapViewControllerProtocol)?
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var instanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    @IBOutlet weak var addressLabel: RNMultiFunctionLabel!
    
    @IBOutlet weak var addressView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMap(gesture:)))
        addressView.addGestureRecognizer(tap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTime), name: NSNotification.Name(rawValue: CountDownTime), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    internal func config(model: Order, indexPath: IndexPath) {
        
        if model.isInvalidated {
            return
        }
        self.model = model
        self.index = indexPath
        
        if let type = model.serviceItem, type != "" {
            
            if let tuple = ServiceItemDictionary[type] {
                typeImageView.image = UIImage(named: tuple.image)
            }else{
                typeImageView.image = UIImage(named:"order_unknow")
            }
            
        }else{
            typeImageView.image = UIImage(named:"order_unknow")
        }
        
        
        let desM = realmQueryModel(Model: DestinationLocation.self) { (results) -> Results<DestinationLocation>? in
            let pre = NSPredicate(format: "crmId = %@", model.crmId!)
            return results.filter(pre)
            }?.last
        if let des = desM { // 目的地址有本地坐标缓存 --- 避免多次地址编码消耗性能
            
            let locationModel = realmQueryResults(Model: LocationModel.self).last
            if let lat01 = locationModel?.latitude, let long01 = locationModel?.longitude{
                
                let distance =  distanceBetweenLocationBy(latitude01: lat01, longitude01: long01, latitude02: des.latitude, longitude02: des.longitude)
                
                DispatchQueue.main.async(execute: {
                    self.instanceLabel.text = String(format: "%.2lfKM", distance)
                })
                
            }else{
                
                globalAppDelegate.locationAction()
                instanceLabel.text = "距离未知"
            }
        }else{
            
            conditionCaculation(m: model)
        }
        
        
        // timeLabel.text = ""
        contentLabel.text = (model.productInfo?.productModel!)! + (model.productInfo?.productName!)!
        var s = (model.province ?? "")
        s += (model.city ?? "")
        s += (model.country ?? "")
        s += (model.address ?? "")
        addressLabel.text = s
        
        
        // 复制
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
        
        
        guard let _ =  model.createTime else {
            self.timeLabel.text = "暂无"
            return
        }
        
    }
    
    
    
    @objc func showTime() {
        
        self.timeLabel.text = model?.countdownString
        
        if let m = model {
            if m.countdownTime <= 0 {
                delegate?.removeExpiredOrder(m, index: index, callBack: { 
                   // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CountDownTime), object: nil)
                })
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
    
    
    // 计算距离 -- 并缓存目标坐标
    func conditionCaculation(m model: Order) {
        
        let locationModel = realmQueryResults(Model: LocationModel.self).last
        if let lat01 = locationModel?.latitude, let long01 = locationModel?.longitude{
            DispatchQueue.main.async(execute: {
                let destinationAddress =  model.province! + model.city! + model.country! + model.address!
                globalAppDelegate.locationManager?.getCoordinate(address: destinationAddress) { (coordinate) in
                    // 目的地坐标
                    
                    let desModel = DestinationLocation()
                    desModel.crmId = model.crmId
                    desModel.longitude = coordinate.longitude
                    desModel.latitude = coordinate.latitude
                    realmWirte(model: desModel)
                    
                    let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let distance =  distanceBetweenLocationBy(latitude01: lat01, longitude01: long01, latitude02: location.latitude, longitude02: location.longitude)
                    
                    self.instanceLabel.text = String(format: "%.2lfKM", distance)
                }
                
                globalAppDelegate.locationManager?.geocoderError = { (_) in
                    self.instanceLabel.text = "距离未知"
                }
            })
            
        }else{
            
            globalAppDelegate.locationAction()
            instanceLabel.text = "距离未知"
        }
        
    }
}
