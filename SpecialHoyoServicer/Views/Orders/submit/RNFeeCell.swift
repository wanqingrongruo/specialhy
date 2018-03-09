//
//  RNFeeCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFeeCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var isEnableBtn: UIButton!
    @IBAction func isEnableAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.setImage(UIImage(named: "log_agree"), for: .normal)
        }
        else {
            sender.setImage(UIImage(named: "log_disagree"), for: .normal)
        }
        
        callback?(sender.isSelected)
    }
    
    var callback: ((Bool)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(model: DetailFee) {
        iconImageView.kf.setImage(with: model.imageUrl, placeholder: UIImage(named: "newFee_default"), options: nil, progressBlock: nil, completionHandler: nil)
        feeLabel.text = String(format: "%.2lf元", model.money)
        titleLabel.text = model.title
        numLabel.text = model.validity
    }
    
}
