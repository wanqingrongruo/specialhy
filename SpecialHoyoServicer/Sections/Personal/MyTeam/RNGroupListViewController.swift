//
//  RNGroupListViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/19.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNGroupListViewController: RNBaseTableViewController {
    
    let groupId: String
    let identifier: String
    
    var isTransferOrder: Bool = false // 是否是转单过来
    var transferOrderId: String? = "" // 需要转的订单 id
    
    lazy var tabelView: UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT) , style: .grouped)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RNTeamGroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "RNTeamGroupListTableViewCell")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        return tableView
    }()
    
    lazy var dataSource: [GroupDetail] = {
        
        let arr = [GroupDetail]()
        
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "我的团队", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("详情", target: self, action: #selector(detailAction))
        
        setUI()
        downloadData()
    }
    
    init(_ groupId: String, identifier: String) {
        self.groupId = groupId
        self.identifier = identifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNGroupListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < dataSource.count {
            let groupDetail = dataSource[indexPath.section]
            guard let teamID = groupDetail.groupId else{
                RNNoticeAlert.showError("提示", body: "获取小组ID失败")
                return
            }
            let teamGroupVC = RNTeamGroupViewController(teamid: teamID, groupName: groupDetail.groupName ?? "成员列表", identifier: identifier)
            teamGroupVC.isTransferOrder = isTransferOrder
            teamGroupVC.transferOrderId = transferOrderId
            self.navigationController?.pushViewController(teamGroupVC, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamGroupListTableViewCell", for: indexPath) as! RNTeamGroupListTableViewCell
        
        if indexPath.row < dataSource.count {
            let groupDetail = dataSource[indexPath.section]
            cell.configCell(groupDetail)
        }
        return cell
    }
    
}


//MARK: - private methods

extension RNGroupListViewController {
    
    func setUI(){
        
        view.addSubview(tabelView)
    }
    
    func downloadData() {
        
        RNHud().showHud(nil)
        UserServicer.groupListInTeam(["groupid": groupId], successClourue: { (dataArray) in
            RNHud().hiddenHub()
            
            self.dataSource = dataArray
            
            self.tabelView.reloadData()
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body:  msg)
        }
    }
    
}

//MARK: - event response

extension RNGroupListViewController {
    
    @objc func dismissFromVC(){
        
        if isTransferOrder {
            _ = self.navigationController?.popViewController(animated: true)
            
        }else{
           self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func detailAction(){
        let groupDetailVC = RNTeamDetailViewController(groupId: groupId, groupName: "团队详情" , flag: 0)
        self.navigationController?.pushViewController(groupDetailVC, animated: true)
        
    }
    
    
}

