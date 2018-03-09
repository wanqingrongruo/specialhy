//
//  RNInitialViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit


// 无用 -- 使用 TabPageViewController 代替


class RNInitialViewController: UIViewController {

    lazy var btn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.blue
        btn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        btn.setTitle("跳转到 B", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        view.backgroundColor = UIColor(red: 149/255, green: 218/255, blue: 152/255, alpha: 1.0)
        view.addSubview(btn)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    @objc func skipAction() {
        
//        let vc = RNAboutViewController()
//        let nav = UINavigationController(rootViewController: vc)
//         RNMainViewController.shared.switchViewController(viewController: nav)
    }
   
   
}

//MARK: - custom methods

extension RNInitialViewController {
    
//    /// 遮罩按钮手势的回调
//    ///
//    /// - parameter pan: 手势
//    func panGestureRecognizer(pan: UIPanGestureRecognizer) {
//        RNMainViewController.shared.panGestureRecognizer(pan: pan)
//    }
}


//MARK: - event response

extension RNInitialViewController {
    
}
