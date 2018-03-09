//
//  RNBaseViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//


// 不要随便继承此类, 此类会显示 消息按钮单例, 需要显示 消息按钮 时继承即可

import UIKit
import DZNEmptyDataSet

class RNBaseViewController: UIViewController {
    
    let items: [(icon: String, color: UIColor)] = [
        ("icon_qq", UIColor(red:0.19, green:0.57, blue:1, alpha:1)),
        ("icon_alarm", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        ("icon_alarm", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1)),
        ("icon_alarm", UIColor(red:0.51, green:0.15, blue:1, alpha:1)),
        ("icon_alarm", UIColor(red:1, green:0.39, blue:0, alpha:1)),
        ("icon_alarm", UIColor(red:0.19, green:0.57, blue:1, alpha:1)),
        ("icon_notification", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        ("icon_alarm", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1)),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // 全局消息按钮显示
        RNMessageView.shared.delegate = self
        view.addSubview(RNMessageView.shared.backView)

        
        RNMessageView.shared.badgeLabel.isHidden = true // 读取消息 -- 隐藏
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 判断本地是否有用户信息
    func judgeCondition() -> Bool{
        
        let userInfo = realmQueryResults(Model: UserModel.self).first
        guard let user = userInfo else {
            RNNoticeAlert.showError("提示", body: "未获取到用户信息,聊天功能无法使用")
            return false
        }
        guard let _ = user.userId else{
            RNNoticeAlert.showError("提示", body: "未获取到用户id,聊天功能无法使用")
            return false
        }

        return true
    }
    
    // 获取用户信息 并 初始化 udesk
    func getCurrentuserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            // 初始化 Udesk
            let organization = UdeskOrganization.init(domain: AppDomain, appKey: AppKey, appId: AppId)

            let customer = UdeskCustomer()
            guard let token = user.userId else{
                
                RNNoticeAlert.showError("提示", body: "未获取到用户id,聊天功能无法使用")
                return
            }
            customer.sdkToken = token
            
            if let name = user.realName {
                customer.nickName = name
            }else{
                customer.nickName = "未获取到姓名"
            }
            UdeskManager.initWith(organization!, customer: customer)
            
            let sdkStyle = UdeskSDKStyle.custom()
            sdkStyle?.navigationColor = MAIN_THEME_COLOR
            sdkStyle?.titleColor = UIColor.white
            
            let chat = UdeskSDKManager.init(sdkStyle: sdkStyle)
            chat?.presentUdesk(in: self, completion: nil)
            
        }) { (msg, code) in
            print("错误提示: \(msg) + \(code)")
        }
    }

}

//MARK: - RNMessageViewDelegate
extension RNBaseViewController: RNMessageViewDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = UIColor.clear
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        // set highlited image
//        let highlightedImage  = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
//        button.setImage(highlightedImage, for: .highlighted)
    //    button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        
        // 隐藏 -- 留下第0,6,7三个按钮
        let hiddenButtonIndex = [1, 2, 3, 4, 5]
        if hiddenButtonIndex.contains(atIndex) {
            button.isHidden = true
        }
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
        
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
        
        switch atIndex {
        case 0:
            if judgeCondition() {
                
                let sdkStyle = UdeskSDKStyle.custom()
                sdkStyle?.navigationColor = MAIN_THEME_COLOR
                sdkStyle?.titleColor = UIColor.white
                
                let chat = UdeskSDKManager.init(sdkStyle: sdkStyle)
                chat?.presentUdesk(in: self, completion: nil)
            }else{
                getCurrentuserInfo()
            }

        case 6:
            let pushStringVC = RNPushStringViewController()
            let nav = RNBaseNavigationController(rootViewController: pushStringVC)
            RNHud().showHud(nil)
            self.present(nav, animated: true, completion: { 
                RNHud().hiddenHub()
            })
            
            break
        case 7:
            let systemMsgVC = RNSystemMsgViewController()
            let nav = RNBaseNavigationController(rootViewController: systemMsgVC)
            RNHud().showHud(nil)
            present(nav, animated: true) {
                
                RNMessageView.shared.badgeLabel.isHidden = true // 读取消息 -- 隐藏
                RNHud().hiddenHub()
            }

            break
        default:
            break
        }
     
    }
    
}

//MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate
extension RNBaseViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let text = "提示";
//        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: MAIN_THEME_COLOR]
//        return NSAttributedString(string: text, attributes: attributes)
//        
//    }
    //描述为空的数据集
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = CGFloat(NSLineBreakMode.byWordWrapping.rawValue)
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(15.0)), NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.paragraphStyle: paragraph]
        
        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
            return NSAttributedString(string: "呃！好像网没通哦~\n请检查手机网络后重试", attributes: attributes)
        }
        return NSAttributedString(string: "您查询的内容好像没找到哦\n~请确定后重试", attributes: attributes)
    }
    ////空数据按钮图片
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
            return UIImage(named: "order_noNetwork")
        }
        return  UIImage(named: "order_noOrders")//UIImage(named: "order_emptyData")
    }
    
//    //数据集加载动画
//    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
//        let animation = CABasicAnimation(keyPath: "transform")
//        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
//        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
//        animation.duration = 0.25
//        animation.isCumulative = true
//        animation.repeatCount = MAXFLOAT
//        return animation as CAAnimation
//    }
//    //按钮标题为空的数据集
//    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
//        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(16.0)), NSForegroundColorAttributeName: (state == UIControlState.normal) ? UIColor.brown : UIColor.green]
//        return NSAttributedString(string: "重新加载", attributes: attributes)
//    }
//    
//    ////重新加载按钮背景图片
//    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
//        let image = UIImage(named: state == UIControlState.normal ? "button_background_foursquare_normal" : "button_background_foursquare_highlight")
//        return image?.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0), resizingMode: .stretch).withAlignmentRectInsets(UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0))
//        
//    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 10
    }
    
    //MARK: -- DZNEmptyDataSetDelegate
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}
