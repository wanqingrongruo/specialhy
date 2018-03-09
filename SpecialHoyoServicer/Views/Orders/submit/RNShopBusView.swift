//
//  RNShopBusView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNShopBusView: UIView {

    @IBOutlet weak var shopBusButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    var shopBusClosure: (()->())?
    var isOpen: Bool = false
    
    var submitClosure: (()->())?
    
    @IBAction func shopAction(_ sender: UIButton) {
        
        shopBusClosure?()
    }
    @IBAction func submitAction(_ sender: UIButton) {
        
        submitClosure?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
