//
//  RNDetailCommonCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNDetailCommonCell: UITableViewCell {
    
    var model: OrderDetail?
    var completedModel: CompletedOrderDetail?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(_ model: OrderDetail, titleString: String, contentString: String?) {
        
        self.model = model
        
        titleLabel.text = titleString
        contentLabel.text = contentString
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }

    }

}

//MARK: - completedOrder

extension RNDetailCommonCell {
    
    func config02(_ model: CompletedOrderDetail, titleString: String, contentString: String?) {
        
        self.completedModel = model
        
        titleLabel.text = titleString
        contentLabel.text = contentString
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }
    }
    
}
