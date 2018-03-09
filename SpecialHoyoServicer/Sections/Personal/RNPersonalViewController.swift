//
//  RNPersonalViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/6/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import ESPullToRefresh


class RNPersonalViewController: UIViewController {
    
   // var headView: RNPersonalHeadView?
    var headView: RNNewHeadView?
    
    var tableView: UITableView!
    
    var dataSource: [[(String, String)]] = {
       
        let array01 = [("person_identifier", "实名认证"), ("person_team", "我的团队"), ("person_exam", "我的考试")]
        let array02 = [("person_comment", "我的评价"),("person_money", "财务管理"), ("person_pay", "订单支付") ]
        let array03 = [("person_store", "仓储物流"), ("person_setting", "设置")]
        
        return [array01, array02, array03]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        createUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showInfo), name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - custom methods 

extension RNPersonalViewController {
    
    fileprivate func createUI() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: DRAWERWIDTH, height: view.frame.size.height), style: .grouped)
        tableView.backgroundColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.rowHeight = 44.0
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.register(UINib(nibName: "RNPersonalCell", bundle: nil), forCellReuseIdentifier: "RNPersonalCell")
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
//        headView = Bundle.main.loadNibNamed("RNPersonalHeadView", owner: nil, options: nil)?.last as? RNPersonalHeadView
//        headView?.frame = CGRect(x: 0, y: 0, width: DRAWERWIDTH, height: DRAWERWIDTH*203/360 + 20)
        
        let header: ESRefreshHeaderAnimator = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        
        header.pullToRefreshDescription = "下拉可以刷新"
        header.releaseToRefreshDescription = "松手刷新"
        header.loadingDescription = "刷新中..."
    
        tableView.es.addPullToRefresh(animator: header){ [weak self] in
            self?.refresh()
        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expiredTimeInterval = 0.1 // 刷新过期时间
        
        headView = Bundle.main.loadNibNamed("RNNewHeadView", owner: nil, options: nil)?.last as? RNNewHeadView
        headView?.frame = CGRect(x: 0, y: 0, width: DRAWERWIDTH, height: 100+100)
        headView?.delegate = self
        tableView.tableHeaderView = headView
        
        view.addSubview(tableView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.autoPullToRefresh() // 自动刷新
        }

        showInfo()
        
    }
    
    func refresh() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            
            self.tableView.es.stopPullToRefresh()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil) // 个人信息更新通知发出通知
            DispatchQueue.main.async {
                self.showInfo()
            }
            
            
        }) { (msg, code) in
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
            print("错误提示: \(msg) + \(code)")
        }

    }
    
    @objc func showInfo() {
        
        let userInfo = realmQueryResults(Model: UserModel.self).first
        
        guard let user = userInfo else {
            
            self.refresh()
            return
        }
        
        if let url = user.headImageUrl, let u = URL(string: url) {
            
            headView?.headImageView.kf.setImage(with: u, placeholder: UIImage(named:"person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
        }else{
            headView?.headImageView.image = UIImage(named: "person_defaultHeadImage")
        }
        
        headView?.nameLabel.text = user.realName != "" ? user.realName : "佚名"
        headView?.sevicerAreaLabel.text =  user.mobile != "" ? String(format: "手机号码: %@", user.mobile ?? "") : ""
        
        if let id = user.userId{
            headView?.userIdLabel.text = id != "" ? "(\(String(describing: id)))" : ""
        }
        
        headView?.finishOrderLabel.text = user.finishOrder != "" ? user.finishOrder : "0"
        headView?.waitOrderLabel.text = user.waitOrder != "" ? user.waitOrder : "0"
        headView?.incomeLabel.text = user.income != "" ? user.income : "0.00"
        headView?.paidLabel.text = user.expenditure != "" ? user.expenditure : "0.00"
    }
    
//    // 获取个人信息
//    func getCurrentuserInfo() {
//        
//    }

    
    func goTeam() {
        
        let userInfo = realmQueryResults(Model: UserModel.self).first
        
        guard let user = userInfo, let id = user.userId else {
            
            RNNoticeAlert.showError("提示", body: "未获取到用户 id")
            return
        }
        
        RNHud().showHud(nil)
        UserServicer.memberIdentifier(["userid": id], successClourue: { (userIdentifier) in
            RNHud().hiddenHub()
            
            switch userIdentifier.identifier {
            case "1"?:
                
                self.checkState(identifier: "1", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到团队编号", refuseDes: "团队创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "2"?:
                self.checkState(identifier: "2", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "小组创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "3"?:
                self.checkState(identifier: "3", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "加入申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case  "4"?:
                let joinUsVC = RNJoinUsViewController()
                let nav = RNBaseNavigationController(rootViewController: joinUsVC)
                self.present(nav, animated: true, completion: nil)
                break
            default:
                break
            }

        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }

    }
    
    func checkState(identifier: String, state: String?, groupId: String?, GroupDes: String, refuseDes: String, waitDes: String){
        
        
        guard let state = state else {
           RNNoticeAlert.showError("提示", body: "未获取到审核状态")
           return
        }
        if state == "70001" {
            // 通过
            guard let groupId = groupId else{
                RNNoticeAlert.showError("提示", body: GroupDes)
                return
                
            }
            
            if identifier == "1" {
                let groupListVC = RNGroupListViewController(groupId, identifier: identifier)
                let nav = RNBaseNavigationController(rootViewController: groupListVC)
                self.present(nav, animated: true, completion: nil)
                
            }else{
                let teamGroupVC = RNTeamGroupViewController(teamid: groupId, groupName: "成员列表", identifier: identifier)
                let nav = RNBaseNavigationController(rootViewController: teamGroupVC)
                self.present(nav, animated: true, completion: nil)
            }
            
            
        }else if state == "70003" {
            // 待审核
            RNNoticeAlert.showError("提示", body: waitDes)
        }else{
            
            // 拒绝
            let joinUsVC = RNJoinUsViewController()
            joinUsVC.msg = refuseDes
            let nav = RNBaseNavigationController(rootViewController: joinUsVC)
            self.present(nav, animated: true, completion: nil)
            
        }
        
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension RNPersonalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNPersonalCell", for: indexPath) as! RNPersonalCell
        
        let img = dataSource[indexPath.section][indexPath.row].0
        let title = dataSource[indexPath.section][indexPath.row].1
        
        cell.iconImageView.image = UIImage(named: img)
        cell.titleLabel.text = title
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                // 实名认证
                let identifierVC = RNIdentityViewController(nibName: "RNIdentityViewController", bundle: nil)
                identifierVC.isPersonal = true
                let nav = RNBaseNavigationController(rootViewController: identifierVC)
                self.present(nav, animated: true, completion: nil)

            }else if indexPath.row == 1{
                // 我的团队
                goTeam()
            }else if indexPath.row == 2 {
                //我的考试
                let examVC = RNExamViewController()
                let nav = RNBaseNavigationController(rootViewController: examVC)
                self.present(nav, animated: true, completion: nil)
            }
            break
        case 1:
            if indexPath.row == 0 {
               // 我的评价
                // 订单支付
                let myCommentVC = RNMyCommentViewController()
                let nav = RNBaseNavigationController(rootViewController: myCommentVC)
                self.present(nav, animated: true, completion: nil)
            }else if indexPath.row == 1{
               // 财务 管理
                let chargeManageVC = RNChargeManageViewController()
                let nav = RNBaseNavigationController(rootViewController: chargeManageVC)
                self.present(nav, animated: true, completion: nil)

            }else{
                // 订单支付
                let waitpayVC = RNWaitPayViewController()
                let nav = RNBaseNavigationController(rootViewController: waitpayVC)
               // nav.navigationBar.isTranslucent = false
                self.present(nav, animated: true, completion: nil)
            }
            break
        case 2:
            
            if indexPath.row == 0{
               // 仓储物流
                let storeExpressVC = RNStoreExpressViewController()
                self.present(storeExpressVC, animated: true, completion: nil)
            }else{ // 设置
                let settingVC = RNSettingViewController()
                self.present(settingVC, animated: true, completion: nil)
            }
            break
        default:
            break
        }
        
//        // 跳转控制器
//         let vc = RNAboutViewController()
//         self.present(vc, animated: true) {
//        }
    }
}

// MARK: - RNPersonalHeadViewProtocol

extension RNPersonalViewController: RNPersonalHeadViewProtocol{
    
    func skipToUserInfo() {
        
        let infoVC = RNUserInfoViewController()
        
        self.present(infoVC, animated: true, completion: nil)
    }
}

// MARK: - RNNewHeadViewProtocol
extension RNPersonalViewController: RNNewHeadViewProtocol{
    
    func skipToUserInfo2() {
        
        let infoVC = RNUserInfoViewController()
        let nav = RNBaseNavigationController(rootViewController: infoVC)
        self.present(nav, animated: true, completion: nil)
      //  self.present(infoVC, animated: true, completion: nil)
    }
}

