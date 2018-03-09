//
//  RNHistoryViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/23.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh

class RNHistoryViewController: RNBaseTableViewController {
    
    var orderId: String
    
    init(_ orderId: String) {
        self.orderId = orderId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableView: UITableView!
    
    lazy var dataSource: [HistoryModel] = {
        
        let array = realmQueryResults(Model: HistoryModel.self)
        
        if array.count > 0  {
            
            var arr = [HistoryModel]()
            for item in array {
                
                arr.append(item)
            }
            
            return arr.map({ (model) -> HistoryModel in
                return model.copy() as! HistoryModel
            })
            
        }else{
            return [HistoryModel]()
        }
        
    }()

    
    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    var isLoading = false
    var isLoadMore = false //  自动刷新调用了 loadmore


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "历史记录", target: self, action: #selector(popBack))]
        
        setupUI()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }

}

extension RNHistoryViewController {
    func setupUI() {
        
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .grouped)
        }else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = BASEBACKGROUNDCOLOR
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNHistoryTimeCell", bundle: nil), forCellReuseIdentifier: "RNHistoryTimeCell")
        tableView.tableFooterView = UIView()
        
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
//        tableView.es.addInfiniteScrolling(animator: footer) { [weak self] in
//            self?.loadMore()
//        }
        
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
        
        parameter["orderid"] = orderId
       
    }

    func refresh() {
        
//
//        if isLoading {
//            return
//        }
//
//        self.isLoading = !self.isLoading
        
      //  page = 1
        
        parameters() // 更新入参
        
        //  tableView.es.resetNoMoreData()
        
        OrderServicer.getHomeTimeList(parameter, successClourue: { (result) in
            
            //  RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
           // self.isLoading = !self.isLoading
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            
           // self.isLoading = !self.isLoading
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
//        if isLoadMore {
//            return
//        }
//
//        self.isLoadMore = !self.isLoadMore
        
        page += 1
        
        parameters()
        
        OrderServicer.getHomeTimeList(parameter, successClourue: { (result) in
            
            self.tableView.es.stopLoadingMore()
           // self.isLoadMore = !self.isLoadMore
            
            self.dataSource.append(contentsOf: result)
            
            if result.count < 20 {
                
                self.tableView.es.noticeNoMoreData()
            }
            self.tableView.reloadData()
            
        }) { (msg, code) in
            
            self.page -= 1 // 加载失败页面索引取消 + 1 操作
            
           // self.isLoadMore = !self.isLoadMore
            self.tableView.es.stopLoadingMore()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }

}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNHistoryViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == (dataSource.count-1)
        {
            return 0.1
        }
        return 2
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNHistoryTimeCell", for: indexPath)
        
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNHistoryTimeCell {
            // 显示
            if !model.isInvalidated {
                cell.config(model: model)
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
