//
//  RNExamViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh

class RNExamViewController: RNBaseTableViewController {
    
    fileprivate var tableView: UITableView!
    
    lazy var dataSource: [ExamModel] = {
        
        let array = realmQueryResults(Model: ExamModel.self)
        
        var arr = [ExamModel]()
        for item in array {
            
            arr.append(item)
        }
        
        return arr.map({ (model) -> ExamModel in
            return model.copy() as! ExamModel
        })
        
    }()

    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "我的考试", target: self, action: #selector(dismissFromVC))]

        setupTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RNExamViewController {
    
    @objc func dismissFromVC(){
        _ = self.dismiss(animated: true, completion: nil)
    }
    
}

extension RNExamViewController {
    
    func setupTableView() {
        
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .grouped)
        }else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
      //  tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear
        
        tableView.register(UINib(nibName: "RNExamCell", bundle: Bundle.main), forCellReuseIdentifier: "RNExamCell")
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            self.tableView.es.startPullToRefresh()
        }
    }

    
    
    func parameters() {
        
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
    }
    
    func refresh() {
        
        page = 1
        
        parameters() // 更新入参
        
        
        UserServicer.getMyExam(parameter, successClourue: { (result) in
            
            self.tableView.es.stopPullToRefresh()
            
            self.dataSource.removeAll()
            self.dataSource = result.map({ (model) -> ExamModel in
                return model.copy() as! ExamModel
            })

            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
        page += 1
        
        parameters()
        
        UserServicer.getMyExam(parameter, successClourue: { (result) in
            
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

// MARK: - UITableViewDelegate && UITabelViewDatasource

extension  RNExamViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNExamCell", for: indexPath)
        
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNExamCell {
            cell.configCell(model: model)
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
}
