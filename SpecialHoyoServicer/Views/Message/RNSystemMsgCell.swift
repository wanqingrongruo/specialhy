//
//  RNSystemMsgCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSystemMsgCell: UITableViewCell {

    @IBOutlet weak var imgeView: UIImageView!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var model: MessageModel?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(_ model: MessageModel, indexPath: IndexPath){
        
        self.model = model
        self.index = indexPath
        
        
        orderIdLabel.text = model.orderId
        
        if let msg =  model.messageCon, msg != "" {
           contentLabel.text = model.messageCon
        }else{
        contentLabel.text = "你有新订单可以抢了"
        }
        
        
       self.timeLabel.text = model.createTime
        
//        guard let time = model.createTime, time != "" else {
//            self.timeLabel.text = "暂无"
//            return
//        }
//        
//        let timeStamp = RNDateTool.dateFromServiceTimeStamp(time)
//        let dataFormat = DateFormatter()
//        dataFormat.dateFormat = "YYYY/MM/dd HH:mm"
//        
//        if let t = timeStamp {
//            let dateString = dataFormat.string(from: t)
//            timeLabel.text = dateString
//        }else{
//            timeLabel.text = time
//        }

        
    }
}
