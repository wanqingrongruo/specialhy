//
//  RNAboutViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNAboutViewController: ElasticModalViewController {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var hudVC: RNTipHudViewController?
    
    lazy var btn: UIButton = {
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 200, width: 100, height: 40)
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "关于"
        
        
        
        view.backgroundColor = UIColor(red: 249/255, green: 218/255, blue: 252/255, alpha: 1.0)
        
        view.addSubview(btn)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        view.backgroundColor = UIColor.blue
    }
    

    
    @objc func skipAction() {
        
        //self.dismissFromTop(view
        
        let view = SpringView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.center = CGPoint(x: SCREEN_BOUNDS.width * 0.5, y: SCREEN_BOUNDS.height * 0.5)
        view.backgroundColor = UIColor.red
        hudVC = RNTipHudViewController(view)
        
        window?.windowLevel = UIWindowLevelNormal
        window?.rootViewController = hudVC
        
        hudVC?.appWindow = UIApplication.shared.keyWindow
        
        hudVC?.callBack = { [weak self] in
            
//             // 销毁 window
//            self?.window?.isHidden = true
//            self?.window = nil
        }
        
        window?.makeKeyAndVisible()
        
        
    }

}
