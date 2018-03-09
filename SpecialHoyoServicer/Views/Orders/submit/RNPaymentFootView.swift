//
//  RNPaymentFootView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPaymentFootView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    internal var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    internal var state: String = "" {
        didSet {
            switch state {
            case PayState.noPay.rawValue:
                DispatchQueue.main.async {
                    self.stateLabel.text = "未支付"
                }
            case PayState.paied.rawValue:
                DispatchQueue.main.async {
                    self.stateLabel.text = "已支付"
                }
            default:
                DispatchQueue.main.async {
                    self.stateLabel.text = "未支付"
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
