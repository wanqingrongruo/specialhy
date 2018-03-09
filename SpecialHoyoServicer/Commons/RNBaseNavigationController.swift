//
//  RNBaseNavigationController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class RNBackView: UIView { // 处理 iOS11 自定义titleView导致的按钮无响应问题
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: SCREEN_WIDTH - 70, height: 44)
    }
    
}

class RNBaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       // navigationBar.isTranslucent = true
        navigationBar.barTintColor = MAIN_THEME_COLOR
        navigationBar.shadowImage = UIImage()
        
        self.interactivePopGestureRecognizer?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - Gesture Recognizer Delegate

extension RNBaseNavigationController: UIGestureRecognizerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // 当导航栈中的视图控制器熟练小于等于1时,忽略 pop 手势
        if viewControllers.count <= 1{
            return false
        }
        
        return true
    }
}



extension UIBarButtonItem {
    
    
    class func createLeftBarItem(_ imageName: String = "nav_back", isUrl: Bool = false, title: String? = nil, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        if let t = title {
            
            return self.itemWithTitle(imageName, isUrl: isUrl, title: t, target: target, action: action)
        }else {
            return self.itemNoTitle(imageName, isUrl: isUrl, target: target, action: action)
        }
    }
    
    class func createRightBarItem(_ imageName: String, isUrl: Bool = false, title: String? = nil, target: AnyObject?, action: Selector) -> UIBarButtonItem{
        
        let btn = UIButton(type: .custom)
        if isUrl {
            let url = URL(string: imageName)
            btn.kf.setBackgroundImage(with: url, for: .normal, placeholder: UIImage(named:"nav_share"), options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            btn.setImage(UIImage(named: imageName), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
    }
    
    class func createRightBarItemOnlyTitle(_ title: String , target: AnyObject?, action: Selector) -> UIBarButtonItem{
        
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
    }
    
    class func itemWithTitle(_ imageName: String = "nav_back", isUrl: Bool = false, title: String, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        
       // let mView = UIView()
        
        let backView = RNBackView()
        backView.backgroundColor = UIColor.clear
        backView.isUserInteractionEnabled = true
        backView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 70, height: 44)
//        mView.addSubview(backView)
//        backView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.height.equalTo(44)
//            make.trailing.greaterThanOrEqualTo(0)
//        }
//        if #available(iOS 11.0, *) {
//            backView.
//        }
        
        let tap = UITapGestureRecognizer(target: target, action: action)
        backView.addGestureRecognizer(tap)
        
        
        let btn = UIButton(type: .custom)
        if isUrl {
            let url = URL(string: imageName)
            btn.kf.setBackgroundImage(with: url, for: .normal, placeholder: UIImage(named:"nav_back"), options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            btn.setImage(UIImage(named:"nav_back"), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .left
        btn.imageView?.isUserInteractionEnabled = true
//       // btn.frame = CGRect(x: 8, y: 2, width: 40, height: 40)
//        btn.titleLabel?.text =  title != "" ? title : "返回"
//        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.titleLabel!.frame.size.width + 2.5, 0, -(btn.titleLabel!.frame.size.width + 2.5))
//        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -(btn.currentImage!.size.width), 0, btn.currentImage!.size.width)
        //
        backView.addSubview(btn)
     //   btn.sizeToFit()
      
        btn.snp.makeConstraints { (make) in
            //make.top.equalTo(0)
            if #available(iOS 11, *) {
              make.leading.equalTo(-16)
            }else{
              make.leading.equalTo(-8)
            }
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.centerY.equalTo(backView.snp.centerY)
        }
        
//
       // let t = "才华有限公司才华有限公司才华有限公司"
//        let myWidth = t.sizeWithText(text: (t as NSString), font: UIFont.systemFont(ofSize: 16), size: CGSize(width: Double(MAXFLOAT), height: 40.0)).size.width
//        let paading = SCREEN_WIDTH - 12 - 30 - 45
        
        let label = UILabel()
        label.text = title //"问题来了,我模拟器是iphone6,cell宽度理论上是375,这里320是xib中的宽度,backview的宽度是300,剪裁后就在右边空出一片问题来了,我模拟器是iphone6,cell宽度理论上是375,这里320是xib中的宽度,backview的宽度是300,剪裁后就在右边空出一片"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .left
        
//        if myWidth >= paading {
//           label.font = UIFont.systemFont(ofSize: 16)
//        }else{
//           label.font = UIFont.systemFont(ofSize: 17)
//        }
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        backView.addSubview(label)

        //        label.isUserInteractionEnabled = true
        //        let tap = UITapGestureRecognizer(target: target, action: action)
        //        label.addGestureRecognizer(tap)


        label.snp.makeConstraints { (make) in
            make.leading.equalTo(btn.snp.trailing).offset(0)
            make.trailing.lessThanOrEqualTo(-5)
            make.height.equalTo(40)
            make.centerY.equalTo(backView.snp.centerY)
        }

        return UIBarButtonItem(customView: backView)
    }
    
    class func itemNoTitle(_ imageName: String = "nav_back", isUrl: Bool = false,target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .custom)
        if isUrl {
            let url = URL(string: imageName)
            btn.kf.setBackgroundImage(with: url, for: .normal, placeholder: UIImage(named:"nav_back"), options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            btn.setImage(UIImage(named:"nav_back"), for: .normal)
        }
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.sizeToFit()

        return UIBarButtonItem(customView: btn)
    }
}

extension UIView {
    
}
