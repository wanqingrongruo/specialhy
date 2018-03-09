//
//  RNFeeHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFeeHeadView: UIView {

    typealias CompleteCallback = () -> ()
    
    @IBOutlet weak var comtrainerView: UIView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var completedBtn: UIButton!
    @IBAction func completeAction(_ sender: UIButton) {
        completeCallback?()
    }

    internal var money: Double = 0.00 {
        didSet {
            DispatchQueue.main.async {
                self.moneyLabel.text = String(format: "¥%.2lf", self.money)
            }
        }
    }
    internal var orderId: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.orderIdLabel.text = String(format: "订单号: %@", self.orderId)
            }
        }
    }
    internal var btnTitle: String = "确定" {
        didSet {
            DispatchQueue.main.async {
                self.completedBtn.setTitle(self.btnTitle, for: .normal)
            }
        }
    }
    
    internal var completeCallback: CompleteCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        completedBtn.layer.masksToBounds = true
        completedBtn.layer.cornerRadius = 8.0
    }
}
