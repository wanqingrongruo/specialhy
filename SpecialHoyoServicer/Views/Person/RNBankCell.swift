//
//  RNBankCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNBankCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankNumber: UILabel!
    
    @IBOutlet weak var defaultButton: NSLayoutConstraint!
    @IBOutlet weak var describeLabel: UILabel!
    
    var callBack: ((BankCardModel) -> ())?

    @IBAction func changeState(_ sender: UIButton) {
    }
    @IBAction func deleteAction(_ sender: UIButton) {
        
        if let m = model {
            callBack?(m)
        }
    }
    
    var model: BankCardModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
//        backView.layer.masksToBounds = true
//        backView.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        
//        backView.layoutIfNeeded()
//        
//        bankNumber.adjustsFontSizeToFitWidth = true
//        
//        let maskPath = UIBezierPath(roundedRect: backView.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight] , cornerRadii: CGSize(width: 5, height: 5))
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = backView.bounds
//        maskLayer.path = maskPath.cgPath
//        backView.layer.mask = maskLayer
//
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configCell(model: BankCardModel) {
        
        self.model = model
        
        bankName.text = model.bankName
        var cardNum: String = "**** **** **** "
        
        guard let cardId = model.cardId, cardId.characters.count >= 4 else{
            
            bankNumber.text = cardNum + model.cardId!
            return
        }

        cardNum += (cardId as NSString).substring(from: model.cardId!.characters.count - 4)
        
        bankNumber.text = cardNum
    }
}
