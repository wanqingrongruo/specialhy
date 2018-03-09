//
//  RNDetailHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNDetailHeadView: UIView {

    @IBOutlet weak var oznerView: UIView!
    @IBOutlet weak var hoyoView: UIView!
    @IBOutlet weak var orderView: UIView!
    
    @IBOutlet weak var oznerIdButton: UIButton!
    @IBOutlet weak var hoyoIdButton: UIButton!
    @IBOutlet weak var orderIdbutton: UIButton!
    
    var callBack: ((_ tag: Int) -> ())?
    
    @IBAction func clickAction(_ sender: UIButton) {
        callBack?(sender.tag)
    }
    override func awakeFromNib() {
        //
        oznerView.layer.masksToBounds = true
        oznerView.layer.cornerRadius = 5
        hoyoView.layer.masksToBounds = true
        hoyoView.layer.cornerRadius = 5
        orderView.layer.masksToBounds = true
        orderView.layer.cornerRadius = 5
        
//        oznerView.layer.shouldRasterize = true
//        hoyoView.layer.shouldRasterize = true
//        orderView.layer.shouldRasterize = true
        
    }

}
