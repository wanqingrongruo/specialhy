//
//  RNLeftWaterCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

protocol RNLeftWaterCellProtocol {
    func getinfo(_ text: String, unit: String,indexPath: IndexPath)
}
class RNLeftWaterCell: UITableViewCell {
    
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
        
        setUnit()
        if let s = contentTextField.text, s != "", let ind = index{
            delegate?.getinfo(s, unit: unit, indexPath: ind)
        }
    }


    var styleSelectedIndex = 0  // 按钮索引, 100-天, 200-桶
    
    var index: IndexPath?
    var vc: UIViewController?
    var delegate: RNLeftWaterCellProtocol?
    var unit: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentTextField.delegate = self
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
    
    func setUnit() {
        
        switch styleSelectedIndex {
        case 100:
            unit = "天"
        case 200:
            unit = "桶"
        default:
            break
        }
    }
}

//MARK: - UITextFieldDelegate
extension RNLeftWaterCell: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if styleSelectedIndex == 0 {
            RNNoticeAlert.showError("提示", body: "请先选择水值单位")
            return false
        }
      
        setUnit()
        
        return true

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        if let s = textField.text, s != "", let ind = index{
            delegate?.getinfo(s, unit: unit, indexPath: ind)
        }
    }
}
