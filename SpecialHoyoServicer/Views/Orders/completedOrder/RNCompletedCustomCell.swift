//
//  RNCompletedCustomCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNCompletedCustomCell: UITableViewCell {
    
    var model: CompletedOrderDetail?
    var indexPath: IndexPath?
    var myType: Int?
    var vc: UIViewController?
    
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
    
    
    func config(model m: CompletedOrderDetail, titles: [String], indexPath: IndexPath, type: Int, viewController: UIViewController){
        
        self.model = m
        self.indexPath = indexPath
        self.myType = type
        self.vc = viewController
        
        self.titleLabel.text = titles[indexPath.row]
        
        switch indexPath.row {
        case 0:
            contentLabel.text = dealEmptyString(text: m.machineType)
        case 1:
            contentLabel.text = dealEmptyString(text: m.machineCode)
        case 2:
            contentLabel.text = dealEmptyString(text: m.ICCID)
        case 3:
            contentLabel.text = dealEmptyString(text: m.macAddress)
        case 4:
            contentLabel.text = dealEmptyString(text: m.serviceCode)
        case 5:
            if [1,2,3,5,7,8].contains(type) {
            
               let t = ((m.residualSZ ?? "") != "" ? m.residualSZ! : "0") + ((m.SZUnit ?? "") != "" ? m.SZUnit! : "天")
               contentLabel.text = dealEmptyString(text: t) // 剩余水值
            }else if type == 4 {
               contentLabel.text = dealEmptyString(text: m.problemComponent) // 问题备注
            }else if type == 6 {
                contentLabel.text = dealEmptyString(text: m.installConfirmNum) // 安装确认单编号
            }else if type == 10 {
                contentLabel.text = dealEmptyString(text: m.y_TDS) // 源水 tds
            }
        case 6:
            if [1,2,5,8].contains(type){
                contentLabel.text = dealEmptyString(text: m.serviceReason) // 服务原因
            }else if [3,6].contains(type){
                contentLabel.text = dealEmptyString(text: m.shuiya) // 水压
            }else if type == 7 {
                contentLabel.text = dealEmptyString(text: m.y_TDS) // 源水 tds
            }else if type == 10{
               contentLabel.text = dealEmptyString(text: m.z_TDS) // 活水 tds
            }
            
        case 7:
            
            if [5,8].contains(type){
              contentLabel.text = dealEmptyString(text: m.problemComponent)  // 问题备注
            }else if type == 3{
                contentLabel.text = dealEmptyString(text: m.y_TDS) // 源水 tds
            }else if type == 6{
                contentLabel.text = dealEmptyString(text: m.isOpenBox) // 开箱状态
            }else if type == 7{
                contentLabel.text = dealEmptyString(text: m.z_TDS) // 活水 tds
            }
            
        case 8:
            if type == 3{
                contentLabel.text = dealEmptyString(text: m.z_TDS) // 活水 tds
            }else if type == 6{
               contentLabel.text = dealEmptyString(text: m.y_TDS) // 源水 tds
            }else if type == 7{
                contentLabel.text = dealEmptyString(text: m.problemComponent)  // 问题备注
            }
        case 9:
            if type == 3{
              contentLabel.text = dealEmptyString(text: m.serviceReason) // 服务原因
            }else if type == 6{
                contentLabel.text = dealEmptyString(text: m.z_TDS) // 活水 tds
            }
        case 10:
            
            if type == 6 {
                contentLabel.text = dealEmptyString(text: m.remark) // 备注描述

            }
        default:
            break
        }
        
    }
    

    // 处理空字符串
    func dealEmptyString(text: String?) -> String{
        
        guard let t = text, t != "" else {
            return "未填"
        }
        
        return t
    }
}
