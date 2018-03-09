//
//  RNPartViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/4.
//  Copyright © 2017年 roni. All rights reserved.
//

// TO DO : 这是一个很糟糕的控制器

import UIKit
import RealmSwift
import ESPullToRefresh

class RNPartViewController: RNBaseTableViewController {
    
    var tableView: UITableView!
    var toolView: RNShopBusView?
    var endPoint: CGPoint = CGPoint(x: 8+27.5, y: SCREEN_HEIGHT-5-27.5)
    
    lazy var dataSource: [PartModel] = {
        let array = realmQueryModel(Model: PartModel.self, condition: { (results) -> Results<PartModel>? in
            
            return results // 从数据库中拉取所有配件
        })
        
        if let items = array {
            var arr = [PartModel]()
            for item in items {
                
                arr.append(item)
            }
            return arr.map({ (model) -> PartModel in
                return model.copy() as! PartModel
            })
            
        }else{
            return [PartModel]()
        }
        
    }()
    
    var hasAmount: Int = 0 // 总件数
    var hasMoney: Double = 0.0 // 总钱数
    
    var keyWindow = UIApplication.shared.keyWindow
    var window: UIWindow?
    var hudVC: RNTipHudViewController?
    
    var orderWindow: UIWindow?
    var showView:RNSelectedProductView?
    
    var alertWindow: UIWindow?
    //
    //    lazy var selectedProducts: [PartModel] = {
    //        return [PartModel]()
    //    }()
    
    // 正式调用时使用的初始化方法
    var selectedProducts: [PartModel] // 已选配件
    var dataCallBack: (([PartModel]) ->()) // 数据回调
    
    var searchBar: UISearchBar?
    var searchController: UISearchController! // 搜索vc
    var searchResults:[PartModel] = [PartModel]() //搜索结果
    
    
    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    var searchSting: String? = nil // 搜索字段
    
    var isLoading = false
    
    init(selectedProducts selected: [PartModel], callBack backClousure: @escaping ([PartModel]) ->()) {
        self.selectedProducts = selected
        self.dataCallBack = backClousure
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "配件使用", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("取消搜索", target: self, action: #selector(cancelAction))
        
        //        // 模拟一段数据
        //        for i in 0...30 {
        //            let model = PartModel()
        //            model.productId = "\(i)"
        //            model.productName = "L型变径管\(i)"
        //            model.productModel = "1.0.3423.433"
        //            model.productPrice = String(format: "%d", 40+i)
        //            model.productAmount = 0
        //            model.productImageUrl = "http://upload-images.jianshu.io/upload_images/565029-013002ee76523276.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"
        //
        //            dataSource.append(model)
        //        }
        if dataSource.count > 0 {
            dealData()
        }
        
        setupUI()
        
        setupSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - custom methods

extension RNPartViewController {
    
    func setupUI() {
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60 - 64), style: .grouped)
        }else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: .grouped)
        }
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNPartCell", bundle: nil), forCellReuseIdentifier: "RNPartCell")
        
        toolView = Bundle.main.loadNibNamed("RNShopBusView", owner: nil, options: nil)?.last as? RNShopBusView
        toolView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
        toolView?.isOpaque = false
        
        let header: ESRefreshHeaderAnimator = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        let footer: ESRefreshFooterAnimator = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        
        header.pullToRefreshDescription = "下拉可以刷新"
        header.releaseToRefreshDescription = "松手刷新"
        header.loadingDescription = "刷新中..."
        
        footer.loadingMoreDescription = "加载更多"
        footer.loadingDescription = "加载中..."
        footer.noMoreDataDescription = "没有更多数据了"
        
        tableView.es.addPullToRefresh(animator: header){ [weak self] in
            self?.refresh()
        }
        tableView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expiredTimeInterval = 0.1 // 刷新过期时间

        
        
        if dataSource.count == 0 { // 数据为空时自动刷新 - 有数据时需要手动刷新
            self.tableView.es.autoPullToRefresh() // 自动刷新
        }
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            self.tableView.es.autoPullToRefresh() // 自动刷新
//        }
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)

        
        if let tool = toolView {
            view.addSubview(tool)
        }
        
        self.toolView?.amountLabel.text = String(format: "共 %d 件", self.hasAmount)//"共 \(String(describing: self?.hasAmount)) 件"
        self.toolView?.priceLabel.text = String(format: "¥ %.2lf", self.hasMoney)
        
        // TO DO: - 这段代码真糟糕
        toolView?.shopBusClosure = { [weak self] in
            
            if let t = self?.toolView, t.isOpen != true {
                
                guard let count = self?.selectedProducts.count, count > 0 else {
                    return
                }
                
                self?.toolView?.isOpen = !self!.toolView!.isOpen
                
                self?.keyWindow = UIApplication.shared.keyWindow
                
                let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-60))
                view.backgroundColor = UIColor.color(77, green: 77, blue: 77, alpha: 0.3)
                
                self?.orderWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-60))
                self?.orderWindow?.addSubview(view)
                self?.orderWindow?.windowLevel = UIWindowLevelNormal
                self?.view.insertSubview(self!.orderWindow!, belowSubview: self!.toolView!)
                
                self?.showView = RNSelectedProductView(self!.selectedProducts)
                self?.showView?.delegate = self
                var height: CGFloat = CGFloat(self!.selectedProducts.count * 44 + 44)
                if height > SCREEN_HEIGHT*0.6 {
                    height = SCREEN_HEIGHT*0.6
                }
                
                self?.showView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 0)
                //                self.showView.backgroundColor = UIColor.red
                view.addSubview(self!.showView!)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self?.orderWindow?.makeKeyAndVisible()
                    self?.showView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT - height - 60, width: SCREEN_WIDTH, height: height)
                })
                
                let tap01 = UITapGestureRecognizer(target: self, action: #selector(self?.tapAction))
                view.addGestureRecognizer(tap01)
                
                let tap02 = UITapGestureRecognizer(target: self, action: #selector(self?.tapAction))
                self?.toolView?.addGestureRecognizer(tap02)
                
            }else{
                self?.hideMenu()
            }
            
        }
        
        toolView?.submitClosure = {
            self.hideMenu()
            // 返回并提交选择的配件
            
            let arr = self.selectedProducts.map({ (item) -> PartModel in
                return item.copy() as! PartModel
            })
            self.dataCallBack(arr)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupSearchController (){
        
        //        searchController = UISearchController(searchResultsController: nil)
        //       // searchController.searchResultsUpdater = self
        //        searchController.searchBar.sizeToFit()
        //        searchController.searchBar.delegate = self
        //       // searchController.searchBar.barTintColor = UIColor(red: 0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        //        tableView.tableHeaderView = searchController.searchBar
        //
        //        definesPresentationContext = true // 保证在UISearchController在激活状态下用户push到下一个view controller之后search bar不会仍留在界面上
        //
        //        searchController.searchBar.delegate = self
        
        searchBar = UISearchBar()
        searchBar?.sizeToFit()
        searchBar?.delegate = self
        tableView.tableHeaderView = searchBar
        
    }
    
    
    func dealData() {
        
        // 重置
        hasAmount = 0 // 总件数
        hasMoney = 0.0 // 总钱数
        
        let arr = dataSource.map { (model) -> PartModel in
            
            var newModel = model
            _ = selectedProducts.map({ (m) -> PartModel in
                
                if !m.isInvalidated {
                    if m.productId == newModel.productId {
                        newModel = m
                    }
                }
                
                return m
            })
            
            return newModel
        }
        
        _ = selectedProducts.map({ (m) -> PartModel in
            
            if !m.isInvalidated {
                self.hasMoney +=  (Double(m.productPrice ?? "0.0") ?? 0.0) * Double(m.productAmount)
                self.hasAmount += m.productAmount
            }
            return m
        })
        
        
        dataSource = arr
        
        self.toolView?.amountLabel.text = String(format: "共 %d 件", self.hasAmount)//"共 \(String(describing: self?.hasAmount)) 件"
        self.toolView?.priceLabel.text = String(format: "¥ %.2lf", self.hasMoney)
        
    }
    
    func parameters() {
        
        parameter["search"] = searchSting
        parameter["Pagesize"] = pagesize
        parameter["Pageindex"] = page
    }
    
    func refresh() {
        
        page = 1
        
        parameters() // 更新入参
        
        isLoading = !isLoading
        
      //  tableView.es.resetNoMoreData()
        
        OrderServicer.getPartInfo(parameter, successClourue: { (result) in
            
            //  RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            
            self.isLoading = !self.isLoading
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
            self.dealData()
            
            //  self.searchController.isActive = false
            
            self.tableView.reloadData()
            
        }) { (msg, code) in
            
            self.isLoading = !self.isLoading
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
        
        page += 1
        
        parameters()
        
        
        OrderServicer.getPartInfo(parameter, successClourue: { (result) in
            
            self.tableView.es.stopLoadingMore()
            
            // 过滤重复数据 -- 这个做法很不好,需要解决数据库删除问题
            let r = result.filter({ (item) -> Bool in
                
                var isDifferent = false
                _  = self.dataSource.map({ (d) -> PartModel in
                    if item.productId != d.productId{
                        isDifferent = true
                    }
                    return d
                })
                
                return isDifferent
            })
            
            self.dataSource.append(contentsOf: r)
            
            if result.count < 20 {
                
                self.tableView.es.noticeNoMoreData()
            }
            
            
            self.dealData()
            
            self.tableView.reloadData()
            
        }) { (msg, code) in
            
            self.page -= 1 // 加载失败页面索引取消 + 1 操作
            
            self.tableView.es.stopLoadingMore()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    
    @objc func tapAction() {
        hideMenu()
    }
    
    func hideMenu() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.showView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 0)
            self.toolView?.isOpen = !self.toolView!.isOpen
            self.orderWindow?.alpha = 0
            self.orderWindow = nil
            self.keyWindow?.makeKeyAndVisible()
            
        })
        
    }
    
    @objc func dismissFromVC(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelAction(){
        
        searchBar?.text = ""
        searchBar?.resignFirstResponder()
        self.searchSting = nil
        tableView.es.autoPullToRefresh()
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNPartViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNPartCell", for: indexPath)
        
        let model = dataSource[indexPath.row]
        
        if let cell = cell as? RNPartCell {
            
            if !model.isInvalidated {
                
                cell.configCell(model: model)
                cell.addCallBack = { [weak self](sender, model) in
                    
                    self?.hasAmount += 1
                    if let price = model.productPrice, let p = Double(price) {
                        self?.hasMoney += p
                    }
                    
                    
                    let someModel = self?.selectedProducts.filter({ (m) -> Bool in
                        if m.productId ==  model.productId{ return true }
                        return false
                    }).last
                    
                    // Warning: 修改数据库数据属性 --- 随意更改会崩溃, begin, commit
                    let realm = try! Realm() // 获取默认的 realm 实例
                    realm.beginWrite()
                 
                    // 修改已选配件
                    if let m = someModel {
                        m.productAmount += 1
                        
                    }else{
                        model.productAmount = 1
                        self?.selectedProducts.append(model)
                    }
                    
                    do {
                        try realm.commitWrite()
                    }
                    catch{
                        print("====数据库写入错误")
                    }
                    
                    
                    self?.toolView?.amountLabel.text = String(format: "共 %d 件", self?.hasAmount ?? 0)//"共 \(String(describing: self?.hasAmount)) 件"
                    self?.toolView?.priceLabel.text = String(format: "¥ %.2lf", self?.hasMoney ?? 0.00)
                    
                    var rect = tableView.rectForRow(at: indexPath)
                    rect.origin.y = rect.origin.y - tableView.contentOffset.y
                    
                    var startRect = sender.frame
                    startRect.origin.y = rect.origin.y + startRect.origin.y
                    RNParabolaAnimation().startAnimation(view: sender, startRect: startRect, finishedPoint: self!.endPoint, duration: 1.0, finishedClosure: { (finished) in
                        let btn = self!.toolView!.shopBusButton!
                        RNParabolaAnimation.shakeAnimation(shakeView: btn)
                    })
                }
                
                cell.subCallBack =  { [weak self](sender, model) in
                    
                    self?.hasAmount -= 1
                    if let price = model.productPrice, let p = Double(price) {
                        self?.hasMoney -= p
                    }
                    
                    let realm = try! Realm() // 获取默认的 realm 实例
                    realm.beginWrite()
                    let someModel = self?.selectedProducts.filter({ (m) -> Bool in
                        if m.productId ==  model.productId{ return true }
                        return false
                    }).last
                    
                    if let m = someModel {
                        m.productAmount -= 1
                    }
                    do {
                        try realm.commitWrite()
                    }
                    catch{
                        print("====数据库写入错误")
                    }
                    
                    // 修改已选配件
                    let tmp = self?.selectedProducts.map({ (m) -> PartModel in
                        if m.productId ==  model.productId{
                            return model
                        }
                        
                        return m
                    })
                    
                    if let t = tmp {
                        var f = [PartModel]()
                        for item in t {
                            if item.productAmount > 0 {
                                f.append(item)
                            }
                        }
                       self?.selectedProducts = f
                    }
                    
                    
                    self?.toolView?.amountLabel.text = String(format: "共 %d 件", self?.hasAmount ?? 0)//"共 \(String(describing: self?.hasAmount)) 件"
                    self?.toolView?.priceLabel.text = String(format: "¥ %.2lf", self?.hasMoney ?? 0.00)
                    
                }
                
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.row]
        if model.isInvalidated {
            return
        }
        
        let view = Bundle.main.loadNibNamed("RNPartInfoView", owner: nil, options: nil)?.last as! RNPartInfoView
        // h + 13 + 60
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-250)//SCREEN_HEIGHT-250
        view.center = CGPoint(x: SCREEN_BOUNDS.width * 0.5, y: SCREEN_BOUNDS.height * 0.5)
        view.config(model: model)
        hudVC = RNTipHudViewController(view)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowLevel = UIWindowLevelNormal
        window?.rootViewController = hudVC
        hudVC?.appWindow = UIApplication.shared.keyWindow
        
        hudVC?.callBack = { [weak self] in
            self?.window = nil
        }
        
        window?.makeKeyAndVisible()
    }
}

// RNSelectedProductViewProtocol
extension RNPartViewController: RNSelectedProductViewProtocol {
    
    func deleteAll() {
        
        let vc = RNWindowViewController()
        vc.callBack = { [weak self] in
            
            self?.alertWindow = nil
            
            self?.selectedProducts.removeAll()
            self?.hideMenu()
            self?.hasMoney = 0.00
            self?.hasAmount = 0
            self?.toolView?.amountLabel.text = String(format: "共 %d 件", self?.hasAmount ?? 0)//"共 \(String(describing: self?.hasAmount)) 件"
            self?.toolView?.priceLabel.text = String(format: "¥ %.2lf", self?.hasMoney ?? 0.0)
            
            let realm = try! Realm() // 获取默认的 realm 实例
            realm.beginWrite()
            let arr = self?.dataSource.map { (model) -> PartModel in
                model.productAmount = 0
                return model
            }
            do {
                try realm.commitWrite()
            }
            catch{
                print("====数据库写入错误")
            }
            self?.dataSource = arr!
            self?.tableView.reloadData()
        }
        
        vc.cancelBack = { [weak self] in
            self?.alertWindow = nil
        }
        
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.windowLevel = UIWindowLevelNormal
        alertWindow?.rootViewController = vc
        vc.appWindow = UIApplication.shared.keyWindow
        alertWindow?.makeKeyAndVisible()
        
        
    }
    
    func addAction(_ model: PartModel) {
        
        if model.isInvalidated {
            return
        }
        
        hasAmount += 1
        if let price = model.productPrice, let p = Double(price) {
            hasMoney -= p
        }
        toolView?.amountLabel.text = String(format: "共 %d 件", hasAmount)//"共 \(String(describing: self?.hasAmount)) 件"
        toolView?.priceLabel.text = String(format: "¥ %.2lf", hasMoney)
        
        let a = selectedProducts.map { (m) -> PartModel in
            if m.productId == model.productId {
                m.productAmount = model.productAmount
            }
            return m
        }
        selectedProducts = a
        
        var changeIndex: Int? = nil
        let realm = try! Realm() // 获取默认的 realm 实例
        realm.beginWrite()
        let arr = dataSource.enumerated().map { (index, m) -> PartModel in
            if m.productId == model.productId {
                m.productAmount = model.productAmount
                changeIndex = index
            }
            
            return m
        }
        do {
            try realm.commitWrite()
        }
        catch{
            print("====数据库写入错误")
        }
        
        self.dataSource = arr
        
        // 刷新
        if let c = changeIndex {
            let indexpath = IndexPath(row: c, section: 0)
            self.tableView.reloadRows(at: [indexpath], with: .none)
        }
        
    }
    
    func subAction(_ model: PartModel, _ isDeleteRow: Bool) {
        
        if model.isInvalidated {
            return
        }
        
        hasAmount -= 1
        if let price = model.productPrice, let p = Double(price) {
            hasMoney -= p
        }
        toolView?.amountLabel.text = String(format: "共 %d 件", hasAmount)//"共 \(String(describing: self?.hasAmount)) 件"
        toolView?.priceLabel.text = String(format: "¥ %.2lf", hasMoney)
        
        let realm = try! Realm() // 获取默认的 realm 实例
        realm.beginWrite()
        if isDeleteRow {
            
            // 删除选中配件组中的对应 model
            var arr = [PartModel]()
            let _ = selectedProducts.map { (m) -> PartModel in
                if m.productId != model.productId {
                    arr.append(m)
                }
                return m
            }
            selectedProducts = arr
            
        }else{
            
            let a = selectedProducts.map { (m) -> PartModel in
                if m.productId == model.productId {
                    m.productAmount = model.productAmount
                }
                return m
            }
            selectedProducts = a
        }
        
        
        var changeIndex: Int? = nil
        let arr = dataSource.enumerated().map { (index, m) -> PartModel in
            if m.productId == model.productId {
                m.productAmount = model.productAmount
                changeIndex = index
            }
            
            return m
        }
        
        do {
            try realm.commitWrite()
        }
        catch{
            print("====数据库写入错误")
        }
        
        self.dataSource = arr
        
        // 刷新
        if let c = changeIndex {
            let indexpath = IndexPath(row: c, section: 0)
            self.tableView.reloadRows(at: [indexpath], with: .none)
        }
        
        if isDeleteRow {
            
            // 当选中配件组为空时, 隐藏已选列表
            if selectedProducts.count == 0 {
                hideMenu()
            }
        }
    }
}


// UISearchResultsUpdating

//extension RNPartViewController: UISearchResultsUpdating{
//
//}

//  UISearchBarDelegate

extension RNPartViewController:  UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchSting = searchBar.text
        searchBar.resignFirstResponder()
         tableView.es.autoPullToRefresh()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchSting = nil
        tableView.es.autoPullToRefresh()
    }
}

