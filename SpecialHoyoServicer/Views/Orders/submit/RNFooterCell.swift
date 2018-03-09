//
//  RNFooterCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/27.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFooterCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    internal var title: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.title
            }
        }
    }
    internal var state: String = "" {
        didSet {
            switch state {
            case PayState.noPay.rawValue:
                DispatchQueue.main.async {
                    self.stateLabel.text = "未支付"
                }
            case PayState.paied.rawValue:
                DispatchQueue.main.async {
                    self.stateLabel.text = "已支付"
                }
            default:
                DispatchQueue.main.async {
                    self.stateLabel.text = "未支付"
                }
            }
        }
    }
    
    internal var tipDes: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tipLabel.text = self.tipDes
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
