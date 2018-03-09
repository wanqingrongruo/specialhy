//
//  RNNewHeadView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/22.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Kingfisher

protocol RNNewHeadViewProtocol {
    func skipToUserInfo2() // 跳转 进入 UserInfoVC
}


class RNNewHeadView: UIView {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var sevicerAreaLabel: UILabel!
    @IBOutlet weak var finishOrderLabel: UILabel!
    @IBOutlet weak var waitOrderLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!

    var delegate: RNNewHeadViewProtocol?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 25
        
        headImageView.isUserInteractionEnabled = true
        
        let infoTap = UITapGestureRecognizer(target: self, action: #selector(infoAction(gesture:)))
        headImageView.addGestureRecognizer(infoTap)
        
       // showInfo()
    }

    
//    func showInfo() {
//        
//        let userInfo = realmQueryResults(Model: UserModel.self).last
//        
//        guard let user = userInfo else {
//            
//            self.getCurrentuserInfo()
//            return
//        }
//        
//        if let url = user.headImageUrl, let u = URL(string: url) {
//            
//            self.headImageView.kf.setImage(with: u, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
//        }else{
//            self.headImageView.image = UIImage(named: "person_defaultHeadImage")
//        }
//        
//        nameLabel.text = user.realName
//        
//        if let id = user.userId{
//            userIdLabel.text = "(\(String(describing: id)))"
//        }
//        sevicerAreaLabel.text = ""
//        
//    }
//    
//    // 获取个人信息
//    func getCurrentuserInfo() {
//        
//        RNHud().showHud(nil)
//        UserServicer.getCurrentUser(successClourue: { (user) in
//            RNHud().hiddenHub()
//            
//            if let url = user.headImageUrl, let u = URL(string: url) {
//                
//                self.headImageView.kf.setImage(with: u, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
//            }else{
//                self.headImageView.image = UIImage(named: "person_defaultHeadImage")
//            }
//            
//            //  print("name: \(user.realName)")
//            self.nameLabel.text = user.realName
//            
//            if let id = user.userId{
//                self.userIdLabel.text = "(\(String(describing: id)))"
//            }
//            self.sevicerAreaLabel.text = ""
//            
//        }) { (msg, code) in
//            RNHud().hiddenHub()
//            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
//            print("错误提示: \(msg) + \(code)")
//        }
//    }
}

//MARK: - event response

extension RNNewHeadView {
    
    @objc func infoAction(gesture: UITapGestureRecognizer) {
        
        delegate?.skipToUserInfo2()
    }
}
