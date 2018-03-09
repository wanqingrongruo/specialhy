//
//  RNBoxStateCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2018/3/5.
//  Copyright © 2018年 roni. All rights reserved.
//

import UIKit

protocol RNBoxStateCellProtocol {
    func getinfo(_ tag: Int, indexPath: IndexPath)
}

class RNBoxStateCell: UITableViewCell {
    
    @IBOutlet weak var mustLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var bucketButton: UIButton!
    @IBOutlet weak var contentTextField: UITextField!
    @IBAction func selectStyle(_ sender: UIButton) {
        
        if sender.tag == styleSelectedIndex {
            return
        }
        
        if styleSelectedIndex == 0 {
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            styleSelectedIndex = sender.tag
            
        }else{
            
            let btn = selectView.viewWithTag(styleSelectedIndex) as! UIButton
            btn.setImage(UIImage(named: "other_unSelected"), for: .normal)
            
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            
            styleSelectedIndex = sender.tag
        }
        
        if let index = index {
             delegate?.getinfo(sender.tag, indexPath: index)
        }
    }

    
    var styleSelectedIndex = 0  // 按钮索引, 100-良, 200-不良
    var index: IndexPath?
    var vc: UIViewController?
    var delegate: RNBoxStateCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(title: String, indexPath: IndexPath, viewController: UIViewController){
        
        titleLabel.text = title
        
        self.index = indexPath
        self.vc = viewController
    }
    
}
