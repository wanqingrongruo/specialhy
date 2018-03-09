//
//  RNWindowViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/8.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNWindowViewController: UIViewController {
    
   // var contentView: UIView
    weak var appWindow: UIWindow?
    var callBack: (() -> ())?
    var cancelBack: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.color(77, green: 77, blue: 77, alpha: 0.5)
        
      
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.5))) {
//            self.alertView()
//        }
//        
//       
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
//        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.alertView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView() {
        let alert = UIAlertController(title: "清空已选配件?", message: nil, preferredStyle: .alert)
        let deletaButton = UIAlertAction(title: "清空", style: .destructive) { [weak self](_) in
            self?.callBack?()
            self?.dismissVC()
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel) { [weak self](_) in
            self?.cancelBack?()
            self?.dismissVC()
        }
        alert.addAction(cancelButton)
        alert.addAction(deletaButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { 
            self.present(alert, animated: true, completion: nil)
        }
        

    }
    
    func dismissVC(){
        // self.dismissFromTop(view)
        
        view.alpha = 0
        appWindow?.makeKeyAndVisible()
    }
}
