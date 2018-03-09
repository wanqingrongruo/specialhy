//
//  RNTjTipView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNTjTipView: SpringView {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBAction func selectAction(_ sender: UIButton) {
        if sender.tag == selectedIndex {
            return
        }
        if selectedIndex == 0 {
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            selectedIndex = sender.tag
        }else{
            
            let btn = selectView.viewWithTag(selectedIndex) as! UIButton
            btn.setImage(UIImage(named: "other_unSelected"), for: .normal)
            
            sender.setImage(UIImage(named: "other_selected"), for: .normal)
            
            selectedIndex = sender.tag
        }
        
    }
    @IBAction func confirmAction(_ sender: UIButton) {
        
        switch selectedIndex {
        case 0:
            RNNoticeAlert.showError("提示", body: "请确认是否入库")
        case 100: // 入库
            params["IsNeedStorage"] = 1
            params["StorageTime"] = dateFormat()
            paramCallBack?(params)
        case 200:
            params["IsNeedStorage"] = 0
            params["StorageTime"] = dateFormat()
            paramCallBack?(params)
        default:
            break
        }
        
    }
    
    
    // personal properties
    private var selectedIndex: Int = 0 // 默认未选
    
    internal var params = [String: Any]() // 最终参数
    
    internal var paramCallBack: ((_ dic: [String: Any]) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.cornerRadius = 3
        
    }
    
    
    func dateFormat() -> String{
        let date = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        return dateFormatter.string(from: date)
    }
}
