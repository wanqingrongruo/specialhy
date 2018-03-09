//
//  RNDetailAddressCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import CoreLocation

class RNDetailAddressCell: UITableViewCell {
    
    var model: OrderDetail?
    var completedModel: CompletedOrderDetail?
    var delegate: MapViewControllerProtocol?
    
    var isShiftMachine = false
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: RNMultiFunctionLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMap(gesture:)))
        addressView.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func config(_ model: OrderDetail, titleString: String) {
     
        self.model = model
        
        if isShiftMachine {
            
            iconImageView.image = UIImage(named: "order_shift")
            addressLabel.text = model.aimAddress
        }else{
           addressLabel.text = model.province! + model.city! + model.country! + model.address!
        }
        
        addressLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.addressLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.addressLabel.pressAction(whichLabel: (self?.addressLabel)!)                }
                
            }
        }

    }
    
//    func showMap(gesture: UITapGestureRecognizer) {
//        
//        guard  let m = model else {
//            RNNoticeAlert.showError("提示", body: "未拿到目的地坐标")
//            return
//        }
//        
//        guard let ad = self.addressLabel.text else {
//            RNNoticeAlert.showError("提示", body: "未拿到目的地地址")
//            return
//        }
//        // 跳转地图
//        let location = CLLocationCoordinate2D(latitude: m.latitude, longitude: m.longitude)
//        delegate?.showMapView(destinationLocation: location, destinationString: ad)
//    }

    
    @objc func showMap(gesture: UITapGestureRecognizer) {
        
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
}

//MARK: - completedOrder

extension RNDetailAddressCell {
    
    func config02(_ model: CompletedOrderDetail, titleString: String) {
        
        self.completedModel = model
        
        if isShiftMachine {
            
            iconImageView.image = UIImage(named: "order_shift")
            addressLabel.text = model.aimAddress
        }else{
            addressLabel.text = model.province! + model.city! + model.country! + model.address!
        }

        
        addressLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.addressLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.addressLabel.pressAction(whichLabel: (self?.addressLabel)!)                }
                
            }
        }
        
    }
    
}


