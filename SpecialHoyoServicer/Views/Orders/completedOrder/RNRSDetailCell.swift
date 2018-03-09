//
//  RNRSDetailCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/10/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNRSDetailCell: UITableViewCell {

 
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var solutionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(_ model: SolutionModel) {
        
        reasonLabel.text = model.reason
        solutionLabel.text = model.solution
    }
    
}
