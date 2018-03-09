//
//  RNMessageView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/30.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

var messageViewWidth: CGFloat = 50
let menuWidth: CGFloat = 40
let menuDistance: Float = 100

@objc public protocol RNMessageViewDelegate {
    /**
     Tells the delegate the circle menu is about to draw a button for a particular index.
     
     - parameter circleMenu: The circle menu object informing the delegate of this impending event.
     - parameter button:     A circle menu button object that circle menu is going to use when drawing the row. Don't change button.tag
     - parameter atIndex:    An button index.
     */
    @objc optional func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int)
    
    /**
     Tells the delegate that a specified index is about to be selected.
     
     - parameter circleMenu: A circle menu object informing the delegate about the impending selection.
     - parameter button:     A selected circle menu button. Don't change button.tag
     - parameter atIndex:    Selected button index
     */
    @objc optional func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int)
    
    /**
     Tells the delegate that the specified index is now selected.
     
     - parameter circleMenu: A circle menu object informing the delegate about the new index selection.
     - parameter button:     A selected circle menu button. Don't change button.tag
     - parameter atIndex:    Selected button index
     */
    @objc optional func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int)
    
    /**
     Tells the delegate that the menu was collapsed - the cancel action.
     
     - parameter circleMenu: A circle menu object informing the delegate about the new index selection.
     */
    @objc optional func menuCollapsed(_ circleMenu: CircleMenu)

}

class RNMessageView{
    
    static var shared = RNMessageView()
    private init() {
       
        create()
    }

    
    internal var delegate: RNMessageViewDelegate?
    
    var backView = UIView()
    
    var menuButton = CircleMenu(frame: CGRect(x: SCREEN_WIDTH - 30 - 40, y: SCREEN_HEIGHT - 30 - 40, width: 40, height: 40), normalIcon: "icon_menu", selectedIcon: "icon_close", buttonsCount: 8, duration: 4, distance: 100)
    
    var badgeLabel = UILabel() // 修改消息条数
    
    func create() {
        
        let backView = UIView(frame:  CGRect(x: SCREEN_WIDTH - 30 - messageViewWidth, y: SCREEN_HEIGHT - 30 - messageViewWidth, width: messageViewWidth, height: messageViewWidth))
        backView.backgroundColor = UIColor.clear
        backView.isOpaque = true
        self.backView = backView
        
        
        let button = CircleMenu(frame: CGRect(x: messageViewWidth - menuWidth, y: messageViewWidth - menuWidth, width: menuWidth, height: menuWidth), normalIcon: "icon_menu", selectedIcon: "icon_close", buttonsCount: 8, duration: 4, distance: menuDistance)
//        let button = CircleMenu(frame: CGRect(x:  SCREEN_WIDTH - 30 - menuWidth, y:  SCREEN_HEIGHT - 30 - menuWidth, width: menuWidth, height: menuWidth), normalIcon: "icon_menu", selectedIcon: "icon_close", buttonsCount: 8, duration: 4, distance: menuDistance)

        button.backgroundColor = UIColor.clear
        button.isOpaque = true
        button.delegate = self
        button.layer.cornerRadius = button.frame.size.width / 2.0
        self.menuButton = button
        
        let label = UILabel(frame: CGRect(x: button.frame.origin.x + menuWidth - 10, y:button.frame.origin.y - 5  , width: 20, height: 20))
        label.backgroundColor = UIColor.red
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        self.badgeLabel = label
        
        backView.addSubview(button)
        backView.addSubview(label)
       
    }
}

extension RNMessageView: CircleMenuDelegate {
    
    func changeBackView(_ isMax: Bool) {
        
        if isMax {
            messageViewWidth  += CGFloat(menuDistance)
        }else{
            messageViewWidth = 50
        }
       
        
        self.backView.frame = CGRect(x: SCREEN_WIDTH - 30 - messageViewWidth, y: SCREEN_HEIGHT - 30 - messageViewWidth, width: messageViewWidth , height: messageViewWidth)
        
        self.menuButton.frame =  CGRect(x: messageViewWidth - menuWidth, y: messageViewWidth - menuWidth, width: menuWidth, height: menuWidth)
        
        self.badgeLabel.frame = CGRect(x: self.menuButton.frame.origin.x + menuWidth - 10, y:self.menuButton.frame.origin.y - 5  , width: 20, height: 20)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
    
        self.delegate?.circleMenu!(circleMenu, willDisplay: button, atIndex: atIndex)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
       
        self.delegate?.circleMenu!(circleMenu, buttonWillSelected: button, atIndex: atIndex)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
       
        self.delegate?.circleMenu!(circleMenu, buttonDidSelected: button, atIndex: atIndex)
    }

}
