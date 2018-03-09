//
//  RNCompletedView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFinishingView: UIView {
    
    typealias CompleteCallback = () -> ()

    @IBOutlet weak var comtrainerView: UIView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var completedBtn: UIButton!
    @IBAction func completeAction(_ sender: UIButton) {
        completeCallback?()
    }
    
    internal var money: Double = 0.00{
        didSet {
            DispatchQueue.main.async {
                self.moneyLabel.text = String(format: "¥%.2lf", self.money)
            }
        }
    }
    internal var btnTitle: String = "完成" {
        didSet {
            DispatchQueue.main.async {
                self.completedBtn.setTitle(self.btnTitle, for: .normal)
            }
        }
    }
    
    internal var completeCallback: CompleteCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
