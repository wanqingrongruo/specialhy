//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit
import Kingfisher

extension UISearchBar {
    open override func value(forUndefinedKey key: String) -> Any? {
        print("没找到这个key")
        return nil
    }
}

open class TabPageViewController: UIPageViewController {
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()
    open var tabItems: [(viewController: UIViewController, title: String)] = []
    
    var currentIndex: Int? {
        
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map{ $0.viewController }.index(of: viewController)
    }
    fileprivate var beforeIndex: Int = 0
    fileprivate var tabItemsCount: Int {
        return tabItems.count
    }
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    lazy  var tabView: TabView = self.configuredTabView() //fileprivate
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?
    fileprivate var tabBarTopConstraint: NSLayoutConstraint?
    
    
    // My Properties
    internal var openDrawerBlock: (() -> ())?  // 打开抽屉
    internal var qrBlock: (() -> ())? // 扫一扫
    fileprivate lazy var myNav: RNCustomNavBar = {
        
        let searchBar = UISearchBar()
        // searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = MAIN_THEME_COLOR
        // searchBar.tintColor = MAIN_THEME_COLOR
        //  searchBar.setValue(UIFont.systemFont(ofSize: 14), forKeyPath: "_placeholderLabel.font")
        searchBar.placeholder = "地址/姓名/浩优编号/工单类型"
        
        var tf = searchBar.value(forKey: "_searchField") as? UITextField
        var label = tf?.value(forKey: "_placeholderLabel") as? UILabel
        label?.font = UIFont.systemFont(ofSize: 14)
        
        //        label?.font = UIFont.systemFont(ofSize: 14)
        
        searchBar.delegate = self
        //  searchBar.isUserInteractionEnabled = false // 关闭搜索
        
        let userInfo = realmQueryResults(Model: UserModel.self).first
        
        var headImageUrl = ""
        if let user = userInfo {
            
            headImageUrl = user.headImageUrl ?? ""
            if headImageUrl.contains("http") == false {
                headImageUrl = BASEURL + headImageUrl
            }
            
        }else{
            
            self.getUserInfo()
        }
        
        
        let nav = RNCustomNavBar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: headImageUrl, rightIcon: "nav_qr", searchBar: searchBar)
        
        nav.createSearchView(target: self, leftAction: #selector(leftAction), rightAction:  #selector(rightAction))
        
        return nav
    }()
    var screenPan: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer() // 全屏右滑手势
    var mainVC: RNMainViewController?
    
    var pageItemPressCallBack: (() -> ())?  // tab 点击
    
    open static func create() -> TabPageViewController {
        let sb = UIStoryboard(name: "TabPageViewController", bundle: Bundle(for: TabPageViewController.self))
        return sb.instantiateInitialViewController() as! TabPageViewController
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(myNav)
        
        addScreenEdgePanGestureRecognizer(view: self.view)
        
        // 处理 pageView 滑动与边缘手势的冲突
        for view in self.view.subviews {
            
            if view.isKind(of: UIScrollView.self) {
                
                (view as! UIScrollView).panGestureRecognizer.require(toFail: self.screenPan)
            }
        }
        
        setupPageViewController()
        setupScrollView()
        updateNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavInfo), name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil)
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tabView.superview == nil {
            tabView = configuredTabView()
        }
        
        if let currentIndex = currentIndex , isInfinity {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateNavigationBar()
        tabView.layouted = true
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
}

//MARK: - My methods

extension TabPageViewController {
    
    /// 遮罩按钮手势的回调
    ///
    /// - parameter pan: 手势
    func panGestureRecognizer(pan: UIPanGestureRecognizer) {
        mainVC?.panGestureRecognizer(pan: pan)
    }
    
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
        
        mainVC?.screenEdgePanGestureRecognizer(pan: pan)
    }
    
    @objc func leftAction() {
        // 打开抽屉
        if openDrawerBlock != nil {
            openDrawerBlock!()
        }
    }
    @objc func rightAction() {
        // 扫一扫
        if qrBlock != nil {
            qrBlock!()
        }
    }
    
    // 获取用户信息
    func getUserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { [weak self](user) in
            
            var headImageUrl = user.headImageUrl ?? ""
            if headImageUrl.contains("http") == false {
                headImageUrl = BASEURL + headImageUrl
            }
            
            let url = URL(string: headImageUrl)
            
            self?.myNav.headButton?.kf.setImage(with: url, for: .normal, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
            
            }, failureClousure: { (msg, code) in
                RNNoticeAlert.showError("提示", body: msg)
        })
        
    }
    
    @objc func updateNavInfo(){
        let userInfo = realmQueryResults(Model: UserModel.self).first
        
        if let image = userInfo?.headImageUrl, let url = URL(string: image) {
            self.myNav.headButton?.kf.setImage(with: url, for: .normal, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
}

extension TabPageViewController: UISearchBarDelegate {
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let searchVC = RNSearchOrderViewController()
        //  let nav = RNBaseNavigationController(rootViewController: searchVC)
        self.present(searchVC, animated: false, completion: nil)
        
        return false
    }
}


// MARK: - Public Interface

public extension TabPageViewController {
    
    public func displayControllerWithIndex(_ index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        
        beforeIndex = index
        shouldScrollCurrentBar = false
        let nextViewControllers: [UIViewController] = [tabItems[index].viewController]
        
        let completion: ((Bool) -> Void) = { [weak self] _ in
            self?.shouldScrollCurrentBar = true
            self?.beforeIndex = index
        }
        
        setViewControllers(
            nextViewControllers,
            direction: direction,
            animated: animated,
            completion: completion)
        
        guard isViewLoaded else { return }
        tabView.updateCurrentIndex(index, shouldScroll: true)
    }
}


// MARK: - View

extension TabPageViewController {
    
    fileprivate func setupPageViewController() {
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
        
        setViewControllers([tabItems[beforeIndex].viewController],
                           direction: .forward,
                           animated: false,
                           completion: nil)
    }
    
    fileprivate func setupScrollView() {
        // Disable PageViewController's ScrollView bounce
        let scrollView = view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.backgroundColor = option.pageBackgoundColor
    }
    
    /**
     Update NavigationBar
     */
    
    fileprivate func updateNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(option.tabBackgroundImage, for: .default)
            navigationBar.isTranslucent = option.isTranslucent
        }
    }
    
    fileprivate func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: isInfinity, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: tabView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)
        
        let top = NSLayoutConstraint(item: tabView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: myNav,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: tabView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: tabView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        view.addConstraints([top, left, right])
        
        tabView.pageTabItems = tabItems.map({ $0.title})
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
        
        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewControllerNavigationDirection) in
            self?.displayControllerWithIndex(index, direction: direction, animated: true)
            
            // -----my code
            if index == 1 || index == 2 {
               self?.pageItemPressCallBack?()
            }
        }
        
        tabBarTopConstraint = top
        
        return tabView
    }
    
    private func setupStatusView() {
        let statusView = UIView()
        statusView.backgroundColor = option.tabBackgroundColor
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
        
        let top = NSLayoutConstraint(item: statusView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .top,
                                     multiplier:1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: statusView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: statusView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        let height = NSLayoutConstraint(item: statusView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: topLayoutGuide.length)
        
        view.addConstraints([top, left, right, height])
        
        statusViewHeightConstraint = height
        self.statusView = statusView
    }
    
    public func updateNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        guard let navigationController = navigationController else { return }
        
        switch option.hidesTopViewOnSwipeType {
        case .tabBar:
            updateTabBarOrigin(hidden: hidden)
        case .navigationBar:
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        case .all:
            updateTabBarOrigin(hidden: hidden)
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        default:
            break
        }
        if statusView == nil {
            setupStatusView()
        }
        
        statusViewHeightConstraint!.constant = topLayoutGuide.length
    }
    
    public func showNavigationBar() {
        guard let navigationController = navigationController else { return }
        guard navigationController.isNavigationBarHidden  else { return }
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }
        
        if option.hidesTopViewOnSwipeType != .none {
            tabBarTopConstraint.constant = 0.0
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration)) {
                self.view.layoutIfNeeded()
            }
        }
        
        navigationController.setNavigationBarHidden(false, animated: true)
        
    }
    
    private func updateTabBarOrigin(hidden: Bool) {
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }
        
        tabBarTopConstraint.constant = hidden ? -(20.0 + option.tabHeight) : 0.0
        UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration)) {
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - UIPageViewControllerDataSource

extension TabPageViewController: UIPageViewControllerDataSource {
    
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        
        guard var index = tabItems.map({$0.viewController}).index(of: viewController) else {
            return nil
        }
        
        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        if isInfinity {
            if index < 0 {
                index = tabItems.count - 1
            } else if index == tabItems.count {
                index = 0
            }
        }
        
        if index >= 0 && index < tabItems.count {
            return tabItems[index].viewController
        }
        
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        return nextViewController(viewController, isAfter: false)
    }
}


// MARK: - UIPageViewControllerDelegate

extension TabPageViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollCurrentBar = true
        tabView.scrollToHorizontalCenter()
        
        // Order to prevent the the hit repeatedly during animation
        tabView.updateCollectionViewUserInteractionEnabled(false)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex , currentIndex < tabItemsCount {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
            beforeIndex = currentIndex
        }
        
        tabView.updateCollectionViewUserInteractionEnabled(true)
    }
}


// MARK: - UIScrollViewDelegate

extension TabPageViewController: UIScrollViewDelegate {
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        
        //        if (velocity.x >= 0 ) && (velocity.x <= 10) {
        //             self.screenEdgePanGestureRecognizer(pan: self.screenPan)
        //        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
            
            return
        }
        
        // (0..<tabItemsCount)
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            index = beforeIndex + 1
        } else {
            index = beforeIndex - 1
        }
        
        if index == tabItemsCount {
            index = 0
        } else if index < 0 {
            index = tabItemsCount - 1
        }
        
        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }
}
