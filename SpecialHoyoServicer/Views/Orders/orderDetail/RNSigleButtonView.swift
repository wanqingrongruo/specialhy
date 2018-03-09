//
//  RNSigleButtonView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSigleButtonView: UIView {
    
    var callBack: ((_ tag: Int) -> ())?

    @IBOutlet weak var sigleButton: UIButton!
    @IBAction func clickAction(_ sender: UIButton) {
        
        callBack?(sender.tag)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sigleButton.layer.masksToBounds = true
        sigleButton.layer.cornerRadius = 5.0
        
//        sigleButton.layer.shouldRasterize = true
    }

}
