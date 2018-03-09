//
//  RNPayInfoViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/22.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

enum ComePayWay: String {
    case waitPay = "待支付"
    case submitOrder = "结单"
}

class RNPayInfoViewController: RNBaseTableViewController {
    
    private var crmId: String
    private var oznerId: String
    private var whereCome: ComePayWay
    internal var totalMoney: Double? = nil // 初始化后传...不传的情况下会自己计算
    init(_ crmId: String, oznerId: String, whereCome: ComePayWay) {
        self.crmId = crmId
        self.oznerId = oznerId
        self.whereCome = whereCome
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tableView: UITableView!
    private var headView: RNPaymentHeadView!
  //  private var footView: RNPaymentFootView!
    private var payView: RNPaymentView!
    var bottomView: RNSigleButtonView?
//    private var footerCell: RNFooterCell!  {
//        didSet {
//            footerCell.state = allFee.payState
//            footerCell.tipDes = tipDes
//        }
//    }
    
    internal var isWaitPay = false //  是否是从待支付界面进入
    internal var isWaitDetailVC = false // 是否从详情过来 -- 用于待支付订单详情回跳
    internal lazy var allFee: AllFee = { // 包括各种服务费用的 model
        return AllFee()
    }()
    private lazy var isGetInfo = { // 决定按钮是否可以点击
        return false
    }()
    private var currentMoney: Double? = nil {
        didSet {
            if let cm = currentMoney {
                headView.money = cm
            }
        }
    }
    private var currentTag: Int = 0 // 当前支付方式 - 默认扫码支付
    private var tipDes: String = "注: 扫码收款, 是用户展示付款码给售后扫码即可收款"
    
    let filterCode: Int = 4  // 过滤
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "收款", target: self, action: #selector(popBack))]
        
        setUI()
        
        if let t = totalMoney {
            currentMoney = t
        }
        
        getAllFee()
//        if whereCome == ComePayWay.waitPay { // 当从待支付进入时才请求,从结单界面进入自己带数据
//           getAllFee()
//        }
//        else {
//            isGetInfo = true
//        }
        
        headView.orderId = self.crmId
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// event response
extension RNPayInfoViewController {
    @objc func popBack(){
        if self.isWaitPay {
            self.navigationController?.popViewController(animated: true)
        }
//        else if self.isWaitPay {
//            if let vcs = self.navigationController?.viewControllers, let vc = vcs.first, vc.isKind(of: RNWaitPayViewController.self) == true {
//                self.navigationController?.popToViewController(vc, animated: true)
//            }
//        }
        else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: FinishedOrderSuccessNotification), object: nil) // 发送通知
            self.dismiss(animated: true, completion: nil) // 跳转控制器
        }
    }
}

// custom methods
extension RNPayInfoViewController {
    
    private func setUI() {
        let padding: CGFloat = 8
        tableView = UITableView(frame: CGRect(x: 8, y: 64 + 20, width: SCREEN_WIDTH - padding * 2, height: SCREEN_HEIGHT - 60 - 20), style: .plain)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        //        tableView.separatorColor = BASEBACKGROUNDCOLOR
//        tableView.layer.masksToBounds = true
//        tableView.layer.cornerRadius = 5.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNPaymentCell", bundle: nil), forCellReuseIdentifier: "RNPaymentCell")
        tableView.register(UINib.init(nibName: "RNFooterCell", bundle: nil), forCellReuseIdentifier: "RNFooterCell")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        headView = Bundle.main.loadNibNamed("RNPaymentHeadView", owner: nil, options: nil)?.last as? RNPaymentHeadView
        headView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 150)
        tableView.tableHeaderView = headView
        
//        footView = Bundle.main.loadNibNamed("RNPaymentFootView", owner: nil, options: nil)?.last as? RNPaymentFootView
//        footView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 64)
//        tableView.tableFooterView = footView
        
        view.addSubview(tableView)
        
        singleView()
    }
    
    func finishView() {
        payView = Bundle.main.loadNibNamed("RNPaymentView", owner: nil, options: nil)?.last as? RNPaymentView
        payView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - 60, width: SCREEN_WIDTH, height: 60)
        payView.completeCallback = { [weak self]tag in
            if let s = self {
                if !s.isGetInfo {
                    RNNoticeAlert.showError("提示", body: "订单信息获取失败,无法支付")
                }
                else {
                    s.skip(with: tag)
                }
            }
        }
        view.addSubview(payView)
    }
    func singleView() {
        bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
        bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60, width: SCREEN_WIDTH, height: 60)
        bottomView?.sigleButton.setTitle("扫码支付", for: .normal)
        bottomView?.callBack = { [weak self] tag in
            if let s = self {
                if !s.isGetInfo {
                    RNNoticeAlert.showError("提示", body: "订单信息获取失败,无法支付")
                }
                else {
                    s.skip(with: 0)
                }
            }
        }
        view.addSubview(bottomView!)
    }
    
    private func getAllFee() {
        RNHud().showHud(nil)
        OrderServicer.getOrderMoney(["CRMID": crmId], successClourue: { (allFee) in
            RNHud().hiddenHub()
            self.allFee = allFee
            self.isGetInfo = true
            self.updateUI()
            self.tableView.reloadData()
            self.configureInfo(with: allFee)
        }) { (msg, code) in
            self.isGetInfo = false
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    private func configureInfo(with allfee: AllFee) {
        headView.orderId = allfee.crmId
       // footView.state = allfee.payState
        
        if let _ = currentMoney {
        }
        else {// 如果总金额没有从上个界面带过来就自己计算
            var tmp: Double = 0.0
            for item in allfee.deatilFees {
                if item.isPaid == PayState.paied.rawValue {
                    //
                }
                else {
                   tmp += item.money
                }
            }
            currentMoney = tmp
        }
    }
    
    private func updateUI() {
        let intrinsicHeight = SCREEN_HEIGHT - 64 - 20 - 60
        
        let dic = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)] as [NSAttributedStringKey: Any]
        let h = tipDes.sizeWithAttributes(text: (tipDes as NSString), with:dic, and: CGSize(width: tableView.frame.size.width - 16, height: CGFloat(MAXFLOAT))).height + 20
        let otherHeight = 64 + 150 + h
        let currentHeight: CGFloat = CGFloat(allFee.deatilFees.count * 44) + otherHeight
        
        if currentHeight < intrinsicHeight {
            let padding: CGFloat = 8
            tableView.isScrollEnabled = false
            tableView.bounces = false
            tableView.frame = CGRect(x: 8, y: 64 + 20, width: SCREEN_WIDTH - padding * 2, height: currentHeight)
            headView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 150)
           // footView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 64)
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            headView.setNeedsLayout()
            headView.layoutIfNeeded()
//            footView.setNeedsLayout()
//            footView.layoutIfNeeded()
        }
    }
    
    // 根据支付方式跳转
   private func skip(with tag: Int) {
        switch tag {
        case 0:
            // 扫码
            self.currentTag = 0
            scanAction()
            break
        case 1:
            // 刷卡
            let receiptVC = RNReceiptViewController(self.crmId, oznerId: self.oznerId)
            receiptVC.isWaitPay = isWaitPay
            navigationController?.pushViewController(receiptVC, animated: true)
        case 2:
            // 代付
            self.currentTag = 2
            scanAction()
            break
        default:
            break
        }
    }
    
    private func scanAction() {
        
        RNPermission.authorizeCameraWith(comletion: { [weak self](granted) in
            if granted {
                if let s = self {
                    var scanManager = RNScanManager(animationImage: "qr_scan_light_green", viewController: s)
                    scanManager.delegate = s
                    scanManager.beginScan()
                }
            }
            else {
                RNPermission.jumpToSystemPrivacySetting()
            }
        })
    }
    
    private func payAction(with authCode: String) {
        guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
            RNNoticeAlert.showError("提示", body: "未获取到 userToken")
            return
        }
        guard let totalM = currentMoney else{
            RNNoticeAlert.showError("提示", body: "未获取到订单支付金额, 无法完成支付")
            return
        }
        RNHud().showHud(nil)
        var paymodel = PayWay.Partner.rawValue
        if currentTag == 0 { // 扫码支付
            paymodel = PayWay.Scan.rawValue
        }
        else { // 售后代付
           paymodel = PayWay.HelpPay.rawValue
        }
        let parameter = ["CRMID": crmId, "PayModel": paymodel, "usertoken": token, "authcode": authCode, "trxamt": totalM*100]
        OrderServicer.scanToPayOrderMoney(parameter, successClourue: {
            RNHud().hiddenHub()
            self.showTip()
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func showTip() {
        var msg = "扫码支付成功"
        if currentTag == 0 { // 扫码支付
            msg = "扫码支付成功"
        }
        else { // 售后代付
            msg = "售后代付成功"
        }
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "确定", style: .cancel) { [weak self](_) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaySuccessNotification), object: nil) // 发送通知
            if let s = self, s.isWaitPay {
                if let vcs = s.navigationController?.viewControllers, let vc = vcs.first, vc.isKind(of: RNWaitPayViewController.self) == true {
                    s.navigationController?.popToViewController(vc, animated: true)
                }
            }else{
                self?.dismiss(animated: true, completion: nil) // 跳转控制器
            }
        }
        alert.addAction(cancelButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// UITableViewDelegate && UITableViewDataSource
extension RNPayInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFee.deatilFees.count + 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.row == allFee.deatilFees.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNFooterCell", for: indexPath)
            if let cell = cell as? RNFooterCell {
                cell.state = allFee.payState
                cell.tipDes = tipDes
            }
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNPaymentCell", for: indexPath)
            if let cell = cell as? RNPaymentCell {
                if indexPath.row < allFee.deatilFees.count {
                    let model = allFee.deatilFees[indexPath.row]
                    cell.configure(model: model)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension RNPayInfoViewController: RNScanManagerProtocol {
    
    func scanFinished(scanResult: RNScanResult, error: String?) {
        guard error == nil else {
            RNNoticeAlert.showError("提示", body:  error!)
            return
        }
        
        guard let resultString = scanResult.strScanned else{
            RNNoticeAlert.showError("提示", body: "扫描结果有误")
            return
        }
       self.payAction(with: resultString)
    }
}


//MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate
extension RNPayInfoViewController{
    //描述为空的数据集
    override func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = CGFloat(NSLineBreakMode.byWordWrapping.rawValue)
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(15.0)), NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.paragraphStyle: paragraph]
        
        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
            return NSAttributedString(string: "呃！好像网没通哦~\n请检查手机网络后重试", attributes: attributes)
        }
        return NSAttributedString(string: "未获取到订单支付信息,无法完成支付", attributes: attributes)
    }
}
