//
//  RNHistoryTimeCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/23.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNHistoryTimeCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    var model: HistoryModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(model m: HistoryModel) {
        
        self.model = m
        
        self.remarkLabel.text = m.remark
        
        guard let time = m.homeTime, time != "" else {
            self.timeLabel.text = "暂无"
            return
        }
        let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
        let dataFormat = DateFormatter()
        dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
        
        if let t = timeStamp {
            let dateString = dataFormat.string(from: t)
            timeLabel.text = dateString
        }else{
            timeLabel.text = time
        }

    }
}
