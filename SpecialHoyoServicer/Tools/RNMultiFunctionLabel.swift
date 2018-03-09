//
//  RNMultiFunctionLabel.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/13.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNMultiFunctionLabel: UILabel {
    
    var isOpenTapGesture: Bool = false { // 是否打开点击手势 -- default: false
        didSet{
            
            if isOpenTapGesture {
                
                self.addTapGesture()
            }
        }
    }
    var isOpenLongGesture: Bool = true { // 是否打开长按手势 -- default: true
        didSet {
             self.addLongPressGesture()
        }
    }
    
    //在具体使用中写函数
    var tapClosure: ((_ gesture: UITapGestureRecognizer) -> ())? // 点击事件
    var pressClosure: ((_ gesture: UILongPressGestureRecognizer) -> ())? // 长按事件
    
    var isOpenHightLightForKeyword: Bool = false {  // 是否打开关键词高亮显示
        
        didSet{
            
            guard let k = keyword else {
                return
            }
            
            guard let t = text else {
                return
            }
            
            let attr = NSMutableAttributedString(string: t)
            let str = NSString(string: t)
            let theRange = str.range(of: k)
            attr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: theRange)
            self.attributedText = attr

        }
    }
    var keyword: String? = nil // 关键词
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isOpenTapGesture {
            self.addTapGesture()
        }
        
        if isOpenLongGesture {
            self.addLongPressGesture()
        }
        
        if isOpenHightLightForKeyword {
            
            guard let k = keyword else {
                return
            }
            
            guard let t = text else {
                return
            }
            
            let attr = NSMutableAttributedString(string: t)
            let str = NSString(string: t)
            let theRange = str.range(of: k)
            attr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: theRange)
            self.attributedText = attr
            
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if isOpenTapGesture {
            self.addTapGesture()
        }
        
        if isOpenLongGesture {
            self.addLongPressGesture()
        }
        
        if isOpenHightLightForKeyword {
            
            guard let k = keyword else {
                return
            }
            
            guard let t = text else {
                return
            }
            
            let attr = NSMutableAttributedString(string: t)
            let str = NSString(string: t)
            let theRange = str.range(of: k)
            attr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.orange, range: theRange)
            self.attributedText = attr
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copyText(_:)){
            return true
        }else{
            return false
        }
        
    }
    
    override func copy(_ sender: Any?) {
        let pastBoard = UIPasteboard.general
        pastBoard.string = self.text
    }
    
    @objc func copyText(_ sender: Any?){
        let pastBoard = UIPasteboard.general
        pastBoard.string = self.text
    }
    
}

//MARK: - private methods

extension RNMultiFunctionLabel {
    
    func addLongPressGesture() {
        
        self.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(gesture:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPressAction(gesture: UILongPressGestureRecognizer){
        
        //        if gesture.state == .began{
        //
        //            self.becomeFirstResponder()
        //
        //            let copyItem = UIMenuItem(title: "复制", action: #selector(copyText(_:)))
        //            let menuVC = UIMenuController.shared
        //            menuVC.menuItems = [copyItem]
        //            if menuVC.isMenuVisible {
        //                return
        //            }
        //            menuVC.setTargetRect(bounds, in: self)
        //            menuVC.setMenuVisible(true, animated: true)
        //        }
        
        if pressClosure != nil {
            
            pressClosure!(gesture)
        }
        
    }
    
    
    func addTapGesture() {
        self.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapGetstureAction(_:)))
        self.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tapGetstureAction(_ gesture: UITapGestureRecognizer) {
        
        //        let telephoneNum = "telprompt://\(title)"
        //        guard let tel = URL(string: telephoneNum) else{
        //            return
        //        }
        //        UIApplication.shared.openURL(tel)
        
        if tapClosure != nil {
            
            tapClosure!(gesture)
        }
        
    }
    
}

//MARK: -  点击以及长按调用闭包的具体实现 -- 有新的操作可以在这个 extension 中添加

extension RNMultiFunctionLabel {
    
    // 复制的函数体 -- 使用时在闭包内调用即可
    func pressAction(whichLabel: UILabel) {
        
        whichLabel.becomeFirstResponder()
        
        let copyItem = UIMenuItem(title: "复制", action: #selector(copyText(_:)))
        let menuVC = UIMenuController.shared
        menuVC.menuItems = [copyItem]
        if menuVC.isMenuVisible {
            return
        }
        menuVC.setTargetRect(whichLabel.bounds, in: whichLabel)
        menuVC.setMenuVisible(true, animated: true)
        
    }
    // 点击拨打电话-- 使用时在闭包内调用即可
    func tapActionForDail(whichLabel: UILabel) {
        
        let telephoneNum = "telprompt://\(whichLabel.text!)"
        guard let tel = URL(string: telephoneNum) else{
            return
        }
        UIApplication.shared.openURL(tel)
        
    }

}

