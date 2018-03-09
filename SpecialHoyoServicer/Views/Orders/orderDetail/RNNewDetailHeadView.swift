//
//  RNNewDetailHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNNewDetailHeadView: UIView {
    
    
    @IBOutlet weak var oznerCodeLabel: RNMultiFunctionLabel!
    @IBOutlet weak var hoyoCodeLabel: RNMultiFunctionLabel!
    @IBOutlet weak var documentNumberLabel: RNMultiFunctionLabel!
    @IBOutlet weak var copyButton: UIButton!
    
    override func awakeFromNib() {
        copyButton.layer.borderWidth = 1.0
        copyButton.layer.borderColor = UIColor.color(140, green: 140, blue: 140, alpha: 1.0).cgColor
        copyButton.layer.masksToBounds = true
        copyButton.layer.cornerRadius = 3
        
        oznerCodeLabel.pressClosure =  { [weak self](gesture) in
            if let text = self?.oznerCodeLabel.text, text != "" {
                if gesture.state == .began{
                    self?.oznerCodeLabel.pressAction(whichLabel: (self?.oznerCodeLabel)!)
                }
                
            }
        }
        
        hoyoCodeLabel.pressClosure =  { [weak self](gesture) in
            if let text = self?.hoyoCodeLabel.text, text != "" {
                if gesture.state == .began{
                    self?.hoyoCodeLabel.pressAction(whichLabel: (self?.hoyoCodeLabel)!)
                }
                
            }
        }
        
        documentNumberLabel.pressClosure =  { [weak self](gesture) in
            if let text = self?.documentNumberLabel.text, text != "" {
                if gesture.state == .began{
                    self?.documentNumberLabel.pressAction(whichLabel: (self?.documentNumberLabel)!)
                }
                
            }
        }
        
    }
    
    
    @IBAction func copyAction(_ sender: UIButton) {
        var contentString = ""
        if let text = self.oznerCodeLabel.text, text != "" {
            contentString += text
        }
        if let text = self.hoyoCodeLabel.text, text != "" {
            contentString +=  " " + text
        }
        if let text = self.documentNumberLabel.text, text != "" {
            contentString +=  " " + text
        }
        
        let pastBoard = UIPasteboard.general
        pastBoard.string = contentString
        
    }
    
    
    func config(model: OrderDetail) {
        if let text = model.crmId, text != ""{
            oznerCodeLabel.text = String(format: "浩优编号: %@", text)
        }else{
            oznerCodeLabel.text = String(format: "浩优编号: 空")
        }
       
        if let text = model.documentNo, text != ""{
            hoyoCodeLabel.text = String(format: "浩泽编号: %@", text)
        }else{
            hoyoCodeLabel.text = String(format: "浩泽编号: 空")
        }
        
        if let text = model.documentNumber, text != ""{
            documentNumberLabel.text = String(format: "开户单号: %@", text)
        }else{
            documentNumberLabel.text = String(format: "开户单号: 空")
        }
    }
    
    func config02(model: CompletedOrderDetail) {
        if let text = model.crmId, text != ""{
            oznerCodeLabel.text = String(format: "浩优编号: %@", text)
        }else{
            oznerCodeLabel.text = String(format: "浩优编号: 空")
        }
        
        if let text = model.documentNo, text != ""{
            hoyoCodeLabel.text = String(format: "浩泽编号: %@", text)
        }else{
            hoyoCodeLabel.text = String(format: "浩泽编号: 空")
        }
        
        if let text = model.documentNumber, text != ""{
            documentNumberLabel.text = String(format: "开户单号: %@", text)
        }else{
            documentNumberLabel.text = String(format: "开户单号: 空")
        }
    }
}
