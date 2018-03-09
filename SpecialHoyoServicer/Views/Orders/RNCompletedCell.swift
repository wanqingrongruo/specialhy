//
//  RNCompletedCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import CoreLocation

class RNCompletedCell: UITableViewCell { // 已完成 cell
    
    var model: Order?
    var delegate: MapViewControllerProtocol?
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var orderId: RNMultiFunctionLabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    @IBOutlet weak var addressLabel: RNMultiFunctionLabel!
    
    @IBOutlet weak var addressView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
       
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
        contentLabel.text =  (model.productInfo?.productModel ?? "") + (model.productInfo?.productName ?? "")
        var s = (model.province ?? "")
        s += (model.city ?? "")
        s += (model.country ?? "")
        s += (model.address ?? "")
        addressLabel.text = s
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
