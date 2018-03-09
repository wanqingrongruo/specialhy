//
//  RNCoupleButtonView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNCoupleButtonView: UIView {
    
    var callBack: ((_ tag: Int) -> ())?

    @IBOutlet weak var noServiceButton: UIButton!
    @IBOutlet weak var arriveButton: UIButton!
    
    @IBAction func clickAction(_ sender: UIButton) {
        
        callBack?(sender.tag) // 无服务 tag:100, 到达 tag: 200
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        noServiceButton.layer.masksToBounds = true
        noServiceButton.layer.cornerRadius = 5.0
        arriveButton.layer.masksToBounds = true
        arriveButton.layer.cornerRadius = 5.0
        
//        noServiceButton.layer.shouldRasterize = true
//        arriveButton.layer.shouldRasterize = true
    }
    
  

}
