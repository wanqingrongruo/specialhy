//
//  RNExamCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/12.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNExamCell: UITableViewCell {
    
    var model: ExamModel?

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(model: ExamModel) {
        
        self.model = model
        
        timeLabel.text = model.testDate
        scoreLabel.text = String(format: "%@分",  model.score ?? "?")
        contentLabel.text = String(format: "考试科目: %@", model.subject ?? "未知")
        
        if let isPass = model.isPass, isPass == "1" {
            passLabel.text = "已通过"
        }else{
            passLabel.textColor = UIColor.red
            passLabel.text = "未通过"
        }
    }
}
