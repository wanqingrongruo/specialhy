//
//  RNChargeSectionTitleView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNChargeSectionTitleView: UIView {
    
    @IBOutlet weak var bcakView: UIView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var paidButton: UIButton!
    
    var seletedIndex = 100
    var clickClousure: ((Int) -> ())?
    
    @IBAction func clickAction(_ sender: UIButton) {
        
        if sender.tag == seletedIndex {
            return
        }
        
        let button = bcakView.viewWithTag(seletedIndex) as! UIButton
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = MAIN_THEME_COLOR
       // sender.isSelected = true
        
        seletedIndex = sender.tag
        
        clickClousure?(sender.tag)
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailButton.layer.masksToBounds = true
        detailButton.layer.cornerRadius = 10
        incomeButton.layer.masksToBounds = true
        incomeButton.layer.cornerRadius = 10
        paidButton.layer.masksToBounds = true
        paidButton.layer.cornerRadius = 10

    }


}
