//
//  RNSubmitCustomCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/24.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

protocol RNSubmitCustomCellProtocol {
    func getInputString(_ text: String, indexPath: IndexPath)
}

class RNSubmitCustomCell: UITableViewCell {
    
    @IBOutlet weak var mustLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBAction func scanButton(_ sender: UIButton) {
        
        var scanManager = RNScanManager(animationImage: "qr_scan_light_green", viewController: vc!)
        scanManager.delegate = self
        scanManager.beginScan()
        
    }
    
    var index: IndexPath?
    var vc: UIViewController?
    var delegate: RNSubmitCustomCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(title: String, placeHolder: String?, indexPath: IndexPath, viewController: UIViewController, isEnabled: Bool = true, keyboardType: UIKeyboardType = .default){
        
        titleLabel.text = title
        
        if let p = placeHolder {
            contentTextField.placeholder = p
        }
        
        contentTextField.isEnabled = isEnabled
        contentTextField.keyboardType = keyboardType
        
        self.index = indexPath
        self.vc = viewController
    }
    
}
//MARK: -
extension RNSubmitCustomCell: RNScanManagerProtocol{
    
    func scanFinished(scanResult: RNScanResult, error: String?) {
        
        guard error == nil else {
            RNNoticeAlert.showError("提示", body:  error!)
            return
        }
        
        if let scan = scanResult.strScanned, scan != ""  {
            var contentString = "" // 需要的字符串
            if scan.hasPrefix("http") && scan.contains("cardvalue") {
                let range:Range = scan.range(of: "cardvalue")!
                contentString = scan.substring(from: scan.index(after: range.upperBound))
                
            }else{
                contentString = scan
            }
            
            contentTextField.text = contentString
            delegate?.getInputString(contentString, indexPath: index!)
        }
    }
    
}
//MARK: - UITextFieldDelegate
extension RNSubmitCustomCell: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let s = textField.text, s != "" {
            delegate?.getInputString(s, indexPath: index!)
        }
    }
}
