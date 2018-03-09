//
//  RNCustomOrderDetailViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/26.
//  Copyright © 2017年 roni. All rights reserved.
//

// 通用的订单详情界面... 已完成订单另写

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation
import Spring

class RNCustomOrderDetailViewController: RNBaseTableViewController {
    
    var type: OrderType  // 订单类型 -- 具体一些特征显示
    var model: Order
    
    var isDownload = false // 判断是否请求接口 -- 针对从未处理->订单详情->预约时间->订单详情(这里需要主动请求接口拿新数据) - 在进入界面设置为 true
    var isMsg = false
    
    var currentType: Int = 0 // 当前订单类型的 code, 方便判断. 范围 1-12
    // var serviceItem: String? = nil // serviceItem
    
    init(model: Order, type: OrderType) {
        self.model = model
        self.type = type
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var tableView: UITableView!
    var headView: RNNewDetailHeadView! //RNDetailHeadView
    var bottomView: UIView?
    
    lazy var dataSource: OrderDetail = {
        
        let models = realmQueryModel(Model: OrderDetail.self) { (results) -> Results<OrderDetail>? in
            return results.filter("crmId = %@", self.model.crmId ?? "" )
        }
        
        if let ms = models, let m = ms.last {
            
            return m.copy() as! OrderDetail
        }
        
        return OrderDetail()
    }()
    
    lazy var sectionOneTitles: [String] = {
        
        return [String]()
    }()
    lazy var sectionOneContents: [String] = {
        
        return [String]()
    }()
    lazy var sectionTwoTitles: [String] = {
        
        return [String]()
    }()
    lazy var sectionTwoContents: [String] = {
        
        return [String]()
    }()
    
    
    var parameter = [String: Any]()
    var isLoading = false
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    var hudVC: RNTipHudViewController?
    lazy var backItem =  {
        return UIBarButtonItem.createLeftBarItem(title: "", target: self, action: #selector(dismissFromVC))
    }()
    
    let filterCode: Int = 14  // 过滤
    var typeLimit = 0 // 控制维护维修单的显示样式
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white 
        
        setBackItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItem("nav_share", target: self, action: #selector(shareAction))
        
        setupUI()
        setupBottom()
        
        if let t = model.serviceItem, t != "" {
            if let tuple = ServiceItemDictionary[t]{
                self.currentType = tuple.code
            }
        }
        
        if dataSource.crmId != nil {
            
            if isDownload {
                self.createDataArray(dataSource)
                //tableView.es.autoPullToRefresh()
            }else{
                self.createDataArray(dataSource)
                //self.tableView.reloadData()
            }
        }
        
        if self.currentType == 7 {
            typeLimit = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackItem() {
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        
        if let username = dataSource.userName {
            backItem =  UIBarButtonItem.createLeftBarItem(title: username, target: self, action: #selector(self.dismissFromVC))
        }
        navigationItem.leftBarButtonItems = [space, backItem]
    }
}

//MARK: - custom methods
extension RNCustomOrderDetailViewController {
    
    func setupUI() {
        
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60 - 64), style: .grouped)
        }else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: .grouped)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNDetailFeeCell", bundle: nil), forCellReuseIdentifier: "RNDetailFeeCell")
        tableView.register(UINib.init(nibName: "RNDetailLinkerCell", bundle: nil), forCellReuseIdentifier: "RNDetailLinkerCell")
        tableView.register(UINib.init(nibName: "RNDetailAddressCell", bundle: nil), forCellReuseIdentifier: "RNDetailAddressCell")
        tableView.register(UINib.init(nibName: "RNDetailAppointmentCell", bundle: nil), forCellReuseIdentifier: "RNDetailAppointmentCell")
        tableView.register(UINib.init(nibName: "RNDetailCommonCell", bundle: nil), forCellReuseIdentifier: "RNDetailCommonCell")
        tableView.register(UINib.init(nibName: "RNDetailNoteCell", bundle: nil), forCellReuseIdentifier: "RNDetailNoteCell")
        tableView.register(UINib.init(nibName: "RNNewDetailLinkerCell", bundle: nil), forCellReuseIdentifier: "RNNewDetailLinkerCell")
        
        let header: ESRefreshHeaderAnimator = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        
        header.pullToRefreshDescription = "下拉可以刷新"
        header.releaseToRefreshDescription = "松手刷新"
        header.loadingDescription = "刷新中..."
        
        
        tableView.es.addPullToRefresh(animator: header){ [weak self] in
            self?.refresh()
        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expiredTimeInterval = 0.1 // 刷新过期时间
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
        
        headView = Bundle.main.loadNibNamed("RNNewDetailHeadView", owner: nil, options: nil)?.last as? RNNewDetailHeadView
        headView.frame =  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 83)
        tableView.tableHeaderView = headView
        
        //        headView.callBack = { [weak self] tag in
        //            // 100, 200, 300
        //
        //            switch tag {
        //            case 100:
        //                guard let id = self?.dataSource.documentNo, id != "" else {
        //                  RNNoticeAlert.showInfo("提示", body: "浩泽编号为空")
        //                  return
        //                }
        //                self?.createQRView("浩泽编号", content: id)
        //            case 200:
        //                guard let id = self?.dataSource.crmId, id != "" else {
        //                    RNNoticeAlert.showError("提示", body: "浩优编号为空")
        //                    return
        //                }
        //                self?.createQRView("浩优编号", content: id)
        //            case 300:
        //                guard let id = self?.dataSource.orderId, id != "" else {
        //                    RNNoticeAlert.showError("提示", body: "订单编号为空")
        //                    return
        //                }
        //                self?.createQRView("订单编号", content: id)
        //            default:
        //                break
        //            }
        //        }
        
        if dataSource.crmId == nil {
            tableView.es.autoPullToRefresh()
        }else{
            headView.config(model: dataSource)
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        //            self.tableView.es.autoPullToRefresh()
        //        }
    }
    
    func setupBottom() {
        
        switch type {
        case .subscibe:
            bottomView = Bundle.main.loadNibNamed("RNCoupleButtonView", owner: self, options: nil)?.last as? RNCoupleButtonView
            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
            (bottomView as! RNCoupleButtonView).callBack = { [weak self] tag in
                // 无服务 tag:100, 到达 tag: 200
                switch tag {
                case 100:
                    
                    // TO DO: -- 抽象成函数,可是我就是不想改...嘻嘻嘻
                    guard let id = self?.model.crmId, id != "" else{
                        RNNoticeAlert.showError("提示", body: "未获取到crmId,无法跳转")
                        return
                    }
                    RNHud().showHud(nil)
                    OrderServicer.canFinishedOrder(["CRMID": id], successClourue: {
                        RNHud().hiddenHub()
                        let noServicerVC = RNNoServiceViewController(model: self!.dataSource)
                        self?.navigationController?.pushViewController(noServicerVC, animated: true)
                    }, failureClousure: { (msg, code) in
                        RNHud().hiddenHub()
                        RNNoticeAlert.showError("提示", body: msg, duration: 3.0)
                    })
                    
                case 200:
                    // 到达
                    // if let s = self,  [2, 6].contains(s.currentType){
                    // 换机/安装单判断出库 -- 后台判断, 未出库报错不允许挑战 - 3s
                    // 未出库: RNNoticeAlert.showError("提示", body: "当前订单设备未出库不得结单", duration: 3.0)
                    // 已出库: self?.skipToSubmitByServicerItem()
                    guard let id = self?.model.crmId, id != "" else{
                        RNNoticeAlert.showError("提示", body: "未获取到crmId,无法跳转")
                        return
                    }
                    RNHud().showHud(nil)
                    OrderServicer.canFinishedOrder(["CRMID": id], successClourue: {
                        RNHud().hiddenHub()
                        self?.skipToSubmitByServicerItem()
                    }, failureClousure: { (msg, code) in
                        RNHud().hiddenHub()
                        RNNoticeAlert.showError("提示", body: msg, duration: 3.0)
                    })
                    //                    }else{
                    //                       self?.skipToSubmitByServicerItem()
                    //                    }
                    break
                default:
                    break 
                }
            }
            
        case .getOrder:
            bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
            (bottomView as! RNSigleButtonView).sigleButton.setTitle("抢   单", for: .normal)
            (bottomView as! RNSigleButtonView).callBack = { [weak self] tag in
                
                // 调用抢单接口
                self?.robOrder()
            }
            
        case .waitingDealing:
            
            bottomView = Bundle.main.loadNibNamed("RNCoupleButtonView", owner: self, options: nil)?.last as? RNCoupleButtonView
            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
            (bottomView as! RNCoupleButtonView).noServiceButton.setTitle("无服务", for: .normal)
            (bottomView as! RNCoupleButtonView).arriveButton.setTitle("预约", for: .normal)
            (bottomView as! RNCoupleButtonView).callBack = { [weak self] tag in
                // 无服务 tag:100, 到达 tag: 200
                switch tag {
                case 100:
                    
                    // TO DO: -- 抽象成函数,可是我就是不想改...嘻嘻嘻
                    guard let id = self?.model.crmId, id != "" else{
                        RNNoticeAlert.showError("提示", body: "未获取到crmId,无法跳转")
                        return
                    }
                    RNHud().showHud(nil)
                    OrderServicer.canFinishedOrder(["CRMID": id], successClourue: {
                        RNHud().hiddenHub()
                        let noServicerVC = RNNoServiceViewController(model: self!.dataSource)
                        self?.navigationController?.pushViewController(noServicerVC, animated: true)
                    }, failureClousure: { (msg, code) in
                        RNHud().hiddenHub()
                        RNNoticeAlert.showError("提示", body: msg, duration: 3.0)
                    })
                    
                case 200:
                    
                    let timeVC = RNTimeConfirmViewController(self!.dataSource, type: self!.type, actionType: "Appointment", orderModel: self!.model)
                    timeVC.waitDealCallback = { [weak self] (_, isConfirmTime) in
                        
                        if isConfirmTime {
                            self?.type = OrderType.subscibe
                        }else{
                            self?.type = OrderType.waitingDealing
                        }
                        self?.setupBottom()
                        self?.tableView.es.autoPullToRefresh()
                    }
                    
                    self?.navigationController?.pushViewController(timeVC, animated: true)
                    break
                default:
                    break
                }
            }
            //            bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
            //            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
            //            (bottomView as! RNSigleButtonView).sigleButton.setTitle("预   约", for: .normal)
            //            (bottomView as! RNSigleButtonView).callBack = { [weak self] tag in
            //
            //                //                let timeVC = RNTimeConfirmViewController(self!.dataSource, type: self!.type, actionType: "Appointment", orderModel: self!.model)
            //                //                self?.navigationController?.pushViewController(timeVC, animated: true)
            //
            //                let timeVC = RNTimeConfirmViewController(self!.dataSource, type: self!.type, actionType: "Appointment", orderModel: self!.model)
            //                timeVC.waitDealCallback = { [weak self] (_, isConfirmTime) in
            //
            //                    if isConfirmTime {
            //                       self?.type = OrderType.subscibe
            //                    }else{
            //                       self?.type = OrderType.waitingDealing
            //                    }
            //                    self?.setupBottom()
            //                    self?.tableView.es.autoPullToRefresh()
            //                }
            //
            //                self?.navigationController?.pushViewController(timeVC, animated: true)
            //
        //            }
        default:
            bottomView = UIView()
        }
        
        view.addSubview(bottomView!)
        
    }
    
    func skipToSubmitByServicerItem() {
        
        guard let type = model.serviceItem, type != "" else{
            RNNoticeAlert.showError("提示", body: "未获取到订单类型,无法跳转")
            return
        }
        
        if let tuple = ServiceItemDictionary[type], tuple.code == filterCode { // 冲水单-联通
            
            RNHud().showHud(nil)
            getIsEnable(successClourue: { [weak self](state) in
                guard let s = self else {
                    RNHud().hiddenHub()
                    RNNoticeAlert.showError("提示", body: "跳转失败")
                    return
                }
                
                RNHud().hiddenHub()
                if state {
                    let submitVC = RNSubmitViewController(type: type, model: s.dataSource)
                    s.navigationController?.pushViewController(submitVC, animated: true)
                }
                else {
                    let submitVC = RNSecondSubmitViewController(type: type, model: s.dataSource)
                    s.navigationController?.pushViewController(submitVC, animated: true)
                }
                
                }, failureClousure: { [weak self](_, _) in
                    guard let s = self else {
                        RNHud().hiddenHub()
                        RNNoticeAlert.showError("提示", body: "跳转失败")
                        return
                    }
                    RNHud().hiddenHub()
                    let submitVC = RNSecondSubmitViewController(type: type, model: s.dataSource)
                    s.navigationController?.pushViewController(submitVC, animated: true)
            })
            
        }
        else {
            let submitVC = RNSecondSubmitViewController(type: type, model: dataSource)
            self.navigationController?.pushViewController(submitVC, animated: true)
        }
    }
    
    func parameters() {
        
        parameter["CRMID"] = model.crmId!
    }
    
    func refresh() {
        
        
        if isLoading {
            return
        }
        
        self.isLoading = !self.isLoading
        
        parameters() // 更新入参
        
        OrderServicer.orderDetail(parameter, successClourue: { (result) in
            
            //  RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            self.isLoading = !self.isLoading
            
            self.dataSource = result
            self.model.serviceItem = result.serviceItem
            
            self.createDataArray(result)
            self.headView.config(model: result)
            
            if let username = result.userName {
                self.backItem =  UIBarButtonItem.createLeftBarItem(title: username, target: self, action: #selector(self.dismissFromVC))
                self.setBackItem()
            }
            
            self.tableView.reloadData()
            
        }) { (msg, code) in
            
            self.isLoading = !self.isLoading
            self.tableView.es.stopPullToRefresh()
            if code == -1001 {
                
                let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
                
                let cancelButton = UIAlertAction(title: "确定", style: .cancel) { [weak self] _ in
                    if let s = self, s.isMsg == true {
                        s.navigationController?.popViewController(animated: true)
                    }else{
                        self?.dismissFromVC()
                    }
                }
                alert.addAction(cancelButton)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                RNNoticeAlert.showError("提示", body: msg)
            }
        }
        
    }
    
    func createDataArray(_ model: OrderDetail) {
        
        sectionOneTitles.removeAll()
        sectionOneContents.removeAll()
        sectionTwoTitles.removeAll()
        sectionTwoContents.removeAll()
        
        if model.crmId == nil {
            sectionOneTitles = ["送装信息", "快递单号"]
            sectionOneContents = ["", ""]
            sectionTwoTitles = ["区域代码", "机器品牌", "机器型号", "机器名称"]
            sectionOneContents = ["", "", "", ""]
            return
        }
        
        if let item = dataSource.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 6 { // 安装订单
            
            sectionOneTitles = ["送装信息", "快递单号"]
            
            if let way = dataSource.sendWay {
                if way == "1" {
                    sectionOneContents = [SendWay.sendTogether.rawValue]
                }else if way == "2" {
                    sectionOneContents = [SendWay.sendSeperator.rawValue]
                }else{
                    sectionOneContents = [""]
                }
            }else{
                sectionOneContents = ["未知"]
            }
            
            // 快递单号 --- TO DO : 后台取字段
            sectionOneContents.append(dataSource.expressCode ?? "")
            
        }
        
        sectionTwoTitles = ["区域代码", "机器品牌", "机器型号", "机器名称"]
        sectionTwoContents = [dataSource.areaCode ?? "", dataSource.productInfo!.companyName!, dataSource.productInfo!.productModel!, dataSource.productInfo!.productName!]
        
    }
    
    
    @objc func dismissFromVC(){
        
        if isDownload {
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            
            //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: GETORDER), object: nil) // 发出通知
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func shareAction()  { // 转单
        
        goTeam()
        //        let userInfo = realmQueryResults(Model: UserModel.self).last
        //
        //        guard let user = userInfo, let teamId = user.teamId else {
        //
        //            RNNoticeAlert.showError("提示", body: "未拿到小组id, 无法转单")
        //            return
        //        }
        //
        //        let teamGroupVC = RNTeamGroupViewController(teamid: teamId, groupName: "成员列表", identifier: "0") // identifier: 用于判断身份, 有效值为1,2,3,4
        //        teamGroupVC.isTransferOrder = true
        //        teamGroupVC.transferOrderId = dataSource.crmId
        //        self.navigationController?.pushViewController(teamGroupVC, animated: true)
    }
    
    
    func createQRView(_ title: String, content: String) {
        
        
        let view = Bundle.main.loadNibNamed("RNQRView", owner: nil, options: nil)?.last as? RNQRView
        view?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH-100, height: SCREEN_WIDTH-100)
        view?.center =  CGPoint(x: SCREEN_BOUNDS.width * 0.5, y: SCREEN_BOUNDS.height * 0.5)
        hudVC = RNTipHudViewController(view!)
        
        // 注意 size -- 根据 view.frame 以及 view?.qrImageView.frame 确定
        let image = RNQRGeneration.qrGenerate(content: content, size: CGSize(width: SCREEN_WIDTH-100-40, height: SCREEN_WIDTH-100-40), foregroundColor: MAIN_THEME_COLOR, icon: nil, watermark: nil)
        
        guard let im = image.image else{
            
            RNNoticeAlert.showError("提示", body:  image.des)
            return
        }
        view?.qrImageView.image = im
        view?.codeLabel.text = String(format: "%@: %@", title, content)
        
        
        window?.windowLevel = UIWindowLevelNormal
        window?.rootViewController = hudVC
        
        hudVC?.appWindow = UIApplication.shared.keyWindow
        
        hudVC?.callBack = { }
        
        window?.makeKeyAndVisible()
        
    }
    
    func robOrder() {
        
        guard let orderId = dataSource.orderId else {
            RNNoticeAlert.showError("提示", body: "未获取到订单 id")
            return
        }
        
        RNHud().showHud(nil)
        OrderServicer.robOrder(["orderid": orderId], successClourue: { [weak self] in
            RNHud().hiddenHub()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GetOrderSuccessNotification), object: nil) // 发送通知
            self?.type = OrderType.waitingDealing
            self?.setupBottom()
            self?.tableView.es.autoPullToRefresh()
            
            
            // 删除已抢订单的位置坐标缓存
            realmDeleteObject(Model: DestinationLocation.self) { (results) -> DestinationLocation? in
                
                return  results.filter({ (model) -> Bool in
                    if model.crmId == self?.dataSource.crmId{
                        return true
                    }
                    return false
                }).last
            }
            
            //           //   跳转下一界面 -- type是以已待处理的身份进入
            //            let commonDetailVC = RNCustomOrderDetailViewController(model: self!.model, type: OrderType.waitingDealing)
            //            commonDetailVC.isDownload = true
            //            self?.navigationController?.pushViewController(commonDetailVC, animated: true)
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}

// MARK: 关于转单
extension RNCustomOrderDetailViewController {
    
    func goTeam() {
        
        let userInfo = realmQueryResults(Model: UserModel.self).last
        
        guard let user = userInfo, let id = user.userId else {
            
            RNNoticeAlert.showError("提示", body: "未获取到用户 id")
            return
        }
        
        RNHud().showHud(nil)
        UserServicer.memberIdentifier(["userid": id], successClourue: { (userIdentifier) in
            RNHud().hiddenHub()
            
            switch userIdentifier.identifier {
            case "1"?: // 团队负责人
                
                self.checkState(identifier: "1", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到团队编号", refuseDes: "团队创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "2"?:
                self.checkState(identifier: "2", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "小组创建申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case "3"?:
                self.checkState(identifier: "3", state: userIdentifier.state, groupId: userIdentifier.groupId, GroupDes: "未获取到小组编号", refuseDes: "加入申请被拒绝, 请查明原因再申请...", waitDes: "审核中...")
                
                break
            case  "4"?:
                RNNoticeAlert.showError("提示", body: "未加入任何小组不能转单")
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
                groupListVC.isTransferOrder = true
                groupListVC.transferOrderId = dataSource.crmId
                self.navigationController?.pushViewController(groupListVC, animated: true)
                
            }else if (identifier == "2") || (identifier == "3"){
                let teamGroupVC = RNTeamGroupViewController(teamid: groupId, groupName: "成员列表", identifier: "0") // identifier: 用于判断身份, 有效值为1,2,3,4
                teamGroupVC.isTransferOrder = true
                teamGroupVC.transferOrderId = dataSource.crmId
                self.navigationController?.pushViewController(teamGroupVC, animated: true)
            }
            
            
        }else if state == "70003" {
            // 待审核
            RNNoticeAlert.showError("提示", body: waitDes)
        }else{
            
            // 拒绝
            RNNoticeAlert.showError("提示", body: "申请加入团队被拒绝,无法转单")
        }
        
    }
    
}


//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNCustomOrderDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 + typeLimit
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case typeLimit:
            return 1
        case 1+typeLimit:
            
            if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 6 { // 安装单 - 多送装信息和快递单号
                return 5
            }else if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{ // 移机 - 目的地址
                return 6
            }else{
                return 3
            }
        case 2+typeLimit:
            return 4
        case 3+typeLimit:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == (1 + typeLimit) {
            return UITableViewAutomaticDimension
            //            if indexPath.row == 1  || indexPath.row == 4{
            //                return UITableViewAutomaticDimension
            //            }else{
            //                return 44
            //            }
        }else if indexPath.section == (2+typeLimit) {
            return 44
        }else{
            return UITableViewAutomaticDimension
        }
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
        
        if dataSource.crmId == nil {
            return UITableViewCell()
        }
        // TO DO: 你会发现这里逻辑很恶心 >< 但它必须恶心🤢我也不想改
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailFeeCell", for: indexPath)
            
            if let cell = cell as? RNDetailFeeCell{
                cell.config(dataSource, titleString: "")
                cell.selectionStyle = .none
            }
        case typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
            if let cell = cell as? RNDetailCommonCell {
                var content = "无"
                // cell.contentLabel.textColor = UIColor.color(104, green: 104, blue: 104, alpha: 1) // UIColor.darkText
                if let serviceType = dataSource.serviceType, serviceType != "" {
                    content = serviceType
                }
                cell.config(dataSource, titleString: "报修类型", contentString: content)
                cell.selectionStyle = .none
            }
        case 1+typeLimit:
            if indexPath.row ==  0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailLinkerCell", for: indexPath)
                
                if let cell = cell as? RNDetailLinkerCell {
                    cell.config(dataSource, titleString: "联系人")
                    cell.delegate = self
                    cell.selectionStyle = .none
                    
                    if self.type == OrderType.getOrder {
                        cell.dailButton.isHidden = true
                    }
                    else {
                        cell.dailButton.isHidden = false
                    }
                }
            }else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAddressCell", for: indexPath)
                
                if let cell = cell as? RNDetailAddressCell {
                    cell.config(dataSource, titleString: "")
                    cell.delegate = self
                    cell.selectionStyle = .none
                }
            }else if indexPath.row == 2{
                
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    if let cell = cell as? RNDetailCommonCell {
                        var content = ""
                        cell.contentLabel.textColor = UIColor.color(104, green: 104, blue: 104, alpha: 1)
                        if let newCompany = dataSource.yjCompany, newCompany != "" {
                            content = newCompany
                        }
                        cell.config(dataSource, titleString: "新客户", contentString: content)
                        cell.selectionStyle = .none
                    }
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAppointmentCell", for: indexPath)
                    
                    if let cell = cell as? RNDetailAppointmentCell {
                        cell.orderModel = model
                        cell.delegate = self
                        cell.config(dataSource, titleString: "预约时间", type:  type.rawValue, viewController: self, indexPath: indexPath)
                        
                        if type == OrderType.getOrder {
                            cell.selectionStyle = .none
                        }else{
                            cell.selectionStyle = .gray
                        }
                        
                    }
                    
                }
            }else if indexPath.row == 3{
                
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNNewDetailLinkerCell", for: indexPath)
                    
                    if let cell = cell as? RNNewDetailLinkerCell {
                        cell.config(dataSource, titleString: "联系人")
                        cell.delegate = self
                        cell.selectionStyle = .none
                        
                        if self.type == OrderType.getOrder {
                            cell.dailButton.isHidden = true
                        }
                        else {
                            cell.dailButton.isHidden = false
                        }
                    }
                }else{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    
                    let title = sectionOneTitles[indexPath.row-3]
                    let content = sectionOneContents[indexPath.row-3]
                    
                    if let cell = cell as? RNDetailCommonCell {
                        cell.config(dataSource, titleString: title, contentString: content)
                        cell.selectionStyle = .none
                    }
                    
                }
            }else if indexPath.row == 4 {
                
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAddressCell", for: indexPath)
                    
                    if let cell = cell as? RNDetailAddressCell {
                        cell.isShiftMachine = true // 移机
                        cell.config(dataSource, titleString: "")
                        cell.delegate = self
                        cell.selectionStyle = .none
                    }
                    
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    
                    let title = sectionOneTitles[indexPath.row-3]
                    let content = sectionOneContents[indexPath.row-3]
                    
                    if let cell = cell as? RNDetailCommonCell {
                        cell.config(dataSource, titleString: title, contentString: content)
                        cell.selectionStyle = .none
                        if indexPath.row == 4 {
                            cell.contentLabel.isOpenTapGesture = true
                            cell.contentLabel.tapClosure = { [weak self] gesture in
                                
                                guard let expressCode = cell.contentLabel.text, expressCode != "", expressCode != "暂无" else {
                                    
                                    RNNoticeAlert.showError("提示", body: "快递单号为空或未取到快递单号")
                                    return
                                }
                                let tmpUrl = "https://m.kuaidi100.com/result.jsp?nu=" + expressCode
                                
                                let urlContrller = RNExpressShowViewController(nibName: "RNExpressShowViewController", bundle: nil)
                                urlContrller.tmpTitle = "物流详情"
                                urlContrller.URLString = tmpUrl
                                self?.navigationController?.pushViewController(urlContrller, animated:  true)
                                
                            }
                        }
                    }
                }
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAppointmentCell", for: indexPath)
                
                if let cell = cell as? RNDetailAppointmentCell {
                    cell.orderModel = model
                    cell.delegate = self
                    cell.config(dataSource, titleString: "预约时间", type:  type.rawValue, viewController: self, indexPath: indexPath)
                    
                    if type == OrderType.getOrder {
                        cell.selectionStyle = .none
                    }else{
                        cell.selectionStyle = .gray
                    }
                }
            }
        case 2+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
            let title = sectionTwoTitles[indexPath.row]
            let content = sectionTwoContents[indexPath.row]
            
            if let cell = cell as? RNDetailCommonCell {
                cell.config(dataSource, titleString: title, contentString: content)
                cell.selectionStyle = .none
            }
            
        case 3+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailNoteCell", for: indexPath)
            if let cell = cell as? RNDetailNoteCell {
                cell.config(dataSource, titleString: "")
                cell.selectionStyle = .none
            }
        default:
            cell = UITableViewCell()
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1+typeLimit {
            
            var skipIndex = 2
            if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                skipIndex = 5
            }
            if indexPath.row == skipIndex{
                
                if type == OrderType.getOrder {
                    return
                }
                
                guard let _ = dataSource.crmId else {
                    RNNoticeAlert.showError("提示", body: "订单详情未获取到,刷新一下试试")
                    return
                }
                
                let cell = tableView.cellForRow(at: indexPath) as? RNDetailAppointmentCell
                // 改约跳转
                if type == OrderType.subscibe {
                    
                    var actionType = "Appointment"
                    if let hometime = dataSource.homeTime, hometime != "" {
                        actionType = "ChangeTimeAppointment"
                    }
                    
                    let timeVC = RNTimeConfirmViewController(dataSource, type: type, actionType: actionType, orderModel: self.model)
                    timeVC.isShowSeg = false
                    timeVC.callBack = { time in
                        
                        cell?.contentLabel.text = time
                    }
                    self.navigationController?.pushViewController(timeVC, animated: true)
                    
                }else { // if type == OrderType.waitingDealing.rawValue ||  type == OrderType.getOrder.rawValue
                    
                    // 未预约跳转
                    
                    let timeVC = RNTimeConfirmViewController(dataSource, type: type, actionType: "Appointment", orderModel: self.model)
                    timeVC.waitDealCallback = { [weak self](_, _) in
                        self?.type = OrderType.subscibe
                        self?.setupBottom()
                        self?.tableView.es.autoPullToRefresh()
                    }
                    
                    self.navigationController?.pushViewController(timeVC, animated: true)
                    
                }
                
            }
        }
    }
}

//MARK: - RNActionSheetProtocol & MapViewControllerProtocol & RecordProtocol
extension RNCustomOrderDetailViewController: RNActionSheetProtocol, MapViewControllerProtocol, RecordProtocol{
    
    func showYoutobeActionView(array: [(image: String, title: String)]) {
        RNActionSheet.creatYoutobe(viewController: self, titles: array) { (index) in
            let num = array[index].title
            dailing(number: num)
        }
    }
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("抢单", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    func beginDailNumber(_ order: Order?, orderDetail: OrderDetail?) {
        
        guard let m = order else {
            RNNoticeAlert.showError("提示", body: "未获取到当前订单信息, 记录失败")
            return
        }
        
        guard let crmId = m.crmId else {
            RNNoticeAlert.showError("提示", body: "未获取到当前订单信息, 记录失败")
            return
            
        }
        
        
        let time = String(describing: Date())
        let params = ["CallTime": time, "CRMID": crmId]
        
        OrderServicer.recordSubscribeInfo(params, successClourue: {
            //
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}

// RNDetailAppointmentCellProtocol
extension RNCustomOrderDetailViewController: RNDetailAppointmentCellProtocol {
    
    func freshUI(indexPath index: IndexPath?) {
        
        if type == OrderType.getOrder {
            return
        }
        
        guard let myIndex = index else {
            return
        }
        let cell = tableView.cellForRow(at: myIndex) as? RNDetailAppointmentCell
        // 改约跳转
        if type == OrderType.subscibe {
            
            var actionType = "Appointment"
            if let hometime = dataSource.homeTime, hometime != "" {
                actionType = "ChangeTimeAppointment"
            }
            
            let timeVC = RNTimeConfirmViewController(dataSource, type: type, actionType: actionType, orderModel: self.model)
            timeVC.isShowSeg = false
            timeVC.callBack = { time in
                
                cell?.contentLabel.text = time
            }
            self.navigationController?.pushViewController(timeVC, animated: true)
            
        }else { // if type == OrderType.waitingDealing.rawValue ||  type == OrderType.getOrder.rawValue
            
            // 未预约跳转
            
            let timeVC = RNTimeConfirmViewController(dataSource, type: type, actionType: "Appointment", orderModel: self.model)
            timeVC.waitDealCallback = { [weak self](_, _)in
                self?.type = OrderType.subscibe
                self?.setupBottom()
                self?.tableView.es.autoPullToRefresh()
            }
            
            self.navigationController?.pushViewController(timeVC, animated: true)
            
        }
        
    }
}

