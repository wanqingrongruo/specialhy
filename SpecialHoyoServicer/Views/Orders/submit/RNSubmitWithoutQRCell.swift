//
//  RNSubmitWithoutQRCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

protocol RNSubmitWithoutQRCellProtocol {
    func getInputStringWithoutQR(_ text: String, indexPath: IndexPath)
}
class RNSubmitWithoutQRCell: UITableViewCell {
    
    @IBOutlet weak var mustLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!

    
    var index: IndexPath?
    var vc: UIViewController?
    var delegate: RNSubmitWithoutQRCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        contentTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(title: String, indexPath: IndexPath, viewController: UIViewController, ph: String = "输入"){
        
        titleLabel.text = title
        contentTextField.placeholder = ph
        
        self.index = indexPath
        self.vc = viewController
    }
    
}


//MARK: - UITextFieldDelegate
extension RNSubmitWithoutQRCell: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let s = textField.text, s != "" {
            delegate?.getInputStringWithoutQR(s, indexPath: index!)
        }
    }
}
