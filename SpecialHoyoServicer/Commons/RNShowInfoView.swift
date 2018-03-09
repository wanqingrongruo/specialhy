//
//  RNShowInfoView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/31.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNShowInfoView: UIView {

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBAction func confirmAction(_ sender: UIButton) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 5

        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
    }
}
