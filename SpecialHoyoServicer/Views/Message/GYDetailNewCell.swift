//
//  GYDetailNewCell.swift
//  HoyoServicer
//
//  Created by SH15BG0110 on 16/5/18.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class GYDetailNewCell: UITableViewCell,MLEmojiLabelDelegate {
    
    var messageLabel: MLEmojiLabel = MLEmojiLabel()
    var iconImageView: UIImageView = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.groupTableViewBackground
        iconImageView.frame = CGRect(x: 10, y: 20, width: 50, height: 50)
        iconImageView.image = UIImage(named: "sys_msg")
        contentView.addSubview(iconImageView)
        let imageView = UIImageView(image: UIImage(named:"message_receiver_background_normal"))
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(25)
            make.leading.equalTo(contentView).offset(65)
            make.height.greaterThanOrEqualTo(20)
            make.trailingMargin.lessThanOrEqualTo(-80)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.sizeToFit()
        messageLabel.textAlignment = NSTextAlignment.left
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        messageLabel.frame = contentView.bounds
        messageLabel.emojiDelegate = self
        
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView).offset(8)
            make.leading.equalTo(imageView).offset(15)
            make.height.greaterThanOrEqualTo(20)
            make.trailing.equalTo(imageView).offset(-20)
            make.bottom.equalTo(imageView).offset(-8)
        }
        
    }
    
    func reloadUI(_ model: PushStringModel) {
        
        messageLabel.emojiText = model.messageCon
        
        iconImageView.layer.cornerRadius = 25
        iconImageView.layer.masksToBounds = true
        if model.sendImageUrl != ""  {
            
            if model.sendImageUrl!.contains("http://") {
                iconImageView.kf.setImage(with: URL(string: model.sendImageUrl!), placeholder:  UIImage(named: "sys_msg"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                iconImageView.kf.setImage(with: URL(string: BASEURL + model.sendImageUrl!), placeholder:  UIImage(named: "sys_msg"), options: nil, progressBlock: nil, completionHandler: nil)
            }

//            var tmpUrl = model.sendImageUrl!
//            if (model.sendImageUrl?.contains("http"))==false
//            {
//                
//                if let _ = (NetworkManager.defaultManager?.website){
//                    
//                    tmpUrl = (NetworkManager.defaultManager?.website)! + tmpUrl
//                    
//                }else{
//                   tmpUrl = SERVICEADDRESS + tmpUrl
//                }
//                
//            }
//            let url = tmpUrl
//            iconImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named:"sys_msg"))
        }
    }
    
    func mlEmojiLabel(_ emojiLabel: MLEmojiLabel!, didSelectLink link: String!, with type: MLEmojiLabelLinkType) {
        
        switch type {
        case MLEmojiLabelLinkType():
            print(link)
            
            if link.contains("http://") || link.contains("https://") {
                 UIApplication.shared.openURL(URL(string: link)!)
            } else {
                let strUrl =  "http://" + link
                 UIApplication.shared.openURL(URL(string: strUrl)!)
                
            }
            
           
            
        case MLEmojiLabelLinkType.phoneNumber:
            UIApplication.shared.openURL(URL(string: "tel://" + link)!)
        case MLEmojiLabelLinkType.email:
            UIApplication.shared.openURL(URL(string: "mailto://" + link)!)
            
        default:
            break
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
