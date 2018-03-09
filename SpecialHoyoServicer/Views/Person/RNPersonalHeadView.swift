//
//  RNPersonalHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/6.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

protocol RNPersonalHeadViewProtocol {
    func skipToUserInfo() // 跳转 进入 UserInfoVC
}

class RNPersonalHeadView: UIView {
    
   
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sevicerAreaLabel: UILabel!
    
    @IBOutlet weak var star01: UIImageView!
    @IBOutlet weak var star02: UIImageView!
    @IBOutlet weak var star03: UIImageView!
    @IBOutlet weak var star04: UIImageView!
    @IBOutlet weak var star05: UIImageView!

    @IBOutlet weak var qrImageView: UIImageView!
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var dealingLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    var delegate: RNPersonalHeadViewProtocol?
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        headImageView.isUserInteractionEnabled = true
        
        let infoTap = UITapGestureRecognizer(target: self, action: #selector(infoAction(gesture:)))
        headImageView.addGestureRecognizer(infoTap)
        
    }
    
}

//MARK: - event response

extension RNPersonalHeadView {
    
    @objc func infoAction(gesture: UITapGestureRecognizer) {
        
        delegate?.skipToUserInfo()
    }
    
}
