//
//  RNNewDetailLinkerCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNNewDetailLinkerCell: UITableViewCell {

    var model: OrderDetail?
    var completedModel: CompletedOrderDetail?
    var delegate: (RNActionSheetProtocol & RecordProtocol)?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: RNMultiFunctionLabel!
    
    @IBOutlet weak var dailButton: UIButton!
    @IBAction func dailAction(_ sender: UIButton) {
        
        var numbers = [(image: String, title: String)]()
        if let client = model?.yjMobile, client != ""{
            let item = ("other_list", client)
            numbers.append(item)
        }
        if let mobile = model?.yjPhone, mobile != "" {
            let item = ("other_list", mobile)
            numbers.append(item)
            
        }
        
        switch numbers.count {
        case 0:
            RNNoticeAlert.showError("提示", body: "没有号码可拨打")
        case 1:
            dailing(number: numbers.first!.title)
        case 2:
            //
            delegate?.showYoutobeActionView(array: numbers)
            break
        default:
            break
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
    
    func config(_ model: OrderDetail, titleString: String) {
        self.model = model
        
        titleLabel.text = titleString
        contentLabel.text = model.yjLinker
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                if gesture.state == .began{
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }
        
        
    }
}

//MARK: - completedOrder

extension RNNewDetailLinkerCell {
    
    func config02(_ model: CompletedOrderDetail, titleString: String) {
        
        self.completedModel = model
        
        titleLabel.text = titleString
        contentLabel.text = model.yjCompany
        
        contentLabel.pressClosure =  { [weak self](gesture) in
            
            if let text = self?.contentLabel.text, text != "" {
                
                if gesture.state == .began{
                    
                    self?.contentLabel.pressAction(whichLabel: (self?.contentLabel)!)                }
                
            }
        }
    }
    
}

