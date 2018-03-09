//
//  RNCommentCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/12.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNCommentCell: UITableViewCell {
    
    var model: CompletedOrderDetail?
    var indexPath: IndexPath?
    var myType: Int?
    var vc: UIViewController?

    @IBOutlet weak var comentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(model m: CompletedOrderDetail, titles: [String], indexPath: IndexPath, type: Int, viewController: UIViewController){
        
        self.model = m
        self.indexPath = indexPath
        self.myType = type
        self.vc = viewController
        
        comentLabel.text = m.comment
    }

    
}
