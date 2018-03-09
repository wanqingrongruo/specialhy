//
//  RNChargeManageViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import ESPullToRefresh

class RNChargeManageViewController: RNModelTableViewController {
    
    
    lazy var myAccount: AccountModel = {
        return AccountModel()
    }()
    
    lazy var dataSource: [AccountDetailModel] = {
        return [AccountDetailModel]()
    }()
    
    lazy var queue: OperationQueue = {
        return OperationQueue()
    }()
    
    let group = DispatchGroup()
    
    var chargeHeadView: RNChargeHeadView? = nil
    var sectionTitleView: RNChargeSectionTitleView? = nil
    var tableView: UITableView!
    
    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
    var isLoading = false
    var isLoadMore = false //  自动刷新调用了 loadmore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "财务管理", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("提现", target: self, action: #selector(getMoney))
        
        setupUI()
        
        self.parameter["moneytype"] = "0"
        
//        let op = BlockOperation {
//
//            RNHud().showHud(nil)
//            self.getOwnMoney()
//            self.refresh()
//        }
//
//        op.completionBlock = {
//
//            DispatchQueue.main.async {
//                RNHud().hiddenHub()
//            }
//        }
//
//        // 放在最后
//        queue.addOperation(op)
        RNHud().showHud(nil)
        self.getOwnMoney()
        self.refresh()
        group.notify(queue: .main) {
             RNHud().hiddenHub()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension RNChargeManageViewController {
    
    func setupUI() {
        
        chargeHeadView = Bundle.main.loadNibNamed("RNChargeHeadView", owner: nil, options: nil)?.last as? RNChargeHeadView
        chargeHeadView?.frame = CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: 130)
        if let headView = chargeHeadView {
            view.addSubview(headView)
        }
        
        sectionTitleView = Bundle.main.loadNibNamed("RNChargeSectionTitleView", owner: nil, options: nil)?.last as? RNChargeSectionTitleView
        sectionTitleView?.frame = CGRect(x: 0, y: 64+130, width: SCREEN_WIDTH, height: 60)
        sectionTitleView?.clickClousure = { tag in
            switch tag {
            case 100:
                
                self.parameter["moneytype"] = "0"
                self.tableView.es.startPullToRefresh()
                break
            case 101:
                
                self.parameter["moneytype"] = "1"
                self.tableView.es.startPullToRefresh()
                break
            case 102:
                self.parameter["moneytype"] = "2"
                self.tableView.es.startPullToRefresh()
                break
            default:
                break
            }
        }
        if let titleView = sectionTitleView {
            view.addSubview(titleView)
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: 64+130+60, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 130 - 60 - 64), style: .plain)
        tableView.rowHeight = 44
        tableView.separatorColor = BASEBACKGROUNDCOLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNMoneyCell", bundle: nil), forCellReuseIdentifier: "RNMoneyCell")
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
        tableView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expiredTimeInterval = 0.1 // 刷新过期时间
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
        
    }
    
    func getOwnMoney() {
        
        let queue = DispatchQueue(label: "getOwnMoney", qos: .default, attributes: .concurrent)
        group.enter()
        queue.async(group: group, execute: {
            FinancialServicer.getOwnMoney(successClourue: { (model) in
                
                self.myAccount = model
                DispatchQueue.main.async {
                    
                    self.chargeHeadView?.incomeLabel.text = model.income
                    self.chargeHeadView?.paidLabel.text = model.totalAssets
                }
                
                self.group.leave()
                
            }) { (msg, code) in
                RNNoticeAlert.showError("提示", body: msg)
                self.group.leave()
            }
        })
    }
    
    func parameters() {
        parameter["pagesize"] = pagesize
        parameter["index"] = page
    }
    
    func refresh() {
        
        //        if isLoading {
        //            return
        //        }
        //
        //        if isLoadMore {
        //            return
        //        }
        //
        //
        //        self.isLoading = !self.isLoading
        
        page = 1
        
        parameters() // 更新入参
        
        let queue = DispatchQueue(label: "refresh", qos: .default, attributes: .concurrent)
        group.enter()
        queue.async(group: group, execute: {
            
            //  tableView.es.resetNoMoreData()
            FinancialServicer.ownMoneyDetail(self.parameter, successClourue: { (result) in
                self.tableView.es.stopPullToRefresh()
                self.isLoading = !self.isLoading
                
                self.dataSource.removeAll()
                self.dataSource = result
                
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
                self.group.leave()
                
            }) { (msg, code) in
                
                self.isLoading = !self.isLoading
                self.tableView.es.stopPullToRefresh()
                RNNoticeAlert.showError("提示", body: msg)
                self.group.leave()
            }
        })
        
    }
    
    func loadMore() {
        
        //        if isLoading {
        //            return
        //        }
        //
        //        if isLoadMore {
        //            return
        //        }
        //
        //        self.isLoadMore = !self.isLoadMore
        
        page += 1
        
        parameters()
        
        FinancialServicer.ownMoneyDetail(parameter, successClourue: { (result) in
            
            self.tableView.es.stopLoadingMore()
            self.isLoadMore = !self.isLoadMore
            
            self.dataSource.append(contentsOf: result)
            
            if result.count < 20 {
                
                self.tableView.es.noticeNoMoreData()
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
        }) { (msg, code) in
            
            self.page -= 1 // 加载失败页面索引取消 + 1 操作
            
            self.isLoadMore = !self.isLoadMore
            self.tableView.es.stopLoadingMore()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
}

extension RNChargeManageViewController {
    
    @objc func getMoney() {
        
        let withdrawVC = RNWithdrawViewController(nibName: "RNWithdrawViewController", bundle: nil)
        navigationController?.pushViewController(withdrawVC, animated: true)
        
    }
    
    @objc func dismissFromVC(){
        _ = self.dismiss(animated: true, completion: nil)
    }
    
}

extension RNChargeManageViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNMoneyCell", for: indexPath)
        
        let model = dataSource[indexPath.row]
        
        if let cell = cell as? RNMoneyCell {
            // 显示
            if !model.isInvalidated {
                
                cell.configCell(model: model)
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
