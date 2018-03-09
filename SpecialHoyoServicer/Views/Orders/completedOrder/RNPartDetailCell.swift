//
//  RNPartDetailCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/10/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPartDetailCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productModelLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func configCell(_ model: CompletedPartModel) {
        productNameLabel.text = model.productName
        productModelLabel.text = model.productId
        productPriceLabel.text = String(format: "￥%@", model.productPrice ?? "0")
        amountLabel.text = String(format: "%d个", model.productAmount)
    }
}
