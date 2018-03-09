//
//  RNSimpleTitleView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/8.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSimpleTitleView: UIView {
    
    var deleteAllClosure: (() -> ())?

    @IBAction func deleteAll(_ sender: UIButton) {
        
        deleteAllClosure?()
    }

}
