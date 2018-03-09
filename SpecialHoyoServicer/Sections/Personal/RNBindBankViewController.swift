//
//  RNBindBankViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNBindBankViewController: RNBaseInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "申请提现", target: self, action: #selector(dismissFromVC))]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

//MARK: event response
extension RNBindBankViewController {
    
    @objc func dismissFromVC(){
        _ = navigationController?.popViewController(animated: true)
    }
}

extension RNBindBankViewController {
    
}

extension RNBindBankViewController {
    
}
