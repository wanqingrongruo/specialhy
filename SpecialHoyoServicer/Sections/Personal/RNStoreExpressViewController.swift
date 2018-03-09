//
//  RNStoreExpressViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/12.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNStoreExpressViewController: ElasticModalViewController {
    
    fileprivate var myNav: RNCustomNavBar = {
        
        let nav = RNCustomNavBar(frame:  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: "nav_back", leftTitle: "仓储物流", rightIcon:  nil, rightTitle: nil)
        nav.createLeftView(target: self as AnyObject, action: #selector(popToLastVC))
        return nav
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - custom methods
extension RNStoreExpressViewController {
    
    func setupUI() {
        
        view.addSubview(myNav)
        
        let imageView = UIImageView(image: UIImage(named: "person_wait"))
        imageView.center = view.center
        imageView.sizeToFit()
        view.addSubview(imageView)
        
        let tipLabel = UILabel()
        tipLabel.text = "敬请期待"
        tipLabel.textAlignment = .center
        tipLabel.textColor = UIColor.darkGray
        tipLabel.font = UIFont.systemFont(ofSize: 20)
        tipLabel.sizeToFit()
        tipLabel.center = CGPoint(x: view.center.x, y: imageView.frame.maxY + 15 + 24)
        view.addSubview(tipLabel)
    }
    
    
    @objc func popToLastVC() {
        
        self.dismissFromTop(view)
    }
    
}
