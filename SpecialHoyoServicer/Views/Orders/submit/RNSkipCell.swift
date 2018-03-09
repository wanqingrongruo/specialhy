//
//  RNSkipCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSkipCell: UITableViewCell {
    
    @IBOutlet weak var mustLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var index: IndexPath?
    var vc: UIViewController?
    
    internal var money: Double = 0.00{
        didSet {
            DispatchQueue.main.async {
                self.moneyLabel.isHidden = false
                self.moneyLabel.text = String(format: "¥%.2lf", self.money)
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
    
    func configCell(title: String, tip: String?, indexPath: IndexPath, viewController: UIViewController){
        
        titleLabel.text = title
        
        if let t = tip {
            contentLabel.text = t
        }
        
        self.index = indexPath
        self.vc = viewController
    }
    
    
}


extension RNSkipCell {
    
    func  config02(title: String, tip: String?, indexPath: IndexPath, viewController: UIViewController){
        
        self.index = indexPath
        self.vc = viewController
        
        titleLabel.text = title
        
        if let t = tip {
            contentLabel.text = t
        }
    }
}
