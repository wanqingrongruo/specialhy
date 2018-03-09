//
//  RNWaitPayViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation

class RNWaitPayViewController: RNModelTableViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource: [Order] = {
        
        let array = realmQueryModel(Model: Order.self, condition: { (results) -> Results<Order>? in
            
            return results.filter("state = 4") // 从数据库中拉取 待处理订单
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
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "个人中心", target: self, action: #selector(dismissFromVC))]
        
        setupUI()
        
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never//UIScrollView也适用
//        }else {
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
        
        addObserveAction()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissFromVC(){
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    // 观察者
    func addObserveAction() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: PaySuccessNotification), object: nil) // 结单成功
    }
    
    
    @objc func notificationAction(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.tableView.es.startPullToRefresh() // 自动刷新
        }
    }


}

//MARK: - custom methods
extension RNWaitPayViewController {
    
    func setupUI() {
        
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .grouped)
        }else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNCompletedCell", bundle: nil), forCellReuseIdentifier: "RNCompletedCell")
        
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
        
        //  self.tableView.es.autoPullToRefresh()
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
        
        parameter["actiontype"] = OrderType.waitPay.rawValue
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
    }
    
    func refresh() {
        
        page = 1
        
        parameters() // 更新入参
        
        //   tableView.es.resetNoMoreData()
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
            //  RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
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
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNWaitPayViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNCompletedCell", for: indexPath)
        
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNCompletedCell {
            // 显示
            
            if !model.isInvalidated {
                cell.config(model: model)
                cell.delegate = self as MapViewControllerProtocol
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 暂时跳转关闭----支付走通后开放
        
        let model = dataSource[indexPath.section]
        let completedDetailVC = RNCompletedOrderDetailViewController(model: model, type: OrderType.waitPay)
        completedDetailVC.isWatingPay = true
        completedDetailVC.isMsg = true // 为了 pop
        self.navigationController?.pushViewController(completedDetailVC, animated: true)        
    }
    
}

//MARK: - MapViewControllerProtocol
extension RNWaitPayViewController: MapViewControllerProtocol{
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("待支付", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
    
}


