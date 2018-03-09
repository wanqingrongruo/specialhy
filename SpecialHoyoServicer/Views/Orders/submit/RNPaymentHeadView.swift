//
//  RNPaymentHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPaymentHeadView: UIView {
    
    @IBOutlet weak var orderIdLabel: RNMultiFunctionLabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    internal var orderId: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.orderIdLabel.text = String(format: "订单号: %@", self.orderId)
            }
        }
    }
    internal var money: Double = 0.00 {
        didSet {
            DispatchQueue.main.async {
                self.feeLabel.text = String(format: "%.2lf", self.money)
            }
        }
    }
    internal var describe: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.desLabel.text = self.describe
            }
        }
    }
    internal var unit: String = "元" {
        didSet {
            DispatchQueue.main.async {
                self.unitLabel.text = self.unit
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 复制
        orderIdLabel.pressClosure = { [weak self](gesture) in
            if let text = self?.orderIdLabel.text, text != "" {
                if gesture.state == .began {
                    self?.orderIdLabel.pressAction(whichLabel: (self?.orderIdLabel)!)
                }
            }
        }
    }
    
}
