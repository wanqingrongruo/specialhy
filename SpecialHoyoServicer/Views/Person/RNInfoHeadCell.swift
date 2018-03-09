//
//  RNInfoHeadCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/13.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNInfoHeadCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius  = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
