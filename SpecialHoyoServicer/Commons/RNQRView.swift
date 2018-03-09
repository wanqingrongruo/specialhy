//
//  RNQRView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/31.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNQRView: SpringView {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var codeLabel: RNMultiFunctionLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        codeLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.codeLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.codeLabel.pressAction(whichLabel: (self?.codeLabel)!)                }
                
            }
        }

    }
}
