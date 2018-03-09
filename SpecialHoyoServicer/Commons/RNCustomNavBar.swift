//
//  RNCustomNavBar.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/14.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class RNCustomNavBar: UIView {
    
    fileprivate var leftIcon: String? = "nav_back"
    fileprivate var leftTitle: String? = "返回"
    fileprivate var rightIcon: String?
    fileprivate var rightTitle: String?
    
    fileprivate var searchBar: UISearchBar?
    
    public var headButton: UIButton?
    
    // 种类一
    init(frame: CGRect, leftIcon: String? = "nav_back", leftTitle: String? = "返回", rightIcon: String? = nil, rightTitle: String? = nil) {
        
        super.init(frame: frame)
        
        self.leftIcon = leftIcon
        self.leftTitle = leftTitle
        self.rightIcon = rightIcon
        backgroundColor = MAIN_THEME_COLOR
        
    }
    
    // 种类二: 带有搜索框
    init(frame: CGRect, leftIcon: String? = "nav_back", rightIcon: String? = nil, searchBar: UISearchBar? = nil) {
        
        super.init(frame: frame)
        
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.searchBar = searchBar
        
        backgroundColor = MAIN_THEME_COLOR
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 左边
    func createLeftView(target: AnyObject?, action: Selector) {
        
        if let title = leftTitle {
            
            // 种类一
            viewWithBack(title: title, target: target, action: action)
        }
        else{
            
            // 种类二
            viewWithNoBack(target: target, action: action)
        }
    }
    

    // 右边
    func createRightView(target: AnyObject?, action: Selector) {
        let btn = UIButton(type: .custom)
        
        if let title = rightTitle {
            btn.setTitle(title, for: .normal)
        }else if let icon = rightIcon {
            btn.setImage(UIImage(named: icon), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFit
        
        self.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.trailing.equalTo(self).offset(-8)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
    }
    
    // 有文字
    func viewWithBack(title: String, target: AnyObject?, action: Selector) {
        let backView = UIView()
        backView.backgroundColor = UIColor.clear
        backView.isUserInteractionEnabled = true
        
        self.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(24)
            make.leading.equalTo(self).offset(0)
            make.height.equalTo(40)
            make.trailing.greaterThanOrEqualTo(-8-44-8)
        }
        
        
        let btn = UIButton(type: .custom)
        if let icon = leftIcon {
            btn.setImage(UIImage(named: icon), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFit
        
        backView.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

       
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 1
        backView.addSubview(label)
        
//        label.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: target, action: action)
//        label.addGestureRecognizer(tap)

        
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(btn.snp.trailing).offset(0)
            make.trailing.lessThanOrEqualTo(-5)
            make.height.equalTo(24)
            make.centerY.equalTo(backView.snp.centerY)
            
        }
        
    }
    
    // 没有文字
    func viewWithNoBack(target: AnyObject?, action: Selector){
        let backView = UIView()
        backView.backgroundColor = UIColor.clear
        
        self.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(24)
            make.leading.equalTo(self).offset(0)
            make.height.equalTo(40)
            make.trailing.equalTo(self).offset(-8-44-8)
        }
        
        
        let btn = UIButton(type: .custom)
        if let icon = leftIcon {
            btn.setImage(UIImage(named: icon), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleToFill
        
        backView.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.width.equalTo(40)
        }

    }
  
    // 首页 bar
    func createSearchView(target: AnyObject?, leftAction: Selector, rightAction: Selector) {
     
        
        let lbtn = UIButton(type: .custom)
        lbtn.backgroundColor = UIColor.clear
        if let icon = leftIcon {
            
            let url = URL(string: icon)
            lbtn.kf.setImage(with: url, for: .normal, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        lbtn.addTarget(target, action: leftAction, for: .touchUpInside)
        lbtn.imageView?.contentMode = .scaleToFill
        
        headButton = lbtn
        self.addSubview(lbtn)
        
        lbtn.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.leading.equalTo(8)
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        
        lbtn.layer.masksToBounds = true
        lbtn.layer.cornerRadius = 18
        

        let rbtn = UIButton(type: .custom)
        rbtn.backgroundColor = UIColor.clear
        if let icon = rightIcon {
            rbtn.setImage(UIImage(named: icon), for: .normal)
        }
        rbtn.addTarget(target, action: rightAction, for: .touchUpInside)
        rbtn.imageView?.contentMode = .scaleAspectFit
        
        self.addSubview(rbtn)
        
        rbtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(24)
            make.trailing.equalTo(self).offset(-8)
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        
        
        
        self.addSubview(searchBar!)
        
        searchBar?.snp.makeConstraints({ (make) in
//            make.top.equalTo(lbtn.snp.top).offset(-2)
            make.centerY.equalTo(lbtn.snp.centerY)
            make.height.equalTo(36)
            make.leading.equalTo(lbtn.snp.trailing).offset(5)
            make.trailing.equalTo(rbtn.snp.leading).offset(-5)
        })

    }
    

}
