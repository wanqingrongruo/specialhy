//
//  RNGroupDetailViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/22.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNGroupDetailViewController: RNBaseTableViewController {
    
    let groupID: String
    let groupName: String
    let flag: Int // 用来标识从哪个界面跳转过来的 0: 小组列表 1: 搜索界面
    var footerView: RNTeamGroupDetailFooterView?
    
    lazy var tabelView: UITableView = {
        
        let tableView =  UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT) , style: .plain)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(UINib(nibName: "RNTeamGroupDetail", bundle: nil), forCellReuseIdentifier: "RNTeamGroupDetail")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        return tableView
    }()
    
    lazy var dataSource: GroupDetail = {
        
        let model = GroupDetail()
        
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: groupName, target: self, action: #selector(dismissFromVC))]
        
        
        setUI()
        downloadData()
    }
    
    init(groupId: String, groupName: String, flag: Int) {
        self.groupID = groupId
        self.groupName = groupName
        self.flag = flag
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

extension RNGroupDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            let areas = dataSource.serviceArea
            if areas.count > 0 {
                return "服务区域列表"
            }
            return nil
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 162
        }
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TO DO
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let areas = dataSource.serviceArea
        if areas.count > 0 {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            let areas = dataSource.serviceArea
            
            return areas.count
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        //
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamGroupDetail", for: indexPath) as! RNTeamGroupDetail
            cell?.selectionStyle = .none
            (cell as! RNTeamGroupDetail).configCell(model: dataSource, flag: 1)
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
            let areas = dataSource.serviceArea
            if indexPath.row < areas.count{
                let area = areas[indexPath.row]
                
                guard let pro = area.province, pro != "" else {
                    return cell!
                }
                var showArea = pro
                guard let city = area.city, city != "" else{
                    
                    cell?.textLabel?.text = showArea
                    return cell!
                }
                showArea += " / \(city)"
                guard let country = area.country, country != "" else {
                    cell?.textLabel?.text = showArea
                    return cell!
                }
                showArea += " / \(country)"
                cell?.textLabel?.text = showArea
            }
            
            
        }
        return cell!
    }
    
}


//MARK: - RNTeamGroupDetailFooterViewDelegate

extension RNGroupDetailViewController: RNTeamGroupDetailFooterViewDelegate {
    
    func showProtocolDetail() {
        let webVC = RNWebUrlViewController(url: GroupProtocol, title: "加入小组")
        self.navigationController?.pushViewController(webVC, animated: true)

    }
    
    
    func joinUs() {
        
        RNHud().showHud(nil)
        UserServicer.joinTeam(["teamid": groupID], successClourue: { 
            RNHud().hiddenHub()
            
            RNNoticeAlert.showSuccessWithForever("提示", body: "申请成功, 请等待审核", buttonTapHandler: { [weak self](_) in
                RNNoticeAlert.hideMessage()
                self?.getCurrentuserInfo()
                self?.dismiss(animated: true, completion: {})
            })
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body:  msg)

        }
    }
    
    // 获取个人信息
    func getCurrentuserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil) // 个人信息更新通知发出通知
            
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
            print("错误提示: \(msg) + \(code)")
        }
    }

}

//MARK: - private methods

extension RNGroupDetailViewController {
    
    func setUI(){
        
        view.addSubview(tabelView)
        
        
        if flag == 1{
            
            footerView = Bundle.main.loadNibNamed("RNTeamGroupDetailFooterView", owner: nil, options: nil)?.last as? RNTeamGroupDetailFooterView
            footerView?.delegate = self
            tabelView.tableFooterView = footerView
        }
        
        
    }
    
    func downloadData() {
        
        RNHud().showHud(nil)
        
        UserServicer.groupDetail(["teamid": groupID], successClourue: { (dataArray) in
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

extension RNGroupDetailViewController {
    
    @objc func dismissFromVC(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
}

