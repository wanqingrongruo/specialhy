//
//  RNCompletedOrderDetailViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/26.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift
import ESPullToRefresh
import CoreLocation
import Spring

class RNCompletedOrderDetailViewController: RNBaseTableViewController {
    
    var type: OrderType  // 订单类型 -- 具体一些特征显示
    var model: Order
    
    var isWatingPay = false // 判断是否是从待支付过来, 默认 false
    var isComment = false // 判断是否是从我的评价过来, 默认 false
    var isServiceTrain = false // 判断是否是从直通车过来, 默认 false
    
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
    var bottomView: RNFinishingView?
    var bottomView02: RNSigleButtonView?
    
    var isMsg = false // 判断是否是从通知界面进入 -- 目标就是不同的返回操作 pop
    var currentType: Int = 0 // 当前订单类型的 code, 方便判断. 范围 1-12
    lazy var typeArray: [Int] = { // 订单类型code数组
        var arr: [Int] = [Int]()
        for i in 1...ServiceItemDictionary.count{
            arr.append(i)
        }
        
        return arr
    }()
    
    lazy var dataSource: CompletedOrderDetail = {
        
        let models = realmQueryModel(Model: CompletedOrderDetail.self) { (results) -> Results<CompletedOrderDetail>? in
            return results.filter("crmId = %@", self.model.crmId ?? "" )
        }
        
        if let ms = models, let m = ms.last {
            return m.copy() as! CompletedOrderDetail
        }
        
        return CompletedOrderDetail()
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
    
    
    lazy var fourTitles: [String] = { // 第四组
        let ones = ["设备管理号", "机器IMEI", "机器ICCID", "机器MAC","直通车编号"]
        return ones
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
        
      //  navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItem("nav_share", target: self, action: #selector(shareAction))
        
       if let serviceItem = model.serviceItem, let tuple = ServiceItemDictionary[serviceItem]{ // 安装或换机单需要选择送装信息
            self.currentType = tuple.code
        }
        guard typeArray.contains(currentType)  else {
            RNNoticeAlert.showError("提示", body: "未在本地找到对应类型的订单,请等待后续更新")
            return
        }
        
        setUpFourDatas()
        
        setupUI()
        
        if dataSource.crmId != nil {
            
            self.createDataArray(dataSource)
          //  self.tableView.reloadData()
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
    
//    func shareAction() {
//        let image = RNScreenShotManager.shot(for: tableView)
//        if let im  = image {
//            RNScreenShotManager.saveImageToAblum(image: im)
//        }
//    }
}

//MARK: - custom methods

extension RNCompletedOrderDetailViewController{
    
    func setupUI() {
        
        if type == .waitPay {
            if #available(iOS 11, *) {
                 tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60 - 64), style: .grouped)
            }else{
                tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60), style: .grouped)
            }
           
        }else{
            if #available(iOS 11, *) {
                 tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-64), style: .grouped)
            }else{
                 tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
            }
          
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
        tableView.register(UINib.init(nibName: "RNCompletedCustomCell", bundle: nil), forCellReuseIdentifier: "RNCompletedCustomCell")
        tableView.register(UINib.init(nibName: "RNCompletedImageCell", bundle: nil), forCellReuseIdentifier: "RNCompletedImageCell")
        tableView.register(UINib.init(nibName: "RNSkipCell", bundle: nil), forCellReuseIdentifier: "RNSkipCell")
        tableView.register(UINib.init(nibName: "RNCommentCell", bundle: nil), forCellReuseIdentifier: "RNCommentCell")
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
//                    RNNoticeAlert.showInfo("提示", body: "浩泽编号为空")
//                    return
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
        
        switch type {
        case .waitPay:
//            bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
//            bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
//            (bottomView as! RNSigleButtonView).sigleButton.setTitle("去支付", for: .normal)
//            (bottomView as! RNSigleButtonView).callBack = { [weak self] tag in
////
////                // 去支付
////                if let id = self?.dataSource.orderId {
////                    let payVC = RNPayViewController(id)
////                    payVC.isWaitPay = true
////                    self?.navigationController?.pushViewController(payVC, animated: true)
////                }else{
////                    RNNoticeAlert.showError("提示", body: "由于未拿到订单 id,无法进行支付")
////                }
//                if let s = self, let id = s.model.crmId {
//                    s.skipToPay(with: id)
//                }
//                else {
//                    RNNoticeAlert.showError("提示", body: "由于未拿到订单id,无法进入收款界面")
//                }
//
//            }
//            view.addSubview(bottomView!)
            
            var currentType = 0 // 当前的订单类型
            if let type =  model.serviceItem, let tuple = ServiceItemDictionary[type]{
                currentType = tuple.code
            }
            
            if currentType == filterCode { // 冲水单 -- 通联
                getIsEnable(successClourue: { [weak self](state) in
                    guard let s = self else {
                        RNNoticeAlert.showError("提示", body: "跳转失败")
                        return
                    }
                    if state {
                       s.finishView()
                    }
                    else {
                       s.singleView()
                    }
                }, failureClousure: { [weak self](msg, code) in
                     self?.singleView()
                })
            }
            else {
                singleView()
            }
          
        default:
            break
        }
//        if dataSource.crmId == nil {
//            tableView.es.autoPullToRefresh()
//        }
//        else {
//            headView.config02(model: dataSource)
//            bottomView?.money = dataSource.payMoney
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.es.autoPullToRefresh()
        }
    }
    
    func finishView() {
        bottomView = Bundle.main.loadNibNamed("RNFinishingView", owner: self, options: nil)?.last as? RNFinishingView
        bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
        bottomView?.btnTitle = "去支付"
        bottomView?.completeCallback = { [weak self] in
            // 提交
            if let s = self, let id = s.model.crmId {
                s.skipToPay(with: id)
            }
            else {
                RNNoticeAlert.showError("提示", body: "由于未拿到订单id,无法进入收款界面")
            }
        }
        view.addSubview(bottomView!)
    }
    func singleView() {
        bottomView02 = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
        bottomView02?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
        bottomView02?.sigleButton.setTitle("去支付", for: .normal)
        bottomView02?.callBack = { [weak self] tag in
            // 去支付
            if let id = self?.dataSource.orderId {
               self?.payView(with: id)
            }else{
                RNNoticeAlert.showError("提示", body: "由于未拿到订单 id,无法进行支付")
            }
        }
        view.addSubview(bottomView02!)
    }
    
    private func skipToPay(with crmId: String) {
        payInfo(with: crmId)
    }
    
    func payInfo(with crmId: String) {
        let payInfoVC = RNPayInfoViewController.init(crmId, oznerId: dataSource.documentNo ?? "", whereCome: ComePayWay.waitPay)
        payInfoVC.totalMoney = (dataSource.payMoney == 0) ? nil : dataSource.payMoney // 当等于0时自己计算
        payInfoVC.isWaitPay = true
      //  payInfoVC.isWaitDetailVC = true
        navigationController?.pushViewController(payInfoVC, animated: true)
    }
    func payView(with crmId: String) {
        let payVC = RNPayViewController(crmId)
        payVC.isWaitPay = true
       // payVC.isWaitDetailVC = true
        navigationController?.pushViewController(payVC, animated: true)
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
        
        OrderServicer.orderDetailForCompletedOreder(parameter, successClourue: { (result) in
            
            self.tableView.es.stopPullToRefresh()
            self.isLoading = !self.isLoading
            
            self.dataSource = result
            self.model.serviceItem = result.serviceItem
            
            self.createDataArray(result)
            self.headView.config02(model: result)
            self.bottomView?.money = result.payMoney
            
            if let username = result.userName {
                self.backItem =  UIBarButtonItem.createLeftBarItem(title: username, target: self, action: #selector(self.dismissFromVC))
                self.setBackItem()
            }
            
            self.tableView.reloadData()
        }) { (msg, code) in
            
            self.isLoading = !self.isLoading
            self.tableView.es.stopPullToRefresh()
            
        }
        
    }
    
    func createDataArray(_ model: CompletedOrderDetail) {
        
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
    
    // 根据订单类型准备数据源
    func setUpFourDatas() {
        
        switch currentType {
        case 1,2: // 退机 + 换机
            fourTitles.append(contentsOf: ["剩余水值", "服务原因"])
            break
        case 3: // 移机
            fourTitles.append(contentsOf: ["剩余水值", "水压", "源水TDS", "活水TDS", "服务原因"])
            break
        case 4: // 充水
            fourTitles.append(contentsOf: ["问题备注"])
            break
        case 5, 8: // 整改 + 换芯
            fourTitles.append(contentsOf: ["剩余水值", "服务原因", "问题备注"])
            break
        case 6: // 安装
            fourTitles.append(contentsOf: ["安装确认单编号", "水压", "开箱状态", "源水TDS", "活水TDS", "备注描述"])
            break
        case 7: // 维护维修
            fourTitles.append(contentsOf: ["剩余水值", "源水TDS", "活水TDS", "问题备注"])
            break
        case 9, 11, 12: // 送货 + 现场勘测 + 清洁消毒
            // 无第二组
            break
        case 10: // 水质检测
            fourTitles.append(contentsOf: ["源水TDS", "活水TDS"] ) //["源水TDS", "活水TDS","监测值"] => 取消水值监测值
            break
        default:
            break
        }
    }
    
    // 获取支付方式
    func getPayWay(string: String) -> String{
        
        switch string {
        case PayWay.Wx.rawValue:
            return "微信支付"
        case PayWay.Cash.rawValue:
            return "现金支付"
        case PayWay.Pos.rawValue:
            return "Pos机支付"
        case PayWay.NoPay.rawValue:
            return "无需支付"
        case PayWay.Alipay.rawValue:
            return "支付宝支付"
        case PayWay.BankOnline.rawValue:
            return "网银支付"
        case PayWay.BzCard.rawValue:
            return "保障卡支付"
        case PayWay.Partner.rawValue:
            return "扣合作方款"
        case PayWay.Scan.rawValue:
            return "扫码支付"
        case PayWay.HelpPay.rawValue:
            return "售后代付"
            
        default:
            return "未知"
        }
    }
    
}

//MARK: - event response

extension RNCompletedOrderDetailViewController{
    
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
    
    
    @objc func dismissFromVC(){
        
        if isMsg || isWatingPay || isComment || isServiceTrain {
            _ = self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}


//MARK: - UITableViewDelegate & UITableViewDataSource

extension RNCompletedOrderDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if isComment {
            return 8 + typeLimit
        }
        return 7 + typeLimit
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
        case 4+typeLimit:
            return fourTitles.count
        case 5+typeLimit:
            return 1
        case 6+typeLimit:
            var currentType = 0 // 当前的订单类型
            if let type =  model.serviceItem, let tuple = ServiceItemDictionary[type]{ // 安装或换机单需要选择送装信息 + 退机单需要弹框
                currentType = tuple.code
            }
            
            if currentType == filterCode { // 冲水单 -- 通联
                return 4 + 1
            }
            return 4
        case 7+typeLimit:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == (1+typeLimit) {

            if indexPath.row == 1  || indexPath.row == 4{
                return UITableViewAutomaticDimension
            }else{
                return 44
            }
        }else if indexPath.section == (2+typeLimit) {
            return 44
        }else if indexPath.section == (4+typeLimit) {
            return 44
        }else if indexPath.section == (6+typeLimit) {
            return 44
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 50
        case typeLimit:
            return 44
        case 1+typeLimit:
            return 44
        case 2+typeLimit:
            return 44
        case 3+typeLimit:
            return 60
        case 4+typeLimit:
            return 44
        case 5+typeLimit:
            return (SCREEN_WIDTH-8*2-5*3)/4 + 20
        case 6+typeLimit:
            return 44
        case 7+typeLimit:
            return 44
        default:
            return 0
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
        
        switch indexPath.section {
        case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailFeeCell", for: indexPath)
                
                if let cell = cell as? RNDetailFeeCell{
                    cell.config02(dataSource, titleString: "")
                    cell.selectionStyle = .none
                }
        case typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
            if let cell = cell as? RNDetailCommonCell {
                var content = "无"
                //cell.contentLabel.textColor = UIColor.color(104, green: 104, blue: 104, alpha: 1) //UIColor.darkText
                if let serviceType = dataSource.serviceType, serviceType != "" {
                    content = serviceType
                }
                cell.config02(dataSource, titleString: "报修类型", contentString: content)
                cell.selectionStyle = .none
            }
            
        case 1+typeLimit:
            if indexPath.row ==  0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailLinkerCell", for: indexPath)
                
                if let cell = cell as? RNDetailLinkerCell {
                    cell.config02(dataSource, titleString: "联系人")
                    cell.dailButton.isHidden = true
                    cell.selectionStyle = .none
                }
            }else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAddressCell", for: indexPath)
                
                if let cell = cell as? RNDetailAddressCell {
                    cell.config02(dataSource, titleString: "")
                    cell.delegate = self
                    cell.selectionStyle = .none
                }
            }else if indexPath.row == 2{
                
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    if let cell = cell as? RNDetailCommonCell {
                        var content = ""
                        cell.contentLabel.textColor = UIColor.black
                        if let newCompany = dataSource.yjCompany, newCompany != "" {
                            content = newCompany
                        }
                        cell.config02(dataSource, titleString: "新客户", contentString: content)
                        cell.selectionStyle = .none
                    }
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAppointmentCell", for: indexPath)
                    
                    if let cell = cell as? RNDetailAppointmentCell {
                        cell.orderModel = model
                        cell.config02(dataSource, titleString: "预约时间", type:  type.rawValue, viewController: self)
                        cell.appointmentButton.isHidden = true
                        cell.selectionStyle = .none
                    }
                    
                }
                
//                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
//                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAddressCell", for: indexPath)
//
//                    if let cell = cell as? RNDetailAddressCell {
//                        cell.isShiftMachine = true // 移机
//                        cell.config02(dataSource, titleString: "")
//                        cell.delegate = self
//                        cell.selectionStyle = .none
//                    }
//                }else{
//                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAppointmentCell", for: indexPath)
//
//                    if let cell = cell as? RNDetailAppointmentCell {
//                        cell.orderModel = model
//                        cell.config02(dataSource, titleString: "预约时间", type:  type.rawValue, viewController: self)
//                        cell.appointmentButton.isHidden = true
//                        cell.selectionStyle = .none
//                    }
//
//                }
            }else if indexPath.row == 3{
                
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNNewDetailLinkerCell", for: indexPath)
                    
                    if let cell = cell as? RNNewDetailLinkerCell {
                        cell.config02(dataSource, titleString: "联系人")
                        cell.selectionStyle = .none
                        cell.dailButton.isHidden = true
                    }
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    
                    guard sectionOneTitles.count > (indexPath.row - 3) else{
                        return UITableViewCell()
                    }
                    guard sectionOneContents.count > (indexPath.row - 3) else{
                        return UITableViewCell()
                    }
                    let title = sectionOneTitles[indexPath.row-3]
                    let content = sectionOneContents[indexPath.row-3]
                    
                    if let cell = cell as? RNDetailCommonCell {
                        cell.config02(dataSource, titleString: title, contentString: content)
                        cell.selectionStyle = .none
                    }

                }
            }else if indexPath.row == 4{
                if let item = model.serviceItem, let tuple = ServiceItemDictionary[item], tuple.code == 3{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAddressCell", for: indexPath)
                    
                    if let cell = cell as? RNDetailAddressCell {
                        cell.isShiftMachine = true // 移机
                        cell.config02(dataSource, titleString: "")
                        cell.selectionStyle = .none
                    }
                    
                }else{
                    cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
                    
                    let title = sectionOneTitles[indexPath.row-3]
                    let content = sectionOneContents[indexPath.row-3]
                    
                    if let cell = cell as? RNDetailCommonCell {
                        cell.config02(dataSource, titleString: title, contentString: content)
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
            } else{
                cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailAppointmentCell", for: indexPath)
                
                if let cell = cell as? RNDetailAppointmentCell {
                    cell.orderModel = model
                    cell.config02(dataSource, titleString: "预约时间", type:  type.rawValue, viewController: self)
                    cell.appointmentButton.isHidden = true
                    cell.selectionStyle = .none
                }
            }
        case 2+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailCommonCell", for: indexPath)
            let title = sectionTwoTitles[indexPath.row]
            let content = sectionTwoContents[indexPath.row]
            
            if let cell = cell as? RNDetailCommonCell {
                cell.config02(dataSource, titleString: title, contentString: content)
                cell.selectionStyle = .none
            }
            
        case 3+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNDetailNoteCell", for: indexPath)
            if let cell = cell as? RNDetailNoteCell {
                cell.config02(dataSource, titleString: "")
                cell.selectionStyle = .none
            }
        case 4+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNCompletedCustomCell", for: indexPath)
            if let cell = cell as? RNCompletedCustomCell {
                cell.selectionStyle = .none
                cell.config(model: dataSource, titles: fourTitles, indexPath: indexPath, type: currentType, viewController: self)
            }
        case 5+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNCompletedImageCell", for: indexPath)
            if let cell = cell as? RNCompletedImageCell {
                cell.selectionStyle = .none
                
                var images = [ImageModel]()
                for item in dataSource.images {
                    images.append(item)
                }
                cell.config(indexPath: indexPath,images: images, viewController: self)
            }
        case 6+typeLimit:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
            if let cell = cell as? RNSkipCell {
                //  cell.config02(dataSource, titleString: "")
                if indexPath.row == 3{
                    cell.accessoryType = .none
                    cell.selectionStyle = .none
                }
                
                switch indexPath.row {
                case 0:
                    cell.config02(title: "故障&解决", tip: "点击查看", indexPath: indexPath, viewController: self)
                case 1:
                    cell.config02(title: "配件使用", tip: "点击查看", indexPath: indexPath, viewController: self)
                case 2:
                    cell.config02(title: "费用统计", tip: "点击查看", indexPath: indexPath, viewController: self)
                case 3:
                    if let payWay = dataSource.payWay{
                        cell.config02(title: "支付方式", tip: getPayWay(string: payWay), indexPath: indexPath, viewController: self)
                    }
                case 4:
                    var currentType = 0 // 当前的订单类型
                    if let type =  model.serviceItem, let tuple = ServiceItemDictionary[type]{ // 安装或换机单需要选择送装信息 + 退机单需要弹框
                        currentType = tuple.code
                    }
                    
                    if currentType == filterCode { // 冲水单 -- 通联
                        // 接口控制
                        cell.accessoryType = .none
                        cell.selectionStyle = .none
                        cell.config02(title: "订单金额", tip: String(format: "%.2lf元", dataSource.payMoney), indexPath: indexPath, viewController: self)
                    }
                    else {
                        // 不显示
                    }
                   
                default:
                    break
                }
            }
            
        case 7+typeLimit:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNCommentCell", for: indexPath)
            if let cell = cell as? RNCommentCell {
                
                // 评价内容
                cell.config(model: dataSource, titles: fourTitles, indexPath: indexPath, type: currentType, viewController: self)
            }
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 6+typeLimit {
            
            switch  indexPath.row {
            case 0:
                // 问题 and 解决
                
                var rsArray = [SolutionModel]()
                _ = dataSource.solutionInfo.forEach({ (m) in
                    rsArray.append(m)
                })

                guard rsArray.count > 0 else {
                    RNNoticeAlert.showInfo("提示", body: "故障&解决信息为空")
                    return
                }
                let rsVC = RNRSDetailViewController(rsArray)
                self.navigationController?.pushViewController(rsVC, animated: true)
                break
            case 1:
                // 配件列表
                var partArray = [CompletedPartModel]()
                _ = dataSource.products.forEach({ (m) in
                    partArray.append(m)
                })

                guard partArray.count > 0 else {
                    RNNoticeAlert.showInfo("提示", body: "配件信息为空")
                    return
                }
                let partVC = RNPartDetailViewController(partArray)
                self.navigationController?.pushViewController(partVC, animated: true)
                break
            case 2:
                //费用统计
                var moneyArray = [MoneyModel]()
                _ = dataSource.moneyList.forEach({ (m) in
                    moneyArray.append(m)
                })
                guard moneyArray.count > 0 else {
                    RNNoticeAlert.showInfo("提示", body: "费用信息为空")
                    return
                }
                let moneyVC =  RNFeeDetailViewController(moneyArray)
                self.navigationController?.pushViewController(moneyVC, animated: true)
                break
            default:
                break
            }
        }
        
    }
}

//MARK: - MapViewControllerProtocol
extension RNCompletedOrderDetailViewController: MapViewControllerProtocol{
    
    func showMapView(destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        let mapVC = RNMapViewController.init("抢单", destinationLocation: destinationLocation, destinationString: destinationString)
        let nav = RNBaseNavigationController(rootViewController: mapVC)
        self.present(nav, animated: true, completion: nil)
    }
    
}

