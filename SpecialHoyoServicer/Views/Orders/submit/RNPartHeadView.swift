//
//  RNPartHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPartHeadView: UIView {
    
    typealias CompleteCallback = () -> ()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var completedBtn: UIButton!
    @IBAction func completeAction(_ sender: UIButton) {
        completeCallback?()
    }
    
    internal var money: Double = 0.00 {
        didSet {
            DispatchQueue.main.async {
                self.feeLabel.text = String(format: "%.2lf元", self.money)
            }
            
        }
    }
    
    internal var btnTitle: String = "添加" {
        didSet {
            DispatchQueue.main.async {
                self.completedBtn.setTitle(self.btnTitle, for: .normal)
            }
        }
    }
    
    internal var completeCallback: CompleteCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        completedBtn.layer.borderWidth = 1.0
        completedBtn.layer.borderColor = UIColor.color(129, green: 129, blue: 129, alpha: 1).cgColor
        completedBtn.layer.masksToBounds = true
        completedBtn.layer.cornerRadius = 8.0
        
    }
}
