//
//  RNPartCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNPartCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productModelLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var subButton: SpringButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
   
    
    var addCallBack: ((_ sender: UIButton, _ model: PartModel) -> ())?
    var subCallBack: ((_ sender: UIButton, _ model: PartModel) -> ())?
    
    @IBAction func addAction(_ sender: UIButton) {
        
        guard let m = model, m.isInvalidated == false else {
            return
        }
        if amount == 0 {
            subButton.isHidden = false
            amountLabel.isHidden =  false
            subButton.animate()
        }
        
        amount += 1
        amountLabel.text = String(format: "%d", amount)
        
        if let m = model {
             addCallBack?(sender, m)
        }
        
    }
    @IBAction func subAction(_ sender: UIButton) {
        guard let m = model, m.isInvalidated == false else {
            return
        }
        
        if amount - 1 > 0 {
            amount -= 1
            amountLabel.text = String(format: "%d", amount)
        }else{
            amount -= 1
            subButton.isHidden = true
            amountLabel.isHidden = true
        }
        
        if let m = model {
            subCallBack?(sender, m)
        }
    }
    
    
    var model: PartModel?
    var amount: Int = 0
    
    // 动画参数 -- 具体参考 Spring 库
    var selectedRow: Int = 0
    var selectedEasing: Int = 0
    
    var selectedForce: CGFloat = 1
    var selectedDuration: CGFloat = 1
    var selectedDelay: CGFloat = 0
    
    var selectedDamping: CGFloat = 0.5
    var selectedVelocity: CGFloat = 0.7
    var selectedScale: CGFloat = 1
    var selectedX: CGFloat = 0
    var selectedY: CGFloat = 0
    var selectedRotate: CGFloat = 0
    
    var selectedAnimation: String = Spring.AnimationPreset.SlideLeft.rawValue
    var selectedCurve: String = Spring.AnimationCurve.EaseInOut.rawValue

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        subButton.isHidden = true
        amountLabel.isHidden = true
        
        setOptions()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(model m: PartModel) {
        
        self.model = m
        
        self.amount = m.productAmount
        
        subButton.isHidden = true
        amountLabel.isHidden = true
        
        productNameLabel.text = m.productName
        productModelLabel.text = m.productModel
        productPriceLabel.text = String(format: "¥%@", m.productPrice ?? "")
        
        if m.productAmount > 0 {
            
            subButton.isHidden = false
            amountLabel.isHidden = false
            amountLabel.text = String(format: "%d", m.productAmount)
            
           // subButton.animate()
        }
    }
    
    func setOptions() {
        subButton.force = selectedForce
        subButton.duration = selectedDuration
        subButton.delay = selectedDelay
        
        subButton.damping = selectedDamping
        subButton.velocity = selectedVelocity
        subButton.scaleX = selectedScale
        subButton.scaleY = selectedScale
        subButton.x = selectedX
        subButton.y = selectedY
        subButton.rotate = selectedRotate
        
        subButton.animation = selectedAnimation
        subButton.curve = selectedCurve
    }
    
}


