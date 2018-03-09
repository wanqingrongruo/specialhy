//
//  RNMemberDetailViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/5/22.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

class RNMemberDetailViewController: RNBaseTableViewController {
    
    typealias DeleteCallBack = () -> ()  // 移除回调
    
    let memberDetail: TeamMembers
    
    let identifier: String
    
    var deleteCallBack: DeleteCallBack
    
    var isTransferOrder: Bool = false // 是否是转单过来
    var transferOrderId: String? = "" // 需要转的订单 id
    var bottomView: UIView?
    
    lazy var tabelView: UITableView = {
        
        let tableView =  UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT) , style: .plain)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(UINib(nibName: "RNTeamMemberDetail", bundle: nil), forCellReuseIdentifier: "RNTeamMemberDetail")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        return tableView
    }()
    
    lazy var dataSource: TeamMembers = {
        
        let model = TeamMembers()
        
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: memberDetail.nickname, target: self, action: #selector(dismissFromVC))]
        
        
        //        if identifier == "1" {  // 团队负责人才可以移除成员
        //             navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("移除", target:  self, action: #selector(deleteMember))
        //        }
        
        setUI()
        downloadData()
    }
    
    init(memberDetail: TeamMembers, identifier: String, deleteCallBack: @escaping DeleteCallBack) {
        self.memberDetail = memberDetail
        self.identifier = identifier
        self.deleteCallBack = deleteCallBack
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

extension RNMemberDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            return 123
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
            cell = tableView.dequeueReusableCell(withIdentifier: "RNTeamMemberDetail", for: indexPath) as! RNTeamMemberDetail
            cell?.selectionStyle = .none
            (cell as! RNTeamMemberDetail).configCell(dataSource)
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

//MARK: - private methods

extension RNMemberDetailViewController {
    
    func setUI(){
        
        if isTransferOrder{
            tabelView.frame =  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-60)
        }
        
        view.addSubview(tabelView)
        
        if isTransferOrder { // 转单
            
            bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
            (bottomView as! RNSigleButtonView).sigleButton.setTitle("转单给TA", for: .normal)
            (bottomView as! RNSigleButtonView).callBack = { [weak self] tag in
                
                // 二次提醒
                self?.alertTip()
            }
            
            if let v = bottomView {
                view.addSubview(v)
            }
        }
    }
    
    func alertTip() {
        
        let alert = UIAlertController(title: "确认把订单转给\(memberDetail.nickname ?? "TA")?", message: nil, preferredStyle: .alert)
        let deletaButton = UIAlertAction(title: "确认", style: .destructive) { [weak self](_) in
            // 转单
            self?.transferOrder()
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(deletaButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func transferOrder() {
        
        guard let oId = transferOrderId else {
            RNNoticeAlert.showError("提示", body:  "未获取到订单CRMID")
            return
        }
        
        guard let uId = memberDetail.userid else {
            RNNoticeAlert.showError("提示", body:  "未获取到接收人的Id")
            return
        }
        
        RNHud().showHud(nil)
        OrderServicer.transferOrder(["CRMID": oId, "ReceiveEngID": uId], successClourue: { (state) in
            
            RNHud().hiddenHub()
            if state == 1 {
                RNNoticeAlert.showSuccessWithForever("提示", body: "转单成功,立即返回", buttonTapHandler: { [weak self](_) in
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: TransferOrderSuccessNofitication), object: nil) // 发送通知
                    RNNoticeAlert.hideMessage()
                    self?.dismiss(animated: true, completion: {
                    })
                })
            }else{
                RNNoticeAlert.showError("提示", body:  "转单失败")
            }
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body:  msg)
        }
    }
    
    func downloadData() {
        
        if let id = memberDetail.userid {
            
            RNHud().showHud(nil)
            UserServicer.teamMemberDetails(["userid": id], successClourue: { (dataArray) in
                RNHud().hiddenHub()
                
                self.dataSource = dataArray
                
                self.dataSource.nickname = self.memberDetail.nickname
                self.dataSource.headimageurl = self.memberDetail.headimageurl
                self.dataSource.userid = self.memberDetail.userid
                self.dataSource.title = self.memberDetail.title
                
                self.tabelView.reloadData()
                
            }, failureClousure: { (msg, code) in
                RNHud().hiddenHub()
                RNNoticeAlert.showError("提示", body:  msg)
            })
            
        }else{
            
            RNNoticeAlert.showError("提示", body: "未获取到工程师ID")
        }
    }
    
    func deleteAction(){
        
        //        guard let userid = memberDetail.userid else {
        //
        //            RNNoticeAlert.showError("提示", body: "未获取到当前用户ID")
        //            return
        //        }
        //        RNHud().showHud(nil)
        //        User.SignOutTeam(userid: userid, success: {
        //            MBProgressHUD.hide(for: self.view, animated: true)
        //            let alertView = SCLAlertView()
        //            alertView.addButton("确定", action: { [weak self] in
        //
        //                self?.deleteCallBack()
        //                self?.navigationController?.popViewController(animated: true)
        //
        //            })
        //            alertView.showSuccess("提示", subTitle: "移除成员成功")
        //        }) { (error) in
        //            MBProgressHUD.hide(for: self.view, animated: true)
        //            let alertView = SCLAlertView()
        //            alertView.addButton("确定", action: {})
        //            alertView.showError("提示", subTitle: error.localizedDescription)
        //        }
        
    }
    
}

//MARK: - event response

extension RNMemberDetailViewController {
    
    @objc func dismissFromVC(){
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func deleteMember() {
        
        //        let alertView = SCLAlertView()
        //        alertView.addButton("确定", action: {
        //            self.deleteAction()
        //        })
        //        alertView.addButton("取消", action: {})
        //        alertView.showWarning("提示", subTitle: "是否确定移除该成员?")
        
    }
    
    
}

