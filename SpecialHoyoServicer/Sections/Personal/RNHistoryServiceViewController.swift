//
//  RNHistoryServiceViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation

class RNHistoryServiceViewController: RNBaseTableViewController {
    
    var servicecode:String
    
    init(servicecode:String) {
        
        self.servicecode=servicecode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    var tableView: UITableView!
    
    lazy var dataSource: [Order] = {
        return [Order]()
    }()

    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "服务记录", target: self, action: #selector(dismissFromVC))]
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RNHistoryServiceViewController {
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tableView.es.autoPullToRefresh() // 自动刷新
        }
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }
    
    func parameters() {
        
        parameter["servicecode"] = servicecode
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
    }
    
    func refresh() {
        
        page = 1
        
        parameters() // 更新入参
        
        UserServicer.serviceTrainRecord(parameter, successClourue: { (result) in
            
            self.tableView.es.stopPullToRefresh()
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
       page += 1
        
       parameters()
        
       UserServicer.serviceTrainRecord(parameter, successClourue: { (result) in
            
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

extension RNHistoryServiceViewController {
    
    @objc func dismissFromVC(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNHistoryServiceViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
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
        
        
        let model = dataSource[indexPath.section]
        
        let completedDetailVC = RNCompletedOrderDetailViewController(model: model, type: OrderType.completed)
        completedDetailVC.isServiceTrain = true
        self.navigationController?.pushViewController(completedDetailVC, animated: true)
        
    }
    
}

//MARK: - MapViewControllerProtocol
extension RNHistoryServiceViewController: MapViewControllerProtocol{
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("服务记录", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
    
}
