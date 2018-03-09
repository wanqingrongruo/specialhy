//
//  RNSimplePartCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/8.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSimplePartCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var subButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    
    var addCallBack: ((_ indexPath: IndexPath, _ model: PartModel) -> ())?
    var subCallBack: ((_ indexPath: IndexPath, _ model: PartModel, _ isEmpty: Bool) -> ())?
    
    @IBAction func addAction(_ sender: UIButton) {
        
        amount += 1
        amountLabel.text = String(format: "%d", amount)
        
        model?.productAmount = amount
        
        addCallBack?(indexPath!, model!)
        
    }
    @IBAction func subAction(_ sender: UIButton) {
        
        if amount - 1 > 0 { // 非0
            amount -= 1
            model?.productAmount = amount
            amountLabel.text = String(format: "%d", amount)
            subCallBack?(indexPath!, model!, false)
        }else{
            amount -= 1
            model?.productAmount = amount
            // 删除行
            subCallBack?(indexPath!, model!, true)
        }
        
    }
    
    var model: PartModel?
    var indexPath: IndexPath?
    var amount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func config(_ model: PartModel, indexPath: IndexPath) {
        
        self.model = model
        self.indexPath = indexPath
        self.amount = model.productAmount
        
        productNameLabel.text = model.productName
        productPriceLabel.text = String(format: "¥%@", model.productPrice ?? "")
        amountLabel.text = String(format: "%d", model.productAmount)
        
    }
}
