
//
//  RNMainViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import swiftScan

class RNMainViewController: UIViewController {
    
    //    static let shared =  RNMainViewController() // 单例
    //    private init() {
    //        super.init(nibName: nil, bundle: nil)
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var personalViewController: RNPersonalViewController?
    var initialViewController: TabPageViewController?
    
    var edgeWith: CGFloat? = DRAWERWIDTH
    
    var coverButton: UIButton?  // 遮罩按钮
    var pan: UIGestureRecognizer? // 遮罩手势
    var screenPan: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer() // 全屏右滑手势
    
    var switchViewController: UIViewController?
    
    var listCountModel: ListCountModel = ListCountModel(){
        didSet{
            let untreated: String = listCountModel.untreated > 99 ? "99+" : String(describing: listCountModel.untreated)
            let reserved: String = listCountModel.reserved > 99 ? "99+" : String(describing: listCountModel.reserved)
            //            let untreated: String = "99+"//listCountModel.untreated > 99 ? "99+" : String(describing: listCountModel.untreated)""
            //            let reserved: String = "99+"
            
            if let untreatedCell = initialViewController?.tabView.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TabCollectionCell {
                if listCountModel.untreated == 0 {
                    untreatedCell.badgeLabel.isHidden = true
                }
                else {
                    untreatedCell.badgeLabel.isHidden = false
                    untreatedCell.badgeLabel.text = untreated
                }
                
            }
            if let reservedCell = initialViewController?.tabView.collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? TabCollectionCell {
                if listCountModel.reserved == 0 {
                    reservedCell.badgeLabel.isHidden = true
                }
                else {
                    reservedCell.badgeLabel.isHidden = false
                    reservedCell.badgeLabel.text = reserved
                }
                
            }
            
        }
    }
    
    init(leftViewController: RNPersonalViewController, mainViewController: TabPageViewController, edgeWidth: CGFloat)  {
        
        super.init(nibName: nil, bundle: nil)
        // let mainVC = RNMainViewController.shared
        
        self.personalViewController = leftViewController
        self.initialViewController = mainViewController
        self.initialViewController?.mainVC = self
        self.edgeWith = edgeWidth
        
        self.view.addSubview(leftViewController.view)
        self.addChildViewController(leftViewController)
        
        self.view.addSubview(mainViewController.view)
        self.addChildViewController(mainViewController)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(OrderPushNotification)
        NotificationCenter.default.removeObserver(notificationActionForMessage)
        NotificationCenter.default.removeObserver(notificationActionForRob)
        NotificationCenter.default.removeObserver(notificationActionForString)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.personalViewController?.view.transform = CGAffineTransform(translationX: -edgeWith!, y: 0)
        
        addScreenEdgePanGestureRecognizer(view: (self.initialViewController?.view)!)
        
        initialViewController?.openDrawerBlock = { [weak  self] in
            
            self?.setupCoverButton() // 添加遮罩
            self?.initialViewController?.view.addSubview((self?.coverButton!)!)
            
            self?.openMyDrawer(duration: 1)
        }
        
        initialViewController?.qrBlock = { [weak self] in
            
            RNPermission.authorizeCameraWith(comletion: { (granted) in
                if granted {
                    if let s = self {
                        var scanManager = RNScanManager(animationImage: "qr_scan_light_green", viewController: s)
                        scanManager.delegate = s
                        scanManager.beginScan()
                    }
                }
                else {
                    RNPermission.jumpToSystemPrivacySetting()
                }
            })            
        }
        
        //        initialViewController?.pageItemPressCallBack = { [weak self] in
        //            self?.getListCount()
        //        }
        
        addObserveAction()
        setupActiveNotification() // app 进入活跃状态即请求订单数
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
        pushMeg() // 推送监听
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //    NotificationCenter.default.addObserver(self, selector: #selector(pushToString), name: NSNotification.Name(rawValue: StringPushNotificationForPush), object: nil)
        
    }
    
    private func setupActiveNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(RNMainViewController.applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.getListCount()
        }
        
    }
    
    // 观察者
    func addObserveAction() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(RNMainViewController.applicationDidBecomeActive(notification:)), name: NSNotification.Name(rawValue: LoginSuccess), object: nil) // 登陆成功
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationActionForMessage), name: NSNotification.Name(rawValue: MessageNotification), object: nil) // 指派订单通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationActionForRob), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil) // 可抢订单通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationActionForString), name: NSNotification.Name(rawValue: OrderPushNotificationString), object: nil) // 浩优推送通知
        
        // NotificationCenter.default.addObserver(self, selector: #selector(getListCount), name: NSNotification.Name(rawValue: ListCountNotification), object: nil) // 抢单成功
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: GetOrderSuccessNotification), object: nil) // 抢单成功
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: SubscibeSuccessNotification), object: nil) // 预约成功
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: NoServiceFinishOrderNotification), object: nil) // 无服务完成
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: TransferOrderSuccessNofitication), object: nil) // 转单成功
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 结单成功
        NotificationCenter.default.addObserver(self, selector: #selector(changeListCount), name: NSNotification.Name(rawValue: MessageNotificationForPush), object: nil) // 指派订单通知
    }
    
    @objc func notificationActionForMessage(){
        globalAppDelegate.showMainViewController(1)
    }
    @objc func notificationActionForRob(){
        globalAppDelegate.showMainViewController(0)
    }
    @objc func notificationActionForString(){
        globalAppDelegate.showMainViewController(-1)
    }
    
    func pushToString() {
        
        //   DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        // TO DO - present 进入浩优推送界面
        let pushStringVC = RNPushStringViewController()
        let nav = RNBaseNavigationController(rootViewController: pushStringVC)
        RNHud().showHud(nil)
        self.present(nav, animated: true, completion: {
            RNHud().hiddenHub()
        })
        //  }
        
    }
    
    
}

extension RNMainViewController {
    
    @objc func changeListCount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.getListCount()
        }
    }
    
   func getListCount() {
        OrderServicer.getOrderListCount(successClourue: { (result) in
            self.listCountModel = result
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: "未处理订单/已预约订单数获取失败", duration: 3.0)
            if let untreatedCell = self.initialViewController?.tabView.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TabCollectionCell {
                untreatedCell.badgeLabel.isHidden = true
            }
            if let reservedCell = self.initialViewController?.tabView.collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? TabCollectionCell {
                reservedCell.badgeLabel.isHidden = true
            }
        }
    }
}

// MARK: - custom methods

extension RNMainViewController {
    
    func setupCoverButton() {
        
        if coverButton == nil {
            
            let btn  = UIButton(type: .custom)
            btn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            btn.backgroundColor = UIColor.color(119, green: 119, blue: 119, alpha: 0.5)
            btn.addTarget(self, action: #selector(RNMainViewController.closeMyDrawer), for: .touchUpInside)
            
            coverButton = btn
        }
        
        addPanGestureRecognizer(view: coverButton!)
        
    }
    
    // 给遮罩添加拖拽手势
    func addPanGestureRecognizer(view: UIView) {
        
        if pan == nil {
            pan = UIPanGestureRecognizer.init(target: self, action: (#selector(panGestureRecognizer(pan:))))
            
        }
        view.addGestureRecognizer(pan!)
    }
    
    /// 创建抽屉
    ///
    /// - Parameters:
    ///   - leftViewController: 左
    ///   - mainViewController: 主
    ///   - edgeWidth: 右边空出的距离
    /// - Returns: 抽屉
    //    class func creat(_ leftViewController: RNPersonalViewController, mainViewController: TabPageViewController, edgeWidth: CGFloat) -> RNMainViewController {
    //
    //        let mainVC = RNMainViewController.shared
    //
    //        mainVC.personalViewController = leftViewController
    //        mainVC.initialViewController = mainViewController
    //        mainVC.edgeWith = edgeWidth
    //
    //        mainVC.view.addSubview(leftViewController.view)
    //        mainVC.addChildViewController(leftViewController)
    //
    //        mainVC.view.addSubview(mainViewController.view)
    //        mainVC.addChildViewController(mainViewController)
    //
    //        return mainVC
    //    }
    
    func pushMeg(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushOrederGY), name: NSNotification.Name(rawValue: OrderPushNotification), object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(HomeTableViewController.selectTabbarAction), name: NSNotification.Name(rawValue: OrderPushNotificationString), object: nil)
        
        if UserDefaults.standard.value(forKey: OrderPushNotification) as? String == OrderPushNotification {
            UserDefaults.standard.setValue(nil, forKey: OrderPushNotification)
            pushOrederGY()
        }
        //        refresh()//数据初始化
    }
    
    
    @objc func pushOrederGY() {
        
        globalAppDelegate.showMainViewController() // 收到订单推送通知重启主界面
    }
    
}
// MARK: - event response

extension RNMainViewController {
    
    // 打开抽屉
    func openMyDrawer(duration: CGFloat) {
        
        
        //        RNMessageView.shared.menuButton.isHidden = !RNMessageView.shared.menuButton.isHidden
        //        RNMessageView.shared.menuButton.onTap()
        //        RNMessageView.shared.badgeLabel.removeFromSuperview()
        
        let time = 0.2
        //        if time == 0 {
        //            time = 0.5
        //        }
        UIView.animateKeyframes(withDuration: TimeInterval(time), delay: 0, options: .calculationModeLinear, animations: {
            self.initialViewController?.view.transform = CGAffineTransform(translationX: self.edgeWith!, y: 0)
            self.personalViewController?.view.transform = CGAffineTransform.identity
        }) { (_) in
            
            //  TO DO
        }
    }
    
    // 关闭抽屉
    @objc func closeMyDrawer(duration: CGFloat) {
        
        //  RNMessageView.shared.menuButton.onTap()
        // UIApplication.shared.keyWindow?.addSubview(RNMessageView.shared.menuButton)
        //
        //        RNMessageView.shared.menuButton.isHidden = !RNMessageView.shared.menuButton.isHidden
        //        RNMessageView.shared.menuButton.onTap()
        //        UIApplication.shared.keyWindow?.addSubview(RNMessageView.shared.badgeLabel)
        
        var time = duration
        if time == 0 {
            time = 0.5
        }
        
        UIView.animateKeyframes(withDuration: TimeInterval(time), delay: 0, options: .calculationModeLinear, animations: {
            self.personalViewController?.view.transform = CGAffineTransform(translationX: -self.edgeWith!, y: 0)
            self.initialViewController?.view.transform = CGAffineTransform.identity
            
            self.coverButton?.alpha = 0
        }) { (_) in
            self.coverButton?.removeFromSuperview()
            self.coverButton = nil
            
        }
    }
    
    // 拖拽手势处理
    @objc func panGestureRecognizer(pan: UIPanGestureRecognizer) {
        
        let offsetX = pan.translation(in: pan.view).x
        
        if pan.state == .cancelled || pan.state == .failed || pan.state == .ended {
            
            if offsetX < 0 , UIScreen.main.bounds.width - self.edgeWith! + abs(offsetX) > UIScreen.main.bounds.width * 0.5{
                
                closeMyDrawer(duration: (self.edgeWith! + offsetX) / self.edgeWith! * 0.5)
                
            }else{
                
                openMyDrawer(duration: abs(offsetX) / self.edgeWith! * 0.5)
            }
            
        }else if pan.state == .changed {
            
            if offsetX < 0 , offsetX > -self.edgeWith! {
                
                initialViewController?.view.transform = CGAffineTransform.init(translationX: self.edgeWith! + offsetX, y: 0)
                personalViewController?.view.transform = CGAffineTransform.init(translationX: offsetX, y: 0)
            }
        }
    }
}
// MARK: -

extension RNMainViewController {
    
    /// 添加边缘手势
    ///
    /// - parameter view: 添加边缘手势的view
    func addScreenEdgePanGestureRecognizer(view: UIView) {
        screenPan = UIScreenEdgePanGestureRecognizer(target: self, action: (#selector(screenEdgePanGestureRecognizer(pan:))))
        screenPan.edges = UIRectEdge.left
        view.addGestureRecognizer(screenPan)
    }
    
    
    /// 边缘手势事件
    ///
    /// - parameter pan: 边缘手势
    @objc func screenEdgePanGestureRecognizer(pan: UIScreenEdgePanGestureRecognizer) {
        
        self.setupCoverButton() // 添加遮罩
        self.initialViewController?.view.addSubview(self.coverButton!)
        
        let offsetX = pan.translation(in: pan.view).x
        
        //   UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
        
        if pan.state == .cancelled || pan.state == .ended || pan.state == .failed {
            
            if offsetX > UIScreen.main.bounds.width * 0.5 {
                
                self.openMyDrawer(duration: (self.edgeWith! + offsetX) / self.edgeWith! * 1.0)
                
            }else {
                
                self.closeMyDrawer(duration: offsetX / self.edgeWith! * 1.0)
            }
        }
        else  if pan.state == .changed {
            
            if offsetX < self.edgeWith! {
                
                self.initialViewController?.view.transform = CGAffineTransform.init(translationX: offsetX, y: 0)
                self.personalViewController?.view.transform = CGAffineTransform.init(translationX: -self.edgeWith! + offsetX, y: 0)
            }
            
        }
        //  });
        
    }
    
}

// MARK: -

extension RNMainViewController {
    
    /// 选择左侧菜单进行跳转
    ///
    /// - parameter viewController: 跳转目标控制器
    func switchViewController(viewController: UIViewController) {
        
        //        RNMessageView.shared.menuButton.removeFromSuperview()
        //        RNMessageView.shared.badgeLabel.removeFromSuperview()
        
        addChildViewController(viewController)
        switchViewController = viewController
        viewController.view.transform = CGAffineTransform.init(translationX: UIScreen.main.bounds.width, y: 0)
        view.addSubview(viewController.view)
        
        UIView.animate(withDuration: 0.2) {
            viewController.view.transform = CGAffineTransform.identity
        };
        
    }
    
    /// 返回到左侧控制器
    func switchBackMainViewController() {
        
        //        UIApplication.shared.keyWindow?.addSubview(RNMessageView.shared.menuButton)
        //
        //        UIApplication.shared.keyWindow?.addSubview(RNMessageView.shared.badgeLabel)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.switchViewController?.view.transform = CGAffineTransform.init(translationX: SCREEN_WIDTH, y: 0)
        }) { (Bool) in
            self.switchViewController?.removeFromParentViewController()
            self.switchViewController?.view.removeFromSuperview()
        }
    }
    
    
}

// MARK: - UIGestureRecognizerDelegate

extension RNMainViewController: UIGestureRecognizerDelegate {
    
    func  gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        
        return true
    }
    
}

// MARK: - RNScanManagerProtocol

extension RNMainViewController: RNScanManagerProtocol {
    
    func scanFinished(scanResult: RNScanResult, error: String?) {
        
        guard error == nil else {
            RNNoticeAlert.showError("提示", body:  error!)
            return
        }
        
        var strParamets = ""
        guard let resultString = scanResult.strScanned, resultString.hasPrefix("http://") else{
            RNNoticeAlert.showError("提示", body: "扫描结果有误")
            return
        }
        let strArr = (resultString as NSString).components(separatedBy: "cardvalue=")
        if strArr.count > 1 {
            strParamets = strArr.last ?? ""
        }
        
        RNHud().showHud(nil)
        UserServicer.checkServiceTrain(["serviceid": strParamets], successClourue: { (id, kind, brand, phone) in
            RNHud().hiddenHub()
            let servicerTrainVC = ServiceTrainViewController(Guid: id, MachineKind: kind, MachineBrand: brand, Phone: phone)
            let nav = RNBaseNavigationController(rootViewController: servicerTrainVC)
            self.present(nav, animated: true, completion: { 
                //
            })
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}


