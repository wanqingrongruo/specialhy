//
//  RNWaitDealingViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation

class RNWaitDealingViewController: RNBaseViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource: [Order] = {
        
        let array = realmQueryModel(Model: Order.self, condition: { (results) -> Results<Order>? in
            
            return results.filter("state = 1") // 从数据库中拉取 待处理订单
        })
        
        if let items = array {
            
            var arr = [Order]()
            for item in items {
                
                arr.append(item)
            }
            
            return arr.map({ (model) -> Order in
                return model.copy() as! Order
            })
            
        }else{
            return [Order]()
        }
        
    }()
    
    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    
    lazy var heightCacheForIndex = {  // 高度缓存
        return [IndexPath: CGFloat]()
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupUI()
        
        addObserveAction()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - custom methods
extension RNWaitDealingViewController {
    
    func setupUI() {
        
        // 44 = tabHeight => 在 appDelegate 的 showMainViewController() 里设置
        tableView = UITableView(frame: CGRect(x: 0, y: 64 + 44, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 44), style: .grouped)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNWaitingDealingCell", bundle: nil), forCellReuseIdentifier: "RNWaitingDealingCell")
        
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
//        }
        
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
        tableView.expiredTimeInterval = 1.0 // 刷新过期时间
        
        
        //        if dataSource.count == 0 { // 数据为空时自动刷新 - 有数据时需要手动刷新
        //            self.tableView.es.autoPullToRefresh() // 自动刷新
        //        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tableView.es.autoPullToRefresh() // 自动刷新
        }
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }
    
    func parameters() {
        
        parameter["actiontype"] = OrderType.waitingDealing.rawValue
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
        // parameter["Keyword"]
    }
    
    func refresh() {
        
        page = 1
        parameters() // 更新入参
       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: ListCountNotification), object: nil) // 发送通知
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
            //  RNHud().hiddenHub()
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            self.heightCacheForIndex = [IndexPath: CGFloat]()
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
            self.tableView.reloadData()
            self.tableView.es.stopPullToRefresh()
            
        }) { (msg, code) in
            
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
        page += 1
      //  print("page: \(page)")
        
        parameters()
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            self.tableView.es.stopLoadingMore()
            self.dataSource.append(contentsOf: result)
            
            if result.count < 20 {
                DispatchQueue.main.async {
                    self.tableView.es.noticeNoMoreData()
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
        }) { (msg, code) in
            
            self.page -= 1 // 加载失败页面索引取消 + 1 操作
            
            self.tableView.es.stopLoadingMore()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    // 观察者
    func addObserveAction() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: GetOrderSuccessNotification), object: nil) // 抢单成功
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: SubscibeSuccessNotification), object: nil) // 预约成功
     //   NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: NoServiceFinishOrderNotification), object: nil) // 无服务完成
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: TransferOrderSuccessNofitication), object: nil) // 转单成功
      //  NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 结单成功
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: MessageNotificationForPush), object: nil) // 指派订单通知
    }
    
    @objc func notificationAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.es.startPullToRefresh() // 自动刷新
        }
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNWaitDealingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
        // return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let height = heightCacheForIndex[indexPath] {
//            return height
//        }
//        
//        return 180.0
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowHeight = cell.frame.size.height
        heightCacheForIndex[indexPath] = rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNWaitingDealingCell", for: indexPath)
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNWaitingDealingCell {
            // 显示
            if !model.isInvalidated {
                DispatchQueue.main.async {
                    cell.config(model: model)
                    cell.state = 1
                    cell.delegate = self
                    cell.vc = self
                }
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.section]
        
        let commonDetailVC = RNCustomOrderDetailViewController(model: model, type: OrderType.waitingDealing)
        let nav = RNBaseNavigationController(rootViewController: commonDetailVC)
        RNHud().showHud(nil)
        present(nav, animated: true) {
            RNHud().hiddenHub()
        }
    }
}

//MARK: - RNActionSheetProtocol & MapViewControllerProtocol & RecordProtocol
extension RNWaitDealingViewController: RNActionSheetProtocol, MapViewControllerProtocol, RecordProtocol{
    
    func showYoutobeActionView(array: [(image: String, title: String)]) {
        RNActionSheet.creatYoutobe(viewController: self, titles: array) { (index) in
            let num = array[index].title
            dailing(number: num)
        }
    }
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("未处理", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    func beginDailNumber(_ order: Order?, orderDetail: OrderDetail?) {
        
        guard let m = order else {
            RNNoticeAlert.showError("提示", body: "未获取到当前订单信息, 记录失败")
            return
        }
        
        guard let crmId = m.crmId else {
            RNNoticeAlert.showError("提示", body: "未获取到当前订单信息, 记录失败")
            return
            
        }
        
        
        let time = String(describing: Date())
        let params = ["CallTime": time, "CRMID": crmId]
        
        OrderServicer.recordSubscribeInfo(params, successClourue: {
            //
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}
