//
//  AppDelegate.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import SwiftyJSON
import Bugly

// 全局 AppDelegate
var globalAppDelegate: AppDelegate {
    
    return UIApplication.shared.delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate{
    
    var window: UIWindow?
    
    var loginVC: RNLoginViewController? // 登陆界面
    var mainViewController: RNMainViewController? // 主视图控制器
    var locationManager: RNLocationManager? = nil
    var isValidToken: Bool = true // token 是否有效 -- 默认有效
    
    var pushType: PushType?  // 推送类型
    var myApns: [AnyHashable: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        //MARK: - 数据库调试
        #if DEBUG
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                PAirSandbox.sharedInstance().enableSwipe()  // 获取沙盒文件,从屏幕右边左滑, After your key window is created, add below code
            })
        #endif
        
        
        let _ = RNListeningNetwork.shared // 网络状态监测
        
        //MARK: - 数据库
        realmMigration() // 数据库迁移 !!!!
        
        login()// 登陆
        setUpJPush(launchOptions: launchOptions) // 极光
        addJPObserve() // 极光监听
        
        
        // MARK: - Bugly
        #if DEBUG
        #else
            Bugly.start(withAppId: BuglyAppId) // 非 Debug 模式下统计
        #endif
        
        // 微信支付
        WXApi.registerApp(wxPayAppId, enableMTA: true)
        
        locationAction() // 定位
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        locationAction() // 定位
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: GETORDER), object: nil) // 发出通知
        
        application.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //        application.applicationIconBadgeNumber = 0
        //        JPUSHService.setBadge(0)
        //        application.cancelAllLocalNotifications()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // 应用间跳转回调
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }else{
            
            if url.host == "safepay" {
                //                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                //                    //
                //                })
            }
            return true
        }
    }
    
    // iOS9.0以后
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }else{
            
            if url.host == "safepay" {
                //                AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                //                    //
                //                })
            }
            return true
        }
    }
    
    
}

//MARK: - realm Migration

extension AppDelegate {
    //
}



//MARK: custom methods

extension AppDelegate {
    
    //登录
    func login(){
        
        UserServicer.loginWithLocalInfo(successClourue: {
            
            self.showMainViewController()
            
            // 初始化 Udesk
            let organization = UdeskOrganization.init(domain: AppDomain, appKey: AppKey, appId: AppId)
            
            let userInfo = realmQueryResults(Model: UserModel.self).first
            guard let user = userInfo else {
                return
            }
            
            let customer = UdeskCustomer()
            guard let token = user.userId else{
                
                RNNoticeAlert.showError("提示", body: "未获取到 id,聊天功能无法使用")
                return
            }
            customer.sdkToken = token
            
            if let name = user.realName {
                customer.nickName = name
            }else{
                customer.nickName = "未获取到姓名"
            }
            
            UdeskManager.initWith(organization!, customer: customer)
            
            //绑定极光
            guard let _ = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey), let _ =  UserDefaults.standard.object(forKey: UserIdKey) else {
                return
            }
            UserServicer.bingJpush(["notifyid": JPUSHService.registrationID()], successClourue: {
                print("极光 => 绑定通知成功")
            }) { (msg, code) in
                // RNNoticeAlert.showError("提示", body: msg)
                print("极光 => 绑定失败: code = \(code)")
            }
            
            
        }) { (msg, code) in
            print("错误信息: \(msg) + \(code)")
            
            // 登陆界面
            self.loginVC = RNLoginViewController(nibName: "RNLoginViewController", bundle: nil)
            let nav = RNBaseNavigationController(rootViewController: self.loginVC!)
            self.window?.rootViewController = nav
        }
        
    }
    
    // 切换主控制器
    func showMainViewController(_ showIndex: Int = 0) {
        
        mainViewController = nil
        
        // 不知道是否应该加上推送重建???
        //        realmMigration() // 数据库迁移 !!!!
        //        addJPObserve() // 极光监听
        //  locationAction() // 定位
        
        let inititalVC = TabPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        let getOrderVC = RNGetOrderViewController()
        let waitDealingVC = RNWaitDealingViewController()
        let subscribeVC = RNSubscribeViewController()
        let compeletedVC = RNCompletedViewController()
        
        inititalVC.tabItems = [(getOrderVC, "抢单"), (waitDealingVC, "未处理"), (subscribeVC, "已预约"), (compeletedVC, "已完成")]
        var option = TabPageOption()
        option.tabHeight = 44
        option.tabWidth = SCREEN_WIDTH / CGFloat(inititalVC.tabItems.count)
        option.hidesTopViewOnSwipeType = .none
        option.isTranslucent = false
        option.tabBackgroundColor = BACKGROUND_COLOR
        option.defaultColor = UIColor.black
        option.currentColor = UIColor.white
        option.currentBarHeight = 0.0
        inititalVC.option = option
        
        var index = showIndex
        if index < 0 || index >= inititalVC.tabItems.count {
            index = 0
        }
        
        inititalVC.displayControllerWithIndex(index, direction: .forward, animated: false) // 初始化是显示哪个页面
        
        mainViewController = RNMainViewController(leftViewController: RNPersonalViewController(), mainViewController: inititalVC, edgeWidth: DRAWERWIDTH)
        //RNMainViewController.creat(RNPersonalViewController(), mainViewController: inititalVC, edgeWidth: DRAWERWIDTH)
        // mainViewController = RNMainViewController.shared
        
        
        loginVC = nil
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
              self.updateVersion() // 版本更新
        }
      
        
        switch showIndex {
        case 0:
            NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotificationForPush), object: nil) // 可抢订单通知转发
            break
        case 1:
            NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotificationForPush), object: nil) // 指派订单通知转
        case -1:
            //           NotificationCenter.default.post(name: Notification.Name(rawValue: StringPushNotificationForPush), object: nil) // 浩优推送通知转
            break
        default:
            break
        }
        
    }
    
    // 登录操作
    func logOut() {
        
        mainViewController = nil
        
        // TO DO
        // 清除用户信息 (本地 and cookies and 数据库)
        UserDefaults.standard.removeObject(forKey: UserDefaultsUserTokenKey)
        UserDefaults.standard.removeObject(forKey: UserIdKey)
        realmDeleteAll()
        
        // 替换  window?.rootViewController = loginViewController
        self.loginVC = RNLoginViewController(nibName: "RNLoginViewController", bundle: nil)
        let nav = RNBaseNavigationController(rootViewController: self.loginVC!)
        self.window?.rootViewController = nav
    }
    
    
    func updateVersion() {
        
        // 版本号原则: 1.0.0,, 必选三位, 提交时转换成 => 100
        let version =  Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        guard let v = version else {
            return
        }
        let arr = v.components(separatedBy: ".")
        var myVersion = ""
        for item in arr {
            myVersion += item
        }
        if arr.count < 3{
            for _ in 1...(3-arr.count){
                myVersion += "0"
            }
            
        }
        
        
        guard let code = Int(myVersion) else {
            return
        }
        
        UserServicer.updateAppVersion(["code": code, "os": "ios", "appname": "浩优服务家"], successClourue: { (versionInfo) in
            
            if let _ = versionInfo {
                
                let alert = UIAlertController(title: "版本更新", message: "新版本上线,您可以前往APP Store更新", preferredStyle: .alert)
                let cancelButton = UIAlertAction(title: "取消", style: .cancel) { (_) in}
                let okButton = UIAlertAction(title: "确定", style: .default) { (_) in
                    let url = AppStoreAddress
                    if let u = URL(string: url){
                        UIApplication.shared.openURL(u)
                    }
                }
                alert.addAction(cancelButton)
                alert.addAction(okButton)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.mainViewController?.present(alert, animated: true, completion: nil)
                }
                
            }
        }) { (msg, code) in
            print("请求更新接口失败, 错误信息: \(msg):\(code)")
        }
        
    }
}

//MARK: - 关于极光推送的一些方法

extension AppDelegate {
    
    func setUpJPush(launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        
        //MARK: - 极光推送 3.0+
        // 初始化APNs
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.alert.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.sound.rawValue)
        if #available(iOS 8.0, *) {
            // 可添加自定义 categories
        }
        
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        // 初始化 JPush
        
        #if DEBUG
            JPUSHService.setup(withOption: launchOptions, appKey: JPushKey, channel: JPChannel, apsForProduction: false) // 开发环境 -- 用于开发测试
            
        #else
            JPUSHService.setup(withOption: launchOptions, appKey: JPushKey, channel: JPChannel, apsForProduction: true) // 生产环境 -- 用于发布
        #endif
        
        
        if (launchOptions != nil) {
            let remoteNotification = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification];
            UserDefaults.standard.setValue("HomeOrderNotification", forKey: OrderPushNotification)
            
            //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
            if (remoteNotification != nil) {
                print("程序在关闭情况下点击横幅")
            }
        }
        
    }
    
    // 监听
    func addJPObserve() {
        //MARK: - Jpush 监听
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidClose(_:)), name: NSNotification.Name.jpfNetworkDidClose, object: nil) //关闭连接
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidRegister(_:)), name: NSNotification.Name.jpfNetworkDidRegister, object: nil) //注册成功
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidLogin(_:)), name: NSNotification.Name.jpfNetworkDidLogin, object: nil) //登陆成功
        //   NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.JPushDidReceiveMessage(_:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil) //收到自定义消息
        
    }
    
    // 发送消息通知
    func pushSoundAction() {
        if let push = pushType {
            
            switch push {
            case .orderrob:
                NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotification), object: nil,userInfo: nil) // 可抢订单
            case .string:
                //               NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotificationString), object: nil,userInfo: nil) // 浩优通知
                let currentViewtroller = UIViewController.currentViewController()
                let pushStringVC = RNPushStringViewController()
                let nav = RNBaseNavigationController(rootViewController: pushStringVC)
                RNHud().showHud(nil)
                currentViewtroller?.present(nav, animated: true, completion: {
                    RNHud().hiddenHub()
                })
                
                
            case .ordernotify:
                // RNNoticeAlert.showInfo("温馨提示", body: "您有新的指派订单，请查看首页的待处理列表")
                NotificationCenter.default.post(name: Notification.Name(rawValue: MessageNotification), object: nil,userInfo: nil) // 指派订单
            case .score:
                break // 积分
            }
        }
        else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: OrderPushNotification), object: nil,userInfo: nil)
        }
    }
    
    // 极光推送监听事件
    func JPushDidSetup(_ noti:Notification)
    {
        print("极光 => 建立连接")
    }
    
    @objc func JPushDidClose(_ noti:Notification)  {
        print("极光 => 关闭连接")
    }
    
    @objc func JPushDidRegister(_ noti:Notification)  {
        print("极光 => 注册成功")
    }
    @objc func JPushDidLogin(_ noti:Notification)  {
        
        //绑定极光
        guard let _ = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey), let _ =  UserDefaults.standard.object(forKey: UserIdKey) else {
            return
        }
        UserServicer.bingJpush(["notifyid": JPUSHService.registrationID()], successClourue: {
            print("极光 => 绑定通知成功")
        }) { (msg, code) in
            //  RNNoticeAlert.showError("提示", body: msg)
            print("极光 => 绑定失败: code = \(code)")
        }
    }
    
    //    //MARK: - 接受自定义消息和通知消息
    //    func JPushDidReceiveMessage(_ noti:Notification)  {
    //
    //        let tmp = noti.userInfo!["content"] as! String
    //        if  let data = tmp.data(using: String.Encoding.utf8) {
    //
    //            let dic = JSON(data: data, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
    //            //  let userId = dic["MsgId"].stringValue
    //            let strNum =  realmQueryResults(Model: MessageModel.self).count
    //
    //            let model = MessageModel()
    //            model.msgId = dic["MsgId"].stringValue
    //            model.sendUserId = dic["SendUserid"].stringValue
    //            model.recvUserId = dic["RecvUserid"].stringValue
    //            model.sendNickName = dic["SendNickName"].stringValue
    //            model.messageType = dic["MessageType"].stringValue
    //            model.sendImageUrl = dic["SendImageUrl"].stringValue
    //            if model.messageType == "score" {
    //                if let imageUrl = model.sendImageUrl, imageUrl != "", (imageUrl.contains("BASEURL") == true){
    //                    model.sendImageUrl =  imageUrl
    //                } else {
    //                    model.sendImageUrl = BASEURL +  model.sendImageUrl!
    //                }
    //            } else {
    //                if model.sendImageUrl != "" {
    //                    model.sendImageUrl = BASEURL +  model.sendImageUrl!
    //                }
    //            }
    //
    //            if let typeGY = model.messageType {
    //
    //                switch  typeGY {
    //                case "string":
    //                    pushType = PushType.string
    //                case "score":
    //                    pushType = PushType.score
    //                case "ordernotify":
    //                    pushType = PushType.ordernotify
    //                case "orderrob":
    //                    pushType = PushType.orderrob
    //
    //                default:
    //                    break
    //                }
    //            }
    //            model.messageCon = dic["MessageCon"].stringValue
    //            model.createTime = dic["CreateTime"].stringValue
    //            model.messageNum = String(strNum + 1)
    //            let remark = dic["Remark"].stringValue
    //            let arr = remark.components(separatedBy: ";")
    //            model.orderId = arr.first ?? ""
    //            model.serviceItem = arr.last ?? ""
    //
    //            realmWirte(model: model)
    //
    //            let scoreModel = ScoreModel()
    //            scoreModel.msgId = dic["MsgId"].stringValue
    //            scoreModel.sendUserId = dic["SendUserid"].stringValue
    //            scoreModel.recvUserId = dic["RecvUserid"].stringValue
    //            scoreModel.sendNickName = dic["SendNickName"].stringValue
    //            scoreModel.sendImageUrl = dic["SendImageUrl"].stringValue
    //            if scoreModel.sendImageUrl != "" {
    //                scoreModel.sendImageUrl = BASEURL +  scoreModel.sendImageUrl!
    //            }
    //            scoreModel.messageCon = dic["MessageCon"].stringValue
    //            scoreModel.messageType = dic["MessageType"].stringValue
    //            scoreModel.createTime = dic["CreateTime"].stringValue
    //            scoreModel.orderId = arr.first ?? ""
    //            scoreModel.serviceItem = arr.last ?? ""
    //
    //            realmWirte(model: scoreModel)
    //
    //            print("极光 => 获取到了自定义消息")
    //            // 后台前台都进，会导致声音重复
    //            //            AudioServicesPlaySystemSound(1007)
    //            //    NotificationCenter.default.post(name: Notification.Name(rawValue: MessageNotification), object: nil, userInfo: ["messageNum": "1"])
    //
    //            //   pushSoundAction()
    //
    //        }
    //
    //    }
    
    
    func parsePushMsg(userInfo dic: [AnyHashable: Any]) {
        
        let apsDic = dic["aps"] as? [AnyHashable: Any]
        if let aps = apsDic {
            let badge = aps["badge"] as? Int
            
            if let be = badge { // 显示消息数
                
                if be > 99 {
                    RNMessageView.shared.badgeLabel.isHidden = false
                    RNMessageView.shared.badgeLabel.text = "99+"
                }else{
                    RNMessageView.shared.badgeLabel.isHidden = false
                    RNMessageView.shared.badgeLabel.text = String(describing: be)
                }
                
            }else{
                RNMessageView.shared.badgeLabel.isHidden = true
            }
        }else{
            RNMessageView.shared.badgeLabel.isHidden = true
        }
        
        let payload = dic["payload"] as? String
        
        guard let pay = payload else {
            return
        }
        let p = pay.replacingOccurrences(of: "\\", with: "")
        if  let data = p.data(using: String.Encoding.utf8) {
            
            let dic = try! JSON(data: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            //  let userId = dic["MsgId"].stringValue
            
            let type = dic["MessageType"].stringValue
            switch  type {
            case "string":
                pushType = PushType.string // 普通消息
                getString(dic: dic)
            case "score":
                pushType = PushType.score // 积分
                getScore(dic: dic)
            case "ordernotify":
                pushType = PushType.ordernotify // 指派订单
                getMessage(dic: dic)
            case "orderrob":
                pushType = PushType.orderrob // 可抢订单
                getMessage(dic: dic)
                
            default:
                break
            }
            
            
        }
        
    }
    
    func getMessage(dic: JSON) {
        
        let strNum =  realmQueryResults(Model: MessageModel.self).count
        
        let model = MessageModel()
        model.msgId = dic["MsgId"].stringValue
        model.sendUserId = dic["SendUserid"].stringValue
        model.recvUserId = dic["RecvUserid"].stringValue
        model.sendNickName = dic["SendNickName"].stringValue
        model.messageType = dic["MessageType"].stringValue
        model.sendImageUrl = dic["SendImageUrl"].stringValue
        
        if model.messageType == "score" {
            if let imageUrl = model.sendImageUrl, imageUrl != "", (imageUrl.contains("BASEURL") == true){
                model.sendImageUrl =  imageUrl
            } else {
                model.sendImageUrl = BASEURL +  model.sendImageUrl!
            }
        } else {
            if model.sendImageUrl != "" {
                model.sendImageUrl = BASEURL +  model.sendImageUrl!
            }
        }
        
        model.messageCon = dic["MessageCon"].stringValue
        model.createTime = dic["CreateTime"].stringValue
        model.messageNum = String(strNum + 1)
        let remark = dic["Remark"].stringValue
        let arr = remark.components(separatedBy: ";")
        model.orderId = arr.first ?? ""
        model.serviceItem = arr.last ?? ""
        
        realmWirte(model: model)
        
    }
    
    func getScore(dic: JSON) {
        
        let strNum =  realmQueryResults(Model: MessageModel.self).count
        
        let scoreModel = ScoreModel()
        scoreModel.msgId = dic["MsgId"].stringValue
        scoreModel.sendUserId = dic["SendUserid"].stringValue
        scoreModel.recvUserId = dic["RecvUserid"].stringValue
        scoreModel.sendNickName = dic["SendNickName"].stringValue
        scoreModel.sendImageUrl = dic["SendImageUrl"].stringValue
        if scoreModel.sendImageUrl != "" {
            scoreModel.sendImageUrl = BASEURL +  scoreModel.sendImageUrl!
        }
        scoreModel.messageCon = dic["MessageCon"].stringValue
        scoreModel.messageType = dic["MessageType"].stringValue
        scoreModel.createTime = dic["CreateTime"].stringValue
        scoreModel.messageNum = String(strNum + 1)
        let remark = dic["Remark"].stringValue
        let arr = remark.components(separatedBy: ";")
        
        scoreModel.orderId = arr.first ?? ""
        scoreModel.serviceItem = arr.last ?? ""
        
        realmWirte(model: scoreModel)
        
    }
    
    // 普通消息
    func getString(dic: JSON) {
        
        let strNum =  realmQueryResults(Model: PushStringModel.self).count
        
        let stringModel = PushStringModel()
        stringModel.msgId = dic["MsgId"].stringValue
        stringModel.sendUserId = dic["SendUserid"].stringValue
        stringModel.recvUserId = dic["RecvUserid"].stringValue
        stringModel.sendNickName = dic["SendNickName"].stringValue
        stringModel.sendImageUrl = dic["SendImageUrl"].stringValue
        if stringModel.sendImageUrl != "" {
            stringModel.sendImageUrl = BASEURL +  stringModel.sendImageUrl!
        }
        stringModel.messageCon = dic["MessageCon"].stringValue
        stringModel.messageType = dic["MessageType"].stringValue
        stringModel.createTime = dic["CreateTime"].stringValue
        stringModel.messageNum = String(strNum + 1)
        let remark = dic["Remark"].stringValue
        let arr = remark.components(separatedBy: ";")
        
        stringModel.orderId = arr.first ?? ""
        stringModel.serviceItem = arr.last ?? ""
        
        realmWirte(model: stringModel)
    }
    
    
}
//MARK: - 推送代理JPUSHRegisterDelegate

extension AppDelegate: JPUSHRegisterDelegate {
    
    // 注册APNs成功并上报DeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("极光 => deviceToken: \(deviceToken)")
        JPUSHService.registerDeviceToken(deviceToken)
        print("极光 => 注册设备成功")
    }
    //实现注册APNs失败接口
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("极光 => 通知注册失败 with error: \(error)")
    }
    
    // JPUSHRegisterDelegate, 以上不是这个的代理方法
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        
        if let trigger = notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self){
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
        parsePushMsg(userInfo: userInfo)  // 解析后台传递的数据 -- app在前台时
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue)); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|
    }
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        let userInfo = response.notification.request.content.userInfo
        
        parsePushMsg(userInfo: userInfo)  // 解析后台传递的数据 -- app在后台时
        pushSoundAction() // 发通知跳转
        completionHandler() // 系统要求执行这个方法
    }
    
    // iOS 6 or earlier support
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print("iOS 6: 程序在前台 \(userInfo) ")
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    // iOS 7 support
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // print("======state: \(String(describing: application.applicationState))")
        
        switch application.applicationState {
        case .active:
            parsePushMsg(userInfo: userInfo)  // 解析后台传递的数据 -- app在前台时
            completionHandler(UIBackgroundFetchResult.newData)
            
        case .background:
            JPUSHService.handleRemoteNotification(userInfo)
            
            parsePushMsg(userInfo: userInfo)  // 解析后台传递的数据 -- app在后台时
            pushSoundAction() // 发通知跳转
            
            completionHandler(UIBackgroundFetchResult.newData)
        default:
            JPUSHService.handleRemoteNotification(userInfo)
            
            parsePushMsg(userInfo: userInfo)  // 解析后台传递的数据 -- app在后台时
            pushSoundAction() // 发通知跳转
            completionHandler(UIBackgroundFetchResult.newData)
        }
        
    }
    
}

// MARK: - 微信支付回调
extension AppDelegate {
    
    // 微信支付回调
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: PayResp.self) {
            let response = resp as! PayResp
            switch  response.errCode {
            case WXSuccess.rawValue:
                
                // 发出微信支付成功通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: WEIXINPAYSUCCESS), object: nil)
                break
                
            default:
                
                // 发出微信支付失败通知
                NotificationCenter.default.post(name: Notification.Name(rawValue: WEIXINPAYFAIL), object: nil)
                
                break
                
            }
            
        }
    }
    
}

//MARK: - location

extension AppDelegate {
    
    // 定位
    func locationAction() {
        
        if locationManager == nil {
            locationManager = RNLocationManager()
        }
        
        locationManager?.errorBlock = { errorMsg in
            RNNoticeAlert.showError("提示", body:  errorMsg)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LOCATIONUPDATEFAIL), object: nil) // 发出通知
        }
        
        locationManager?.coordinateBlock = { (location) in
            
            let locationModel = realmQueryResults(Model: LocationModel.self).last
            
            if let loca = locationModel {
                realmUpdate(Model: LocationModel.self, value: ["id": loca.id!, "latitude": location.latitude, "longitude": location.longitude])
            }else{
                
                let model = LocationModel()
                model.id = "9999"
                model.latitude = location.latitude
                model.longitude = location.longitude
                
                realmWirte(model: model)
            }
            
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: LOCATIONUPDATESUCCESS), object: nil) // 发出通知
            //            let m = realmQueryResults(Model: LocationModel.self).last
            //            print("cb====\(m!)")
        }
        locationManager?.addressInfoBlock = { (province, city, area) in
            
            let locationModel = realmQueryResults(Model: LocationModel.self).last
            
            if let loca = locationModel {
                realmUpdate(Model: LocationModel.self, value: ["id": loca.id!, "province": province, "city": city, "country": area])
            }else{
                
                let model = LocationModel()
                model.id = "9999"
                model.province = province
                model.city = city
                model.country = area
                
                realmWirte(model: model)
            }
            
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: LOCATIONUPDATESUCCESS), object: nil) // 发出通知
            
            //            let m = realmQueryResults(Model: LocationModel.self).last
            //            print("ab====\(m!)")
        }
        locationManager?.geocoderError = { errorMsg in
            
            // RNNoticeAlert.showError("提示", body:  errorMsg, duration: 3.0)
        }
        
        locationManager?.startLocation()
    }
    
}


