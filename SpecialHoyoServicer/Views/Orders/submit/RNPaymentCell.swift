//
//  RNPaymentCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPaymentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(model: DetailFee) {
        if model.isPaid == PayState.paied.rawValue {
            titleLabel.textColor = .red
            priceLabel.textColor = .red
            numberLabel.textColor = .red
        }
        titleLabel.text = model.title
        priceLabel.text = String(format: "¥%.2lf", model.money)
        numberLabel.text = model.validity
    }
    
}
