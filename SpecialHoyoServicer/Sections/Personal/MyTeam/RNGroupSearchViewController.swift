//
//  RNGroupSearchViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/23.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RNGroupSearchViewController: RNBaseTableViewController {
    
    lazy var searchBar: UISearchBar = {
        
        let bar = UISearchBar(frame: CGRect(x:20, y: 0, width: SCREEN_WIDTH-120, height: 40))
        bar.placeholder = "填写小组名称/小组ID"
        bar.showsCancelButton = true
        bar.returnKeyType = .search
        bar.delegate = self
        bar.becomeFirstResponder()
        let cancelButton = bar.value(forKey: "cancelButton") as! UIButton
        cancelButton.isEnabled = false
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        
        return bar
    }()
    var searchString: String = ""
    
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
    
    lazy var dataSource:[GroupDetail] = {
        let arr = [GroupDetail]()
        return arr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton()
        btn.setImage(UIImage(named: "nav_back"), for: .normal)
        btn.addTarget(self, action: #selector(dismissFromVC), for: .touchUpInside)
        btn.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        navigationItem.titleView = searchBar as UIView
        
        setUI()
        downloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNGroupSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            let groupDetailVC = RNGroupDetailViewController(groupId: teamID, groupName: groupDetail.groupName ?? "小组详情", flag: 1)
            self.navigationController?.pushViewController(groupDetailVC, animated: true)
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
            
//            cell.nameLabel.isOpenHightLightForKeyword = true
//            cell.nameLabel.keyword = self.searchString
//            cell.IDLabel.isOpenHightLightForKeyword = true
//            cell.IDLabel.keyword = self.searchString
            
            cell.keyword = searchString
            cell.isOpenHighLight = true
            cell.configCell(groupDetail)
            
         
        }
        return cell
    }
    
}


//MARK: - UISearchBarDelegate

extension RNGroupSearchViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        downloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        downloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: - private methods

extension RNGroupSearchViewController {
    
//    func setSearchBar() {
//        
//        searchBar = UISearchBar
//    }
    
    func setUI(){
        
        view.addSubview(tabelView)
    }
    
    func downloadData() {
        
       // RNHud().showHud(nil)
        UserServicer.queryTeamList(["query": searchString], successClourue: { (dataArray) in
            //RNHud().hiddenHub()
            self.dataSource = dataArray
            
            self.tabelView.reloadData()
        }) { (msg, code) in
            //RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body:  msg)
        }
    }
    
}

//MARK: - event response

extension RNGroupSearchViewController {
    
    @objc func dismissFromVC(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func cancelAction(){
        
        if searchBar.isExclusiveTouch {
            searchBar.isExclusiveTouch = !searchBar.isExclusiveTouch
            searchBar.resignFirstResponder()
            
        }
       
    }
    
    func spaceAction(){
        
    }
}

