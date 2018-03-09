//
//  RNDetailAppointmentCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

protocol RNDetailAppointmentCellProtocol {
    func freshUI(indexPath index: IndexPath?)
}

class RNDetailAppointmentCell: UITableViewCell {
    
    var model: OrderDetail?
    var completedModel: CompletedOrderDetail?
    var type: String = ""
    var vc: UIViewController?
    var orderModel: Order?
    var index: IndexPath?
    
    var delegate: RNDetailAppointmentCellProtocol?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    @IBOutlet weak var appointmentButton: UIButton!
    
    @IBAction func clickAction(_ sender: UIButton) {
        
        delegate?.freshUI(indexPath: index)
//        // 改约跳转
//        guard let m = model, let t = OrderType(rawValue: type) else {
//            
//            RNNoticeAlert.showError("提示", body: "未取到订单详情")
//            return
//        }
//
//        
//        if type == OrderType.subscibe.rawValue {
//            
//            var actionType = "NoTimeAppointment"
//            if let hometime = model?.homeTime, hometime != "" {
//                actionType = "ChangeTimeAppointment"
//            }
//            
//            let timeVC = RNTimeConfirmViewController(m, type: t, actionType: actionType, orderModel: self.orderModel!)
//            
//            timeVC.callBack = { [weak self] time in
//                
//                self?.contentLabel.text = time
//            }
//            vc?.navigationController?.pushViewController(timeVC, animated: true)
//            
//        }else { // if type == OrderType.waitingDealing.rawValue ||  type == OrderType.getOrder.rawValue
//            
//            // 未预约跳转
//            
//            let timeVC = RNTimeConfirmViewController(m, type: t, actionType: "Appointment", orderModel: self.orderModel!)
//            vc?.navigationController?.pushViewController(timeVC, animated: true)
//
//        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ model: OrderDetail, titleString: String, type: String, viewController: UIViewController, indexPath: IndexPath) {
        
        self.model = model
        self.type = type
        self.vc = viewController
        self.index = indexPath
        
        titleLabel.text = titleString
        
        if type == OrderType.waitingDealing.rawValue {
            
            appointmentButton.setImage(UIImage(named: "order_noSubscribe"), for: .normal)
        }else if type == OrderType.subscibe.rawValue {
            appointmentButton.setImage(UIImage(named: "order_amendtreaty"), for: .normal)
        }
        
        guard let time = model.homeTime, time != "" else {
            self.contentLabel.text = "暂无"
            return
        }
        
        appointmentButton.setImage(UIImage(named: "order_amendtreaty"), for: .normal)
        
        let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
        
        if let t = timeStamp {
            let dateString = dataFormat.string(from: t)
            contentLabel.text = dateString
        }else{
            contentLabel.text = time
        }
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }

    }
    
}

//MARK: - completedOrder

extension RNDetailAppointmentCell{
    
    func config02(_ model: CompletedOrderDetail, titleString: String, type: String, viewController: UIViewController) {
        
        self.completedModel = model
        self.type = type
        self.vc = viewController
        
        titleLabel.text = titleString
        
        if type == OrderType.waitingDealing.rawValue {
            
            appointmentButton.setImage(UIImage(named: "order_noSubscribe"), for: .normal)
        }else if type == OrderType.subscibe.rawValue {
            appointmentButton.setImage(UIImage(named: "order_amendtreaty"), for: .normal)
        }
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }
        
        guard let time = model.homeTime, time != "" else {
            self.contentLabel.text = "暂无"
            return
        }
        
        let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
        
        if let t = timeStamp {
            let dateString = dataFormat.string(from: t)
            contentLabel.text = dateString
        }else{
            contentLabel.text = time
        }
        
    }

}
