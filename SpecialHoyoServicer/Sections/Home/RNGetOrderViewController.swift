//
//  RNGetOrderViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation
import RealmSwift

class RNGetOrderViewController: RNBaseViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource: [Order] = {
        return [Order]()
    }()
    
    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    
    var timer: Timer?
    var notification: NotificationToken? // 数据库监听 -- 记住移除
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.setupUI()
        
        //   self.notificationForLocationModel()
        
        addObserveAction()
        
        setUpTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
//notification?.stop()
        timer?.invalidate()
        timer = nil
    }
    
    func setUpTimer() {
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(countEvent), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    // 倒计时事件
    @objc func countEvent() {
        
        for item in dataSource {
            
            item.countDown()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CountDownTime), object: nil) // 发出通知
    }
}
//MARK: - custom methods
extension RNGetOrderViewController {
    
    func setupUI() {
        
        // TO DO: - 封装成模块
        // 44 = tabHeight => 在 appDelegate 的 showMainViewController() 里设置
        tableView = UITableView(frame: CGRect(x: 0, y: 64 + 44, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 44), style: .grouped)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNGetOrderCell", bundle: nil), forCellReuseIdentifier: "RNGetOrderCell")
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        
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
        tableView.expiredTimeInterval = 3 // 刷新过期时间
        
        
        //        if dataSource.count == 0 { // 数据为空时自动刷新 - 有数据时需要手动刷新
        //            self.tableView.es.autoPullToRefresh() // 自动刷新
        //        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.es.autoPullToRefresh() // 自动刷新
        }
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }
    
    func notificationForLocationModel() {
        
        // 对象通知
        notification = realmQueryResults(Model: LocationModel.self).last?.observe({ [weak self](change) in
            switch change {
            case .change(_):
                // RNNoticeAlert.showError("提示", body: "监测到对象通知")
                self?.refresh()
            case .error(let err):
                RNNoticeAlert.showError("提示", body: err.localizedDescription)
            case .deleted:
                print("The object was deleted")
            }
        })
        
        //        notification = realmQueryResults(Model: LocationModel.self).addNotificationBlock({ [weak self](changes: RealmCollectionChange) in
        //            switch changes {
        //            case .initial(_):
        //                break
        //            case .update(_, deletions: _, insertions: _, modifications: _):
        //                RNNoticeAlert.showError("提示", body: "监测到集合通知")
        //                self?.refresh()
        //            case .error(let err):
        //                RNNoticeAlert.showError("提示", body: err.localizedDescription)
        //            }
        //        })
    }
    
    func parameters() {
        
        parameter["actiontype"] = OrderType.getOrder.rawValue
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
        //        parameter["orderby"] = "time" // "location"
        //
        //        let location = realmQueryResults(Model: LocationModel.self).last
        //
        //        //print("llll = \(location!)")
        //
        //        guard let loca = location else {
        //            RNNoticeAlert.showInfo("提示", body: "正在获取位置,请稍等")
        //            return
        //        }
        //
        //        parameter["Province"] = loca.province
        //        parameter["City"] = loca.city
        //        parameter["city"] = loca.country
        //        parameter["lat"] = loca.latitude
        //        parameter["lng"] = loca.longitude
        
    }
    
    func refresh() {
        page = 1
        
        parameters() // 更新入参
        
        //  tableView.es.resetNoMoreData()
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
            self.tableView.es.stopPullToRefresh()
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
            // 删除坐标缓存
            // realmDeleteObjectsWithoutCondition(Model: DestinationLocation.self)
            
            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
        
        page += 1
        
        parameters()
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
            self.tableView.es.stopLoadingMore()
            
            self.dataSource.append(contentsOf: result)
            
            if result.count < 20 {
                
                self.tableView.es.noticeNoMoreData()
            }
            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            
            self.page -= 1 // 加载失败页面索引取消 + 1 操作
            
            self.tableView.es.stopLoadingMore()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    // 观察者
    func addObserveAction() {
        
        //  NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: LOCATIONUPDATESUCCESS), object: nil) // 位置更新
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: GetOrderSuccessNotification), object: nil) // 抢单成功
        
        //   NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: GETORDER), object: nil)
        
        //  NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: NoServiceFinishOrderNotification), object: nil) // 无服务完成
        //  NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: TransferOrderSuccessNofitication), object: nil) // 转单成功
        //   NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 结单成功
        
        // 订单推送监听 - 刷新界面
        //    NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: MessageNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: OrderPushNotificationForPush), object: nil)
        
    }
    
    @objc func notificationAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.es.startPullToRefresh() // 自动刷新
        }
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNGetOrderViewController: UITableViewDelegate, UITableViewDataSource{
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNGetOrderCell", for: indexPath)
        
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNGetOrderCell {
            // 显示
            cell.delegate = self
            cell.config(model: model, indexPath: indexPath)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let model = dataSource[indexPath.section]
        
        let commonDetailVC = RNCustomOrderDetailViewController(model: model, type: OrderType.getOrder)
        let nav = RNBaseNavigationController(rootViewController: commonDetailVC)
        RNHud().showHud(nil)
        present(nav, animated: true) {
            RNHud().hiddenHub()
        }
    }
}


//MARK: - RNGetOrderCellProtocol & MapViewControllerProtocol
extension RNGetOrderViewController: RNGetOrderCellProtocol, MapViewControllerProtocol{
    
    func removeExpiredOrder(_ expiredOrer: Order, index: IndexPath?, callBack: () -> ()) {
        
        // 删除过期订单的位置坐标缓存
        realmDeleteObject(Model: DestinationLocation.self) { (results) -> DestinationLocation? in
            
            return  results.filter({ (model) -> Bool in
                if model.crmId == expiredOrer.crmId{
                    return true
                }
                return false
            }).last
        }
        
        for (i, value) in dataSource.enumerated() {
            
            if expiredOrer.crmId == value.crmId {
                
                dataSource.remove(at: i)
                let indexSet = NSIndexSet(index: i)
                tableView.beginUpdates()
                tableView.deleteSections(indexSet as IndexSet, with: .none)
                tableView.endUpdates()
                callBack()
            }
        }
    }
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("抢单", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
}
