//
//  RNMoneyCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNMoneyCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var model: AccountDetailModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(model: AccountDetailModel) {
        
        self.model = model
        
        //  获取类型 0: 全部, 1: 收入, 2: 提现, 3:扣款
        if let way = model.way{
           
            switch way {
            case "1":
                titleLabel.text = model.remark
                iconImageView.image = UIImage(named: "person_income")
                moneyLabel.textColor = UIColor.orange

                break
            case "2":
                titleLabel.text = model.remark
                iconImageView.image = UIImage(named: "person_paid")
                moneyLabel.textColor = UIColor.color(33, green: 169, blue: 110, alpha: 1)  // 33 169 110
                break
            case "3":
                titleLabel.text = model.remark
                iconImageView.image = UIImage(named: "person_paid")
                moneyLabel.textColor = UIColor.color(33, green: 169, blue: 110, alpha: 1)
                break
            default:
                break
            }
           
        }
        moneyLabel.text = model.money
        
        timeLabel.text = model.createTime
    }
    
}
