//
//  RNSearchOrderViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import ESPullToRefresh
import CoreLocation

class RNSearchTextField: UITextField {
    
    //  重写
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.leftViewRect(forBounds: bounds)
        padding.origin.x += 5
        return padding
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.rightViewRect(forBounds: bounds)
        padding.origin.x -= 5
        return padding
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.textRect(forBounds: bounds)
        padding.origin.x += 5
        return padding
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.editingRect(forBounds: bounds)
        padding.origin.x += 5
        return padding
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.placeholderRect(forBounds: bounds)
        padding.origin.x += 5
        return padding
    }
}

class RNSearchOrderViewController: RNBaseTableViewController {
    
    var searchBar: RNSearchTextField? = nil
    var keyword: String? = nil
    
    var tableView: UITableView!
    var typeButton: UIButton!
    
    lazy var dataSource: [Order] = {
        return [Order]()
    }()

    var page = 1
    var pagesize = 20
    var parameter = [String: Any]()
 
    let orderTypes: [(code:String, title:String)] = [("123", "全部"), ("123000006", "安装"), ("123000007", "维修维护"), ("123000014", "充水+清洁"), ("123000001", "退机"), ("123000002", "换机"), ("123000003", "移机"), ("123000008", "换芯"), ("123000009", "送货"),  ("123000004", "充水"), ("123000005", "整改"), ("123000010", "水质检测"), ("123000011", "现场勘测"), ("123000012", "清洁消毒")]
    var selectedType:String? = nil

    var defaultTypeIndex = 1 // 默认已预约类型
    lazy var types: [String] = {
       
        return [OrderType.waitingDealing.rawValue, OrderType.subscibe.rawValue, OrderType.completed.rawValue]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

       view.backgroundColor = BASEBACKGROUNDCOLOR
        
        setupTabs()
        setupNav()
        
        setupUI()
        addObserveAction()
        
        parameter["actiontype"] = OrderType.subscibe.rawValue /// 默认搜索已预约
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        //navigationController?.navigationBar.isHidden = true
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
       // navigationController?.navigationBar.isHidden = false
        IQKeyboardManager.sharedManager().enable = false
    }
}

//MARK: custom methods
extension RNSearchOrderViewController {
    
    func setupTabs() {
        let switchView = RNTypeSwitchView(frame: CGRect(x: 0, y: 64 + 5, width: SCREEN_WIDTH, height: 44), types: orderTypes)
        switchView.backgroundColor = UIColor.clear
        switchView.callBack = { [weak self]indexpath in
            
            if indexpath.item == 0 {
                self?.selectedType = nil
            }else{
                let item = self?.orderTypes[indexpath.item]
                if let i = item{
                    self?.selectedType = i.code
                }
            }
            
            self?.refresh()
        }
        view.addSubview(switchView)
    }
    func setupNav() {
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        backView.backgroundColor = MAIN_THEME_COLOR
        view.addSubview(backView)
        
        let backButton = UIButton(frame: CGRect(x: 8, y: 20 + 7, width: 30, height: 30))
        backButton.setImage(UIImage(named: "nav_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backView.addSubview(backButton)
        
        let typeView = UIView(frame: CGRect(x: backButton.frame.maxX + 5, y: 20 + 7, width: 60, height: 30))
        typeView.backgroundColor = UIColor.clear
        backView.addSubview(typeView)
        
        typeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 52, height: 30))
        typeButton.setTitle(types[defaultTypeIndex], for: .normal)
        typeButton.tag = defaultTypeIndex
        typeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        typeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        typeButton.addTarget(self, action: #selector(shiftType(sender:)), for: .touchUpInside)
        typeView.addSubview(typeButton)
        
        let imageView = UIImageView(frame: CGRect(x: typeButton.frame.maxX+2, y: 24, width: 6, height: 6))
        imageView.image = UIImage(named: "order_down")
        imageView.contentMode = .bottomRight
        typeView.addSubview(imageView)
        
        searchBar = RNSearchTextField(frame: CGRect(x: typeView.frame.maxX + 8, y: 20 + 7, width: SCREEN_WIDTH - 8 - backButton.frame.width - 5 - typeView.frame.width - 8 - 15, height: 30))
        searchBar?.backgroundColor = UIColor.white
        searchBar?.font = UIFont.systemFont(ofSize: 14)
        searchBar?.delegate = self
        searchBar?.leftViewMode = .always
        searchBar?.rightViewMode = .always
        searchBar?.contentVerticalAlignment = .center
        searchBar?.placeholder = "搜索地址/姓名/电话/工单号"
        searchBar?.returnKeyType = .search
        searchBar?.layer.masksToBounds = true
        searchBar?.layer.cornerRadius = 15
      //  searchBar?.addTarget(self, action: #selector(myTextChange(textField:)), for: .allEditingEvents)
        searchBar?.becomeFirstResponder()
        backView.addSubview(searchBar!)
        
        let leftIm = UIImageView(frame: CGRect(x: 0, y: 7, width: 15, height: 15))
        leftIm.image = UIImage(named: "order_search")
        leftIm.contentMode = .scaleAspectFit
        searchBar?.leftView = leftIm
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 7, width: 20, height: 20))
        rightButton.setImage(UIImage(named:"order_cancel"), for: .normal)
        rightButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        searchBar?.rightView = rightButton
    }
    
    func setupUI() {
        
        if #available(iOS 11, *) {
             tableView = UITableView(frame: CGRect(x: 0, y: 64 + 44, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 44 - 5), style: .grouped)
        }else{
             tableView = UITableView(frame: CGRect(x: 0, y: 64 + 44, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 44 - 5), style: .grouped)
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNWaitingDealingCell", bundle: nil), forCellReuseIdentifier: "RNWaitingDealingCell")
        tableView.register(UINib.init(nibName: "RNCompletedCell", bundle: nil), forCellReuseIdentifier: "RNCompletedCell")
        
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
      //  tableView.expriedTimeInterval = 3 // 刷新过期时间
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }

    func parameters() {
        
        parameter["pagesize"] = pagesize
        parameter["pageindex"] = page
        
        if let k = keyword {
            parameter["Keyword"] = k
        }else{
            parameter["Keyword"] = nil
        }
        
        if let t = selectedType  {
            parameter["ServiceItem"] = t
        }else{
            parameter["ServiceItem"] = nil
        }
    }

    func refresh() {
        
        if keyword == nil {
            self.tableView.es.stopPullToRefresh()
            return
        }
        
        page = 1
        
        parameters() // 更新入参
        
        //  tableView.es.resetNoMoreData()
        
        RNHud().showHud(nil)
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
            RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            
            self.dataSource.removeAll()
            self.dataSource = result
            
            if result.count < 20 {
                
                // self.tableView.es.noticeNoMoreData() // 下拉加载通知无数据后,不在底部提示无更多数据,且上拉操作也被禁止
            }
            
            // 删除坐标缓存
            // realmDeleteObjectsWithoutCondition(Model: DestinationLocation.self)
            
            
            self.tableView.reloadData()
            
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
        
    }
    
    func loadMore() {
        
        page += 1
        
        parameters()
        
        OrderServicer.orderList(parameter, successClourue: { (result) in
            
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

//MARK: event repsonse
extension RNSearchOrderViewController {
    
    @objc func backAction(){
        
        if let s = searchBar, s.isExclusiveTouch == true{
            s.resignFirstResponder()
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func shiftType(sender: UIButton) {
        
        let alert = UIAlertController(title: "请选择搜索的订单类型", message: nil, preferredStyle: .actionSheet)
        let waitDealButton = UIAlertAction(title: "未处理", style: .default) { [weak self](_) in
            self?.defaultTypeIndex = 0
            self?.typeButton.setTitle("未处理", for: .normal)
            self?.parameter["actiontype"] = OrderType.waitingDealing.rawValue
            self?.isRefresh()
        }
        let subscribeButton = UIAlertAction(title: "已预约", style: .default) { [weak self](_) in
            self?.defaultTypeIndex = 1
            self?.typeButton.setTitle("已预约", for: .normal)
            self?.parameter["actiontype"] = OrderType.subscibe.rawValue
            self?.isRefresh()
        }
        let completedButton = UIAlertAction(title: "已完成", style: .default) { [weak self](_) in
            self?.defaultTypeIndex = 2
            self?.typeButton.setTitle("已完成", for: .normal)
            self?.parameter["actiontype"] = OrderType.completed.rawValue
            self?.isRefresh()
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(waitDealButton)
        alert.addAction(subscribeButton)
        alert.addAction(completedButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alert, animated: true, completion: nil)
        }
        
//        if defaultTypeIndex == 0 {
//            defaultTypeIndex = 1
//            sender.setTitle(types[defaultTypeIndex], for: .normal)
//            parameter["actiontype"] = OrderType.waitingDealing.rawValue
//        }else{
//            defaultTypeIndex = 0
//            sender.setTitle(types[defaultTypeIndex], for: .normal)
//            parameter["actiontype"] = OrderType.subscibe.rawValue
//        }
    }
    
    func isRefresh() {
        if keyword != nil {
            RNHud().showHud(nil)
            refresh()
        }
    }
    
    @objc func cancelSearch() {
        
        searchBar?.text = nil
        keyword = nil
//        if let s = searchBar{
//            s.resignFirstResponder()
//        }

        dataSource.removeAll()
        tableView.reloadData()
    }
    
    func myTextChange(textField: RNSearchTextField) {
        keyword = textField.text
        
        if keyword == ""{
            return
        }
        refresh()
    }
    // 观察者
    func addObserveAction() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: SubscibeSuccessNotification), object: nil) // 预约成功
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: NoServiceFinishOrderNotification), object: nil) // 无服务完成
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: TransferOrderSuccessNofitication), object: nil) // 转单成功
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 结单成功
    }
    
    @objc func notificationAction(){
        self.tableView.es.autoPullToRefresh() // 自动刷新
    }

}


//MARK: - UITextFieldDelegate
extension RNSearchOrderViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        myTextChange(textField: searchBar!)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        return true
    }
}


//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSearchOrderViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
        
        
        if defaultTypeIndex == 2 { // 已完成
            cell = tableView.dequeueReusableCell(withIdentifier: "RNCompletedCell", for: indexPath)
        }else{
           cell = tableView.dequeueReusableCell(withIdentifier: "RNWaitingDealingCell", for: indexPath)
        }
        let model = dataSource[indexPath.section]
        
        if let cell = cell as? RNWaitingDealingCell {
            // 显示
            if !model.isInvalidated{
                cell.config(model: model)
                cell.delegate = self
                cell.state = 2
                cell.vc = self
                
                if self.defaultTypeIndex == 1 {
                    cell.dailButton.isHidden = true
                    cell.timeLabel.isHidden = false
                }else if self.defaultTypeIndex == 0{
                    cell.dailButton.isHidden = false
                    cell.timeLabel.isHidden = true
                }
            }
            
        }else if let cell = cell as? RNCompletedCell {
            if !model.isInvalidated {
                cell.config(model: model)
                cell.delegate = self as MapViewControllerProtocol
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section]
        
        switch defaultTypeIndex {
        case 0:
            let commonDetailVC = RNCustomOrderDetailViewController(model: model, type: OrderType.waitingDealing)
            let nav = RNBaseNavigationController(rootViewController: commonDetailVC)
            RNHud().showHud(nil)
            present(nav, animated: true) {
                RNHud().hiddenHub()
            }
        case 1:
            let commonDetailVC = RNCustomOrderDetailViewController(model: model, type: OrderType.subscibe)
            let nav = RNBaseNavigationController(rootViewController: commonDetailVC)
            RNHud().showHud(nil)
            present(nav, animated: true) {
                RNHud().hiddenHub()
            }
        case 2:
            let completedDetailVC = RNCompletedOrderDetailViewController(model: model, type: OrderType.completed)
            let nav = RNBaseNavigationController(rootViewController: completedDetailVC)
            RNHud().showHud(nil)
            present(nav, animated: true) {
                RNHud().hiddenHub()
            }
        default:
            break
        }
    }
}

//MARK: - RNActionSheetProtocol & MapViewControllerProtocol
extension RNSearchOrderViewController: RNActionSheetProtocol, MapViewControllerProtocol, RecordProtocol{
    
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

