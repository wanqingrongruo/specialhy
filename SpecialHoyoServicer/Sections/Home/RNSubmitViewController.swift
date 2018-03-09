//
//  RNSubmitViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreLocation

class RNSubmitViewController: RNBaseTableViewController {
    
    var type: String
    var model: OrderDetail
    init(type t: String, model m: OrderDetail) {
        self.type = t
        self.model = m
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // properties
    var currentType: Int = 0 // 当前订单类型的 code, 方便判断. 范围 1-12
    lazy var typeArray: [Int] = { // 订单类型code数组
        var arr: [Int] = [Int]()
        for i in 1...ServiceItemDictionary.count{
            arr.append(i)
        }
        
        return arr
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60-5) , style: .plain)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "RNSubmitCustomCell", bundle: nil), forCellReuseIdentifier: "RNSubmitCustomCell")
        tableView.register(UINib.init(nibName: "RNSubmitWithoutQRCell", bundle: nil), forCellReuseIdentifier: "RNSubmitWithoutQRCell")
        tableView.register(UINib.init(nibName: "RNLeftWaterCell", bundle: nil), forCellReuseIdentifier: "RNLeftWaterCell")
        tableView.register(UINib.init(nibName: "RNImageCell", bundle: nil), forCellReuseIdentifier: "RNImageCell")
        tableView.register(UINib.init(nibName: "RNSkipCell", bundle: nil), forCellReuseIdentifier: "RNSkipCell")
        tableView.register(UINib.init(nibName: "RNBoxStateCell", bundle: nil), forCellReuseIdentifier: "RNBoxStateCell")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        return tableView
    }()
    
    lazy var dataSource: [[String]] = {
        
        var arr = [[String]]()
        let ones = ["设备管理号","直通车编号"] //  "机器IMEI", "机器ICCID", "机器MAC"
        arr.append(ones)
        return arr
    }()
    
    var isTwoSection = false //  送货 + 现场勘测 + 清洁消毒 三种类型的订单只有两组
    
//    var bottomView: RNSigleButtonView?
    var bottomView: RNFinishingView?
    //MARK: - 参数
    var orderFinishInfo: String? = nil // json串
    var imageParams: [UIImage] = { // 图片
        return [UIImage]()
    }()
    lazy var parameters: [String: Any] = { // 参数 -> json串
        return [String: Any]()
    }()
    var distanceString: Double? = nil // 距离,单位 KM
    //MARK: 回调数据
    lazy var troubleArray: [String] = { // 已选故障&解决
        
        return [String]()
    }()
    lazy var partArray: [PartModel] = { // 已选配件
        return [PartModel]()
    }()
    // 其他费用类型数组 -- 另一个控制器回调回来
    fileprivate lazy var otherFeeTitleArray = {
        
        return [String]()
    }()
    // 其他费用金额数组
    fileprivate lazy var otherFeeArray = {
        
        return [Double]()
    }()
    lazy var feeArray: [[String: Double]] = { // 已选费用
        return [[String: Double]]()
    }()
    lazy var waterValueArray: [String] = { // 检测值
        return [String]()
    }()
    var payWay: String = "" // 已选支付方式
    
    // 退机单提示
    var isShowTipView = false
    var window: UIWindow?
    
    var currentSkipCell: RNSkipCell?
    var isGotAllFee = true // 是否拿到了其他费用
    var allFee: AllFee? = nil {
        didSet {
            var money: Double = 0.00
            allFee?.deatilFees.forEach({ (fee) in
                
                if fee.isPaid == PayState.paied.rawValue{
                    // 已支付
                }
                else if fee.isSelected == false {
                    // 未选择
                }
                else {
                   money += fee.money
                }
            })
            
            totalMoney = money + partMoney // 给订单总金额赋值
        }
    }
    var totalMoney: Double = 0.00 {
        didSet {
            if let cell = currentSkipCell {
                cell.money = totalMoney
            }
            bottomView?.money = totalMoney
        }
    }
    var partMoney: Double = 0.00
    
    var boxState: String? = nil {
        didSet {
            
        }
    }
    
 //  let group = DispatchGroup()
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BASEBACKGROUNDCOLOR
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "订单详情", target: self, action: #selector(popBack))]
        
        if let tuple = ServiceItemDictionary[type]{ // 安装或换机单需要选择送装信息 + 退机单需要弹框
            self.currentType = tuple.code
        }
        guard typeArray.contains(currentType)  else {
            RNNoticeAlert.showError("提示", body: "未在本地找到对应类型的订单,请等待后续更新")
            return
        }
        
        setUpDatas()
        setUI()
        
        globalAppDelegate.locationAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.caculateDistance() // 计算距离
        }
        
        getAllFee()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.showTip()
//        }
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - event response
extension RNSubmitViewController {
    
    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    func showTip(){
        if self.currentType == 1 {
            // 弹退机提示
            window = UIWindow(frame: UIScreen.main.bounds)
            let tjVC = RNTjViewController()
            window?.windowLevel = UIWindowLevelNormal
            window?.rootViewController = tjVC
            
            tjVC.appWindow = UIApplication.shared.keyWindow
            
            tjVC.callBack = {  [weak self] (dic) in
                self?.window = nil
                self?.isShowTipView = true
                for d in dic {
                    self?.parameters[d.key] = d.value
                }
            }
            
            window?.makeKeyAndVisible()
        }
    }
}

// MARK: - custom mehtods
extension RNSubmitViewController {
    
    // 根据订单类型准备数据源
    func setUpDatas() {
        
        var twos = [String]()
        switch currentType {
        case 1,2: // 退机 + 换机
            twos = ["剩余水值", "服务原因"]
            break
        case 3: // 移机
            twos = ["剩余水值", "水压", "源水TDS", "活水TDS", "服务原因"]
            break
        case 4: // 充水
            twos = ["故障&解决", "问题备注"]
            break
        case 5, 8: // 整改 + 换芯
            twos = ["剩余水值", "服务原因", "问题备注"]
            break
        case 6: // 安装
            twos = ["安装确认单编号", "水压", "开箱状态", "源水TDS", "活水TDS", "备注描述"]
            break
        case 7, 14: // 维护维修
            twos = ["剩余水值", "源水TDS", "活水TDS", "问题备注", "故障&解决"]
            break
        case 9, 11, 12: // 送货 + 现场勘测 + 清洁消毒
            // 无第二组
            isTwoSection = true
            break
        case 10: // 水质检测
            twos = ["源水TDS", "活水TDS"] //["源水TDS", "活水TDS","监测值"] => 取消水值监测值
            break
        default:
            break
        }
        
        if !isTwoSection{
            dataSource.append(twos)
        }
        
        let threes = ["","费用明细"]  //["", "配件使用", "费用统计","支付方式"] // 第一行显示图片
        dataSource.append(threes)
    }
    
    func setUI() {
        
        view.addSubview(tableView)
        
        bottomView = Bundle.main.loadNibNamed("RNFinishingView", owner: self, options: nil)?.last as? RNFinishingView
        bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
        bottomView?.completeCallback = { [weak self] in
            // 提交
            self?.bottomView?.completedBtn.isEnabled = false
            self?.bottomView?.completedBtn.backgroundColor = UIColor.lightGray
            self?.submitToServer()
        }
        view.addSubview(bottomView!)
    }
    
    func getAllFee() {
        guard let crmId = model.crmId else {
            isGotAllFee = false
            RNNoticeAlert.showError("提示", body: "crmId不存在, 请检查网络稍后重试")
            return
        }
        RNHud().showHud(nil)
        
//        if !isGotAllFee {
//            group.enter()
//        }
        OrderServicer.getOrderMoney(["CRMID": crmId], successClourue: { (allFee) in
            
//            if !self.isGotAllFee {
//                self.group.leave()
//            }
            self.allFee = allFee
            self.isGotAllFee = true
            RNHud().hiddenHub()
        }) { (msg, code) in
//            if !self.isGotAllFee {
//                self.group.leave()
//            }
            self.isGotAllFee = false
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    //第一组
    func configFirstSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitCustomCell", for: indexPath)
        
        let title = dataSource[indexPath.section][indexPath.row]
        var ph: String? = nil
        switch indexPath.row {
        case 0:
            ph = "输入/扫码"
            //        case 1,2:
            //            ph = "输入(只有2G机器有!)"
            //        case 3:
        //            ph = "输入(仅WiFi机器有!)"
        case 1:
            ph = "输入/扫码"
        default:
            break
        }
        
        if let cell = cell as? RNSubmitCustomCell {
            
            switch indexPath.row {
            case 0:
                // 键盘类型: 只能输入数字 + 字母 ,且至少六个字符
                cell.configCell(title: title, placeHolder: ph, indexPath: indexPath, viewController: self, keyboardType: .asciiCapable)
            case 1:
                //
                cell.configCell(title: title, placeHolder: ph, indexPath: indexPath, viewController: self, isEnabled:  true, keyboardType: .asciiCapable)
            default:
                cell.configCell(title: title, placeHolder: ph, indexPath: indexPath, viewController: self)
            }
            cell.delegate = self
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    // 第三组 或者 当 isTwoSection = true 时的第二组
    func configThirdSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNImageCell", for: indexPath)
            if let cell = cell as? RNImageCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
            }
            return cell
//        case 1:
//            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
//            if let cell = cell as? RNSkipCell {
//
//                var t: String = "请选择配件"
//                if partArray.count > 0 {
//                    t = "配件查看"
//                }
//                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
//                cell.selectionStyle = .gray
//            }
//            return cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
            if let cell = cell as? RNSkipCell {
                
                self.currentSkipCell = cell
                
                cell.money = self.totalMoney
                cell.contentLabel.isHidden = true
                let t: String = ""
//                if feeArray.count > 0 {
//                    t = "费用查看"
//                }
                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
                cell.selectionStyle = .gray
            }
            return cell
//        case 3:
//            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
//            if let cell = cell as? RNSkipCell {
//                var t: String = "支付选择"
//                if feeArray.count > 0 {
//                    t = "支付查看"
//                }
//                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
//                cell.selectionStyle = .gray
//            }
//            return cell
        default:
            cell = UITableViewCell()
            return cell
        }
    }
    
    // MARK: - 第二组
    //1235 - 退货/换货/移机/整改
    func configSecond12358Cell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNLeftWaterCell", for: indexPath)
            if let cell = cell as? RNLeftWaterCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
            }
            
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitWithoutQRCell", for: indexPath)
            if let cell = cell as? RNSubmitWithoutQRCell {
                if currentType == 3 && indexPath.row == 1{
                    cell.configCell(title: title, indexPath: indexPath, viewController: self, ph: "单位:mpa")
                    cell.contentTextField.keyboardType = .decimalPad
                }
                else {
                    cell.configCell(title: title, indexPath: indexPath, viewController: self)
                }
                
                cell.delegate = self
                cell.selectionStyle = .none
                
                if currentType == 3 && (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3){
                    cell.mustLabel.isHidden = false
                    cell.contentTextField.keyboardType = .numberPad
                }
                else {
                    cell.mustLabel.isHidden = true
                }
            }
        }
        
        
        return cell
    }
    
    //4 - 充水
    func configSecond4Cell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
            if let cell = cell as? RNSkipCell {
                var t: String = "请选择故障&解决"
                if troubleArray.count > 0 {
                    t = "请查看"
                }
                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
                cell.selectionStyle = .gray
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitWithoutQRCell", for: indexPath)
            if let cell = cell as? RNSubmitWithoutQRCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
            }
        }
        
        return cell
    }
    
    // 6 - 安装
    func configSecond6Cell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        
        if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNBoxStateCell", for: indexPath)
            if let cell = cell as? RNBoxStateCell {
                cell.configCell(title: "开箱状态", indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
            }
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitWithoutQRCell", for: indexPath)
            if let cell = cell as? RNSubmitWithoutQRCell {
                
                if indexPath.row == 0 {
                    cell.configCell(title: title, indexPath: indexPath, viewController: self)
                    cell.contentTextField.keyboardType = .asciiCapable
                }
                else if indexPath.row == 1 {
                    cell.configCell(title: title, indexPath: indexPath, viewController: self, ph: "单位:mpa")
                    cell.contentTextField.keyboardType = .decimalPad
                }
                else if indexPath.row == 3 || indexPath.row == 4 {
                    cell.configCell(title: title, indexPath: indexPath, viewController: self)
                    cell.contentTextField.keyboardType = .numberPad
                }
                else {
                    cell.configCell(title: title, indexPath: indexPath, viewController: self)
                }
                
                cell.delegate = self
                if indexPath.row != 5 {
                    cell.mustLabel.isHidden = false
                }
                else {
                    cell.mustLabel.isHidden = true
                }
                
            }
            cell.selectionStyle = .none
        }
        return cell
    }
    //7 - 维护维修
    func configSecond7Cell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNLeftWaterCell", for: indexPath)
            if let cell = cell as? RNLeftWaterCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
            }
        }else if indexPath.row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
            if let cell = cell as? RNSkipCell {
                var t: String = "请选择故障&解决"
                if troubleArray.count > 0 {
                    t = "请查看"
                }
                cell.mustLabel.isHidden = false
                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
                cell.selectionStyle = .gray
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitWithoutQRCell", for: indexPath)
            if let cell = cell as? RNSubmitWithoutQRCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
                
                if indexPath.row == 1 || indexPath.row == 2 {
                    cell.mustLabel.isHidden = false
                    cell.contentTextField.keyboardType = .numberPad
                }
                else {
                    cell.mustLabel.isHidden = true
                }
            }
        }
        
        return cell
    }
    //10 - 水质检测
    func configSecond10Cell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let title = dataSource[indexPath.section][indexPath.row]
        if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSkipCell", for: indexPath)
            if let cell = cell as? RNSkipCell {
                var t: String = "" // TO DO: 修改 查看详情----功能取消
                if  waterValueArray.count > 0 {
                    t = ""
                }
                cell.configCell(title: title, tip: t, indexPath: indexPath, viewController: self)
                cell.selectionStyle = .gray
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSubmitWithoutQRCell", for: indexPath)
            if let cell = cell as? RNSubmitWithoutQRCell {
                cell.configCell(title: title, indexPath: indexPath, viewController: self)
                cell.delegate = self
                cell.selectionStyle = .none
                
                if indexPath.row == 0 || indexPath.row == 1 {
                    cell.mustLabel.isHidden = false
                }
                else {
                    cell.mustLabel.isHidden = true
                }
            }
        }
        
        return cell
    }
    
    
    func skipToTrouble(_ cell: UITableViewCell?) {
        if let cell = cell as? RNSkipCell {
            
            // 跳转问题&解决
            let troubleVC = RNTroubleViewController(dataSource: troubleArray, callBack: { [weak self](results) in
                self?.troubleArray = results
                cell.contentLabel.text = "请查看"
            })
            self.navigationController?.pushViewController(troubleVC, animated: true)
        }
    }
    
    func skipToWaterCheck(_ cell: UITableViewCell?) {
//        if let cell = cell as? RNSkipCell {
//
//            // 检测值 TO DO:
//        }
    }
    
    func skipToPart(_ cell: UITableViewCell?) {
        if let cell = cell as? RNSkipCell {
            
            //  配件
            let partVC = RNPartViewController(selectedProducts: partArray, callBack: { [weak self](results) in
                self?.partArray = results
                cell.contentLabel.text = "配件查看"
            })
            self.navigationController?.pushViewController(partVC, animated: true)
        }
    }
    
    func skipToFee(_ cell: UITableViewCell?) {
        if let cell = cell as? RNSkipCell {
            
            if !isGotAllFee {
                guard let crmId = model.crmId else {
                    isGotAllFee = false
                    RNNoticeAlert.showError("提示", body: "crmId不存在, 请检查网络稍后重试")
                    return
                }
                RNHud().showHud(nil)
                OrderServicer.getOrderMoney(["CRMID": crmId], successClourue: { (allFee) in
                    self.allFee = allFee
                    self.isGotAllFee = true
                    RNHud().hiddenHub()
                    self.skipToNewFeeCaculateVC(cell)
                }) { (msg, code) in
                    self.isGotAllFee = false
                    RNHud().hiddenHub()
                    RNNoticeAlert.showError("提示", body: msg)
                }
                
            }else{
                self.skipToNewFeeCaculateVC(cell)
            }
        }
    }
    
    func skipToNewFeeCaculateVC(_ cell: RNSkipCell) {
//        // 费用选择
//        let selectOtherFeeTypeVC = RNSelectOtherFeeTypeViewController(selectedTitle: otherFeeTitleArray, selectedFees: otherFeeArray) { [weak self](result) in
//            self?.otherFeeTitleArray.removeAll()
//            self?.otherFeeArray.removeAll()
//            self?.feeArray.removeAll()
//            for item in result{
//                self?.otherFeeTitleArray.append(item.0)
//                self?.otherFeeArray.append(item.1)
//                var dic = [String: Double]()
//                dic[item.0] = item.1
//                self?.feeArray.append(dic)
//            }
//
//            cell.contentLabel.text = "费用查看"
//        }
//        navigationController?.pushViewController(selectOtherFeeTypeVC, animated: true)
        
        guard let allfee = allFee else {
            return
        }
        
        let newFeeVC = RNNewFeeServiceViewController.init(totalMoney, model: model, allFee: allfee, partArray: partArray) { [weak self](money, allfee, partArray) in
           // self?.totalMoney = money
            var tmp: Double = 0.0
            for item in partArray {
                tmp += (Double(item.productPrice ?? "0.00") ?? 0.00) * Double(item.productAmount)
            }
            self?.partMoney = tmp  // 配件总价格
            
            self?.allFee = allfee
            self?.partArray = partArray
        }
        navigationController?.pushViewController(newFeeVC, animated: true)
    }
    func skipToPayWay(_ cell: UITableViewCell?) {
        if let cell = cell as? RNSkipCell {
            
            // 支付方式
            let payWayVC = RNPayWayViewController(payWay: payWay, callback: { [weak self](result) in
                self?.payWay = result
                cell.contentLabel.text = "支付查看"
            })
            navigationController?.pushViewController(payWayVC, animated: true)
        }
    }
    
}

//MARK: - 关于提交
extension RNSubmitViewController {
    
    func caculateDistance(){ // 计算距离
        
        let locationModel = realmQueryResults(Model: LocationModel.self).last
        if let lat01 = locationModel?.latitude, let long01 = locationModel?.longitude{
            
            let destinationAddress =  (model.province != nil ? model.province! : "") + (model.city != nil ? model.city! : "") + (model.country != nil ? model.country! : "") + (model.address != nil ? model.address! : "")
            globalAppDelegate.locationManager?.getCoordinate(address: destinationAddress) { [ weak self](coordinate) in
                // 目的地坐标
                let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance =  distanceBetweenLocationBy(latitude01: lat01, longitude01: long01, latitude02: location.latitude, longitude02: location.longitude)
                
                self?.distanceString = distance
            }
            
        }
    }
    
    // 字典转 jsonString
    func dicToJsonString(_ dic: [String: Any]) -> String?{
        let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        guard let haveData = data else{
            return nil
        }
        var strJson = String(data: haveData, encoding: String.Encoding.utf8)
        
        strJson = strJson?.replacingOccurrences(of: "\n", with: "")
        //strJson = strJson?.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        return strJson
    }
    
    // 问题&解决 list 处理
    func doSolutionInfo() -> [[String: String]] {
        
        var arr = [[String: String]]()
        for item in troubleArray{
            let index = item.components(separatedBy: ":")
            let value01 = index.first
            let value02 = index.last
            
            if let v1 = value01, let v2 = value02 {
                let dic: [String: String] = ["Reason" : v1, "Solution" :v2]
                arr.append(dic)
            }
            
        }
        return arr
    }
    
    // 配件 list
    func doProducts() -> [[String: Any?]]{
        var arr = [[String: Any?]]()
        for item in partArray {
            var dic = [String: Any?]()
            dic["ProductID"] = item.productId
            dic["ProductNum"] = item.productAmount
            dic["Price"] = item.productPrice
            dic["CompanyName"] = item.productName
            arr.append(dic)
        }
        
        return arr
    }
    
    // 费用 list
    func doMoneylist() -> [[String: Any?]] {
        var arr = [[String: Any?]]()
        if let detailFees = allFee?.deatilFees {
            for item in detailFees {
                var dic = [String: Any?]()
                if item.isSelected {
                    dic["money"] = item.money.cent
                    dic["title"] = item.title
                    dic["payKind"] = item.payKind
                    arr.append(dic)
                }
            }
        }
        
        if self.partArray.count > 0 {
            var dic = [String: Any?]()
            dic["money"] = self.partMoney.cent
            dic["title"] = "配件服务费"
            dic["payKind"] = PayKind.partFee.rawValue
            arr.append(dic)
        }
       
        return arr
    }
    
    // 合并参数
    func mergeParam() -> Bool{
        
        guard let orderid =  model.orderId else{
            RNNoticeAlert.showError("提示", body: "未获取到订单id")
            return false
        }
        parameters["OrderId"] = orderid
        
        if let dis = distanceString {
            //            RNNoticeAlert.showError("提示", body: "距离信息计算失败, 请确认地址正确后稍后再试")
            //
            //            globalAppDelegate.locationAction()
            //            self.caculateDistance()
            //            return false
            parameters["Distance"] = String(describing: dis)
        }
        
        
      //  let machindeId = parameters["MachineType"]
        
        //        if [1,2,3,6,7].contains(currentType) { // 退机换机移机安装维修
        //            guard let _ = machindeId else {
        //                RNNoticeAlert.showError("提示", body: "设备管理号是必填信息!", duration: 3.0)
        //                return false
        //            }
        //        }
        //
        //        if [1,2,3,6,7].contains(currentType) { // 退机换机移机安装维修
        //            let serviceCode = parameters["ServiceCode"]
        //            guard let _ = serviceCode else {
        //                RNNoticeAlert.showError("提示", body: "直通车编号是必填信息!", duration: 3.0)
        //                return false
        //            }
        //        }
        //        if [1,2,3,6,7].contains(currentType), let productModel = model.productInfo?.productModel, productModel == "JZY-A2B-X(T1)" { // 退机换机移机安装维修
        //            let iMEI = parameters["MachineCode"]
        //            guard let _ = iMEI else {
        //                RNNoticeAlert.showError("提示", body: "机器IMEI是在JZY-A2B-X(T1)的订单中是必填信息!", duration: 3.0)
        //                return false
        //            }
        //        }
        
        
        if currentType == 6 {
            let confirmCode = parameters["InstallConfirmNum"]
            guard let _ = confirmCode else {
                RNNoticeAlert.showError("提示", body: "请填写安装单确认编号")
                return false
            }
        }
        
        guard let type = parameters["MachineType"] as? String, type.isLettersOrNumbers() else {
            RNNoticeAlert.showError("提示", body: "设备管理号必须为5位以上的数字或字母")
            return false
        }
        guard let _ = parameters["ServiceCode"] else {
            RNNoticeAlert.showError("提示", body: "直通车编码不能为空")
            return false
        }
        if [3, 6, 7, 10, 14].contains(currentType) {
            guard let y = parameters["Y_TDS"] as? String else {
                RNNoticeAlert.showError("提示", body: "请填写源水 TDS 值")
                return false
            }
            guard y.isUnInterger() else {
                RNNoticeAlert.showError("提示", body: "源水 TDS 值必须为非负整数")
                return false
            }
            guard let z = parameters["Z_TDS"] as? String else {
                RNNoticeAlert.showError("提示", body: "请填写活水 TDS 值")
                return false
            }
            guard z.isUnInterger() else {
                RNNoticeAlert.showError("提示", body: "活水 TDS 值必须为非负整数")
                return false
            }
            
        }
        if [1, 2, 3, 5, 7, 8, 14].contains(currentType) {
            guard let y =  parameters["ResidualSZ"] as? String else {
                RNNoticeAlert.showError("提示", body: "请填写剩余水值")
                return false
            }
            guard y.isUnInterger() else {
                RNNoticeAlert.showError("提示", body: "剩余值必须为非负整数")
                return false
            }
        }
        
        if (currentType == 7 || currentType == 14 ) && (troubleArray.count <= 0) {
            RNNoticeAlert.showError("提示", body: "请选择故障和解决办法")
            return false
        }
        if currentType == 6 {
            guard let installConfirmNum =  parameters["InstallConfirmNum"] as? String, installConfirmNum.isLettersOrNumbers() else {
                RNNoticeAlert.showError("提示", body: "安装确认单号必须为数字或字母")
                return false
            }
            
        }
        
        if [3, 6].contains(currentType) {
            guard let shuiya =   parameters["shuiya"] as? String, shuiya.isDecimal(), let _ = Double(shuiya) else {
                RNNoticeAlert.showError("提示", body: "请填写水压值,必须为数字")
                return false
            }
        }
        
//        if payWay == "" {
//            RNNoticeAlert.showError("提示", body: "请选择支付方式")
//            return false
//        }
//
//        parameters["PayWay"] = payWay
        parameters["SolutionInfo"] = doSolutionInfo()
        parameters["products"] = doProducts()
        parameters["moneylist"] = doMoneylist()
        
        self.orderFinishInfo = dicToJsonString(parameters)
        
        return true
    }
    
    func activeCompletedButton() {
        self.bottomView?.completedBtn.isEnabled = true
        self.bottomView?.completedBtn.backgroundColor = MAIN_THEME_COLOR
    }
    
    func submitToServer(){
        if !mergeParam() {
            activeCompletedButton()
            return
        }
        
        guard let orderInf = orderFinishInfo else {
            RNNoticeAlert.showError("提示", body: "订单参数为空")
            activeCompletedButton()
            return
        }
        
        guard  imageParams.count >= 2 else{
            RNNoticeAlert.showError("提示", body: "至少需要上传一张机器安装图和一张机器安装确认单的照片", duration: 3)
            activeCompletedButton()
            return
        }
        
        guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
            RNNoticeAlert.showError("提示", body: "未获取到 userToken")
            activeCompletedButton()
            return
        }
        
        if let dis = distanceString, dis > 3.0 {
            RNNoticeAlert.showWarning("提示", body: "结单距离超过3KM!")
        }
        
//        // 退机订单判定
//        if self.currentType == 1, !isShowTipView{
//            showTip()
//            return
//        }
        
        RNHud().showHud(nil)
        OrderServicer.waterFinishedOrder(["orderFinishInfo": orderInf, "usertoken": token], imageDatas: imageParams, successClourue: { [weak self](state) in
            RNHud().hiddenHub()
            self?.activeCompletedButton()
            if state == 2 { // 状态为2时跳转支付界面
//
//                if let id = self?.model.orderId {
//                    let payVC = RNPayViewController(id)
//                    self?.navigationController?.pushViewController(payVC, animated: true)
//                }else{
//                    RNNoticeAlert.showError("提示", body: "由于未拿到订单 id,无法进行支付")
//                }
                
                if let s = self, let id = s.model.crmId{
                    s.skipToPay(with: id)
                }
                else {
                     RNNoticeAlert.showError("提示", body: "由于未拿到订单id,无法进入收款界面")
                }
                
            }else{
                
                RNNoticeAlert.showSuccessWithForever("提示", body: "结单成功", buttonTapHandler: { [weak self](_) in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 发送通知
                    RNNoticeAlert.hideMessage()
                    self?.dismiss(animated: true, completion: {})
                })
            }
            
        }) { [weak self](msg, code) in
            RNHud().hiddenHub()
            self?.activeCompletedButton()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    private func skipToPay(with crmId: String) {
        let payInfoVC = RNPayInfoViewController.init(crmId, oznerId: model.documentNo ?? "", whereCome: ComePayWay.submitOrder)
        payInfoVC.totalMoney = totalMoney
        
        var fee = allFee
        if partArray.count > 0 {
            var detailFee = DetailFee()
            detailFee.money = self.partMoney
            detailFee.title = "配件服务费"
            detailFee.validity = String(format: "%d件", partArray.count)
            detailFee.isPaid = PayState.noPay.rawValue
            fee?.deatilFees.append(detailFee)
        }
        payInfoVC.allFee = fee ?? AllFee()
        
        navigationController?.pushViewController(payInfoVC, animated: true)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSubmitViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTwoSection{
            
            if (indexPath.section == 1) && (indexPath.row == 0) {
                return UITableViewAutomaticDimension
            }else{
                return 44
            }
            
        }else{
            
            if (indexPath.section == 2) && (indexPath.row == 0) {
                return UITableViewAutomaticDimension
            }else{
                return 44
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTwoSection{
            
            if (indexPath.section == 1) && (indexPath.row == 0) {
                return (SCREEN_WIDTH-8*2-5*3)/4 + 20
            }else{
                return 44
            }
            
        }else{
            
            if (indexPath.section == 2) && (indexPath.row == 0) {
                return (SCREEN_WIDTH-8*2-5*3)/4 + 20
            }else{
                return 44
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }else if section == 1{
            if isTwoSection {
                return 0.01
            }
            return 10
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = configFirstSection(tableView, cellForRowAt: indexPath)
        }else if isTwoSection{
            if indexPath.section == 1 {
                cell = configThirdSection(tableView, cellForRowAt: indexPath)
            }
        }else{
            
            if indexPath.section == 1 {
                // 复杂的第二组
                
                if [1,2,3,5,8].contains(currentType) {
                    
                    cell = configSecond12358Cell(tableView, cellForRowAt: indexPath)
                }else if currentType == 4{ // 充水
                    cell = configSecond4Cell(tableView, cellForRowAt: indexPath)
                }else if currentType == 6 { // 维护维修
                    cell = configSecond6Cell(tableView, cellForRowAt: indexPath)
                }else if currentType == 7 || currentType == 14 { // 维护维修
                    cell = configSecond7Cell(tableView, cellForRowAt: indexPath)
                }else if currentType == 10 { // 水质检测
                    cell = configSecond10Cell(tableView, cellForRowAt: indexPath)
                }else{
                    cell = UITableViewCell()
                }
                
            }else if indexPath.section == 2{
                cell = configThirdSection(tableView, cellForRowAt: indexPath)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if isTwoSection && (indexPath.section == 1){
            
            switch indexPath.row {
//            case 1:
//                skipToPart(cell)
            case 1:
                skipToFee(cell)
//            case 3:
//                skipToPayWay(cell)
            default:
                break
            }
        }else{
            
            if indexPath.section == 1{
                
                if currentType == 4 && (indexPath.row == 0){
                    skipToTrouble(cell)
                }else if (currentType == 7 || currentType == 14) && (indexPath.row == 4) {
                    skipToTrouble(cell)
                }else if currentType == 10 && (indexPath.row == 2){
                    skipToWaterCheck(cell)
                }
            }else if indexPath.section == 2{
                switch indexPath.row {
//                case 1:
//                    skipToPart(cell)
                case 1:
                    skipToFee(cell)
//                case 3:
//                    skipToPayWay(cell)
                default:
                    break
                }
            }
        }
        
    }
    
}


//MARK: - RNSubmitCustomCellProtocol
extension RNSubmitViewController: RNSubmitCustomCellProtocol {
    
    func getInputString(_ text: String, indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                parameters["MachineType"] = nil
                if text.count < 6 {
                   RNNoticeAlert.showError("提示", body: "至少输入6个字符")
                }
                else if !text.isLettersOrNumbers() {
                     RNNoticeAlert.showError("提示", body: "只允许输入数字和字母")
                }
                else {
                    parameters["MachineType"] = text
                }
//            case 1:
//                parameters["MachineCode"] = text
//            case 2:
//                parameters["ICCID"] = text
//            case 3:
//                parameters["MacAddress"] = text
            case 1:
                parameters["ServiceCode"] = text
            default:
                break
            }
        }
    }
}

//MARK: - RNSubmitWithoutQRCellProtocol
extension RNSubmitViewController: RNSubmitWithoutQRCellProtocol{
    
    func getInputStringWithoutQR(_ text: String, indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            switch indexPath.row {
            case 0:
                if currentType == 6{ // 安装确认单编号
                    parameters["InstallConfirmNum"] = text
                }
                if currentType == 10{ // 源水 YDS
                    parameters["Y_TDS"] = text
                }
            case 1:
                if [1,2,5,8].contains(currentType) { // 服务原因
                    parameters["ServiceReasons"] = text
                }
                if [3,6].contains(currentType)  { // 水压
                    parameters["shuiya"] = text
                }
                if currentType == 7 || currentType == 14 { // 源水
                    parameters["Y_TDS"] = text
                }
                if currentType == 10 { // 活水
                    parameters["Z_TDS"] = text
                }
                
                break
            case 2:
                if [5,8].contains(currentType) { // 问题备注
                    parameters["ProblemComponent"] = text
                }
                if currentType == 3 { // 源水
                    parameters["Y_TDS"] = text
                }
                if currentType == 6 { // 开箱
                    parameters["IsOpenBox"] = text
                }
                if currentType == 7 || currentType == 14 { // 活水
                    parameters["Z_TDS"] = text
                }
                
                break
            case 3:
                if currentType == 3 { // 活水
                    parameters["Z_TDS"] = text
                }
                if currentType == 6 { // 源水
                    parameters["Y_TDS"] = text
                }
                if currentType == 7 || currentType == 14 { // 问题
                    parameters["ProblemComponent"] = text
                }
                break
            case 4:
                if currentType == 3 { // 服务原因
                    parameters["ServiceReasons"] = text
                }
                if currentType == 6 { // 活水
                    parameters["Z_TDS"] = text
                }
                break
            case 5:
                if currentType == 6 { // 备注
                    parameters["Remark"] = text //TO DO: -
                }
            default:
                break
            }
        }
    }
}
//MARK: - RNLeftWaterCellProtocol
extension RNSubmitViewController: RNLeftWaterCellProtocol{
    
    func getinfo(_ text: String, unit: String, indexPath: IndexPath) {
        parameters["ResidualSZ"] = text
        parameters["SZunit"] = unit
    }
}

//MARK: - RNBoxStateCellProtocol
extension RNSubmitViewController: RNBoxStateCellProtocol{
    func getinfo(_ tag: Int, indexPath: IndexPath) {
        
        let index = IndexPath(row: 5, section: indexPath.section)
        let cell = tableView.cellForRow(at: index) as? RNSubmitWithoutQRCell
        
        if tag == 100 {
            parameters["IsOpenBox"] = "良"
            boxState = "良"
            cell?.mustLabel.isHidden = true
        }
        else {
            parameters["IsOpenBox"] = "不良"
            boxState = "不良"
            cell?.mustLabel.isHidden = false
        }
    }
}


//MARK: - RNImageCellProtocol
extension RNSubmitViewController: RNImageCellProtocol{
    
    func getImages(images arr: [UIImage]) {
        
        self.imageParams = arr
    }
}
