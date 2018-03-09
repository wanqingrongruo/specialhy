//
//  RNFeeDetailCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/10/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFeeDetailCell: UITableViewCell {

    @IBOutlet weak var feeTypeLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configCell(_ model: MoneyModel) {
        
        feeTypeLabel.text = model.title
        feeLabel.text = String(format: "￥%.2lf", model.money/100.0)
    }
    
}
