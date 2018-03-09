//
//  RNDetailFeeCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNDetailFeeCell: UITableViewCell {
    
    var model: OrderDetail?
    
    var completedModel: CompletedOrderDetail?
    
    @IBOutlet weak var logoImagView: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var payStateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(_ model: OrderDetail, titleString: String) {
        
        self.model = model
        
        if let type = model.serviceItem, type != "" {
            
            if let tuple = ServiceItemDictionary[type] {
                logoImagView.image = UIImage(named: tuple.image)
            }else{
                logoImagView.image = UIImage(named:"order_unknow")
            }
            
        }else{
            logoImagView.image = UIImage(named:"order_unknow")
        }

        feeLabel.text = String(format: "%@: ￥%@", model.payTitle ?? "服务费",model.money ?? "")
      //  feeLabel.text = "服务费: ￥" + (model.money ?? "")
        
        guard let state = model.payState, state != "" else {
            payStateLabel.text = "未知"
            return
        }
        
        switch state {
        case PayState.paied.rawValue:
            payStateLabel.text = "已支付"
        case PayState.noPay.rawValue:
            payStateLabel.text = "未支付"
        default:
            payStateLabel.text = "未知"
        }
    }
}

//MARK: - completedOrder

extension RNDetailFeeCell {
    
    func config02(_ model: CompletedOrderDetail, titleString: String) {
        
        self.completedModel = model
        
        if let type = model.serviceItem, type != "" {
            
            if let tuple = ServiceItemDictionary[type] {
                logoImagView.image = UIImage(named: tuple.image)
            }else{
                logoImagView.image = UIImage(named:"order_unknow")
            }
            
        }else{
            logoImagView.image = UIImage(named:"order_unknow")
        }
        
       feeLabel.text = String(format: "%@: ￥%@", model.payTitle ?? "",model.money ?? "")
        //  feeLabel.text = "服务费: ￥" + (model.money ?? "")
        
        guard let state = model.payState, state != "" else {
            payStateLabel.text = "未知"
            return
        }
        
        switch state {
        case PayState.paied.rawValue:
            payStateLabel.text = "已支付"
        case PayState.noPay.rawValue:
            payStateLabel.text = "未支付"
        default:
            payStateLabel.text = "未知"
        }
    }

}
