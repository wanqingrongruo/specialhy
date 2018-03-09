//
//  RNActionSheet.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit
import XLActionController


protocol RNActionSheetProtocol {
    // func showSkypeActionView(array: [String])
    func showYoutobeActionView(array: [(image: String, title: String)])
}

struct RNActionSheet {
    
    static func createSkype(viewController: UIViewController, titles: [String], backgroundColor: UIColor = .white, style: ActionStyle = .default, callBack: ((_ index: Int) -> ())?) {
        
        let actionController = SkypeActionController()
        actionController.backgroundColor = backgroundColor
        
        for (index, value) in titles.enumerated() {
            let action = Action(value, style: .default, handler: { action in
                if callBack != nil {
                    callBack!(index)
                }
            })
            actionController.addAction(action)
        }
        actionController.addAction(Action("取消", style: .cancel, handler: nil))
        viewController.present(actionController, animated: true, completion: nil)
    }
    
    static func creatYoutobe(viewController: UIViewController, titles: [(image: String, title: String)], style: ActionStyle = .default, callBack: ((_ index: Int) -> ())?){
        
        let actionController = YoutubeActionController()
        for (index, value) in titles.enumerated() {
            let action = Action(ActionData(title: value.title, image: UIImage(named: value.image)!), style: .default, handler: { action in
                if callBack != nil {
                    callBack!(index)
                }
            })
            actionController.addAction(action)
        }

        actionController.addAction(Action(ActionData(title:"取消", image: UIImage(named: "other_cancel")!), style: .default, handler: nil))
        viewController.present(actionController, animated: true, completion: nil)

    }
}
