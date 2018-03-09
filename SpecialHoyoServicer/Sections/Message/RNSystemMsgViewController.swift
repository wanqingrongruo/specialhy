//
//  RNSystemMsgViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift

class RNSystemMsgViewController: RNBaseTableViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource: [MessageModel] = {
        
        let array = realmQueryResults(Model: MessageModel.self)
        
        var arr = [MessageModel]()
        for item in array.reversed() {
            arr.append(item)
        }
        return arr
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "系统通知", target: self, action: #selector(dismissFromVC))]
        
        setupUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: - event response
extension RNSystemMsgViewController {
    
    @objc func dismissFromVC(){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - custom methods
extension RNSystemMsgViewController {
    
    func setupUI() {
        
        // 44 = tabHeight => 在 appDelegate 的 showMainViewController() 里设置
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .plain)
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = BASEBACKGROUNDCOLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNSystemMsgCell", bundle: nil), forCellReuseIdentifier: "RNSystemMsgCell")
        tableView.tableFooterView = UIView()
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSystemMsgViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNSystemMsgCell", for: indexPath)
        
        let model = dataSource[indexPath.row]
        
        if let cell = cell as? RNSystemMsgCell {
            // 显示
            cell.config(model, indexPath: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.row]
        
        guard let crmID = model.orderId else{
            RNNoticeAlert.showError("提示", body: "未获取到 crmid")
            return
        }
        
        //        var orderType = OrderType.getOrder
        //        if let typeGY = model.messageType {
        //
        //            switch  typeGY {
        //            case "ordernotify":
        //                orderType = OrderType.waitingDealing // 指派订单
        //            case "orderrob":
        //               orderType = OrderType.getOrder //可抢订单
        //
        //            default:
        //                break
        //            }
        //        }
        
        RNHud().showHud(nil)
        OrderServicer.getOrderState(["CRMID": crmID], successClourue: { (state) in
            RNHud().hiddenHub()
            self.skipWhere(state, model: model)
        }, failureClousure: { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        })
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let model = dataSource[indexPath.row]
            // 删除数据库数据
            realmDeleteObject(Model: MessageModel.self, condition: { (models) -> MessageModel? in
                
                for item in models {
                    if (item.orderId != "") && (item.orderId == model.orderId) {
                        return item
                    }
                }
                
                return nil
            })
            self.dataSource.remove(at: indexPath.row)
            
            
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadEmptyDataSet()
            self.tableView.endUpdates()
        }
    }
    
    
    func skipWhere(_ state: String, model: MessageModel){
        
        let orderModel = Order()
        orderModel.crmId = model.orderId
        orderModel.serviceItem = model.serviceItem
        
        switch state {
        case OrderState.outDate.rawValue:
            RNNoticeAlert.showInfo("提示", body: "订单已过期")
        case OrderState.waitingGet.rawValue:
            whichType(OrderType.getOrder, model: orderModel)
        case OrderState.waitingDeal.rawValue:
            whichType(OrderType.waitingDealing, model: orderModel)
        case OrderState.subscibed.rawValue:
            whichType(OrderType.subscibe, model: orderModel)
        case OrderState.completed.rawValue:
            // 已完成详情
            let completedDetailVC = RNCompletedOrderDetailViewController(model: orderModel, type: OrderType.completed)
            completedDetailVC.isMsg = true
            self.navigationController?.pushViewController(completedDetailVC, animated: true)
            break
        case OrderState.waitingPay.rawValue:
            // 待支付详情
            let completedDetailVC02 = RNCompletedOrderDetailViewController(model: orderModel, type: OrderType.waitPay)
            completedDetailVC02.isWatingPay = true
            completedDetailVC02.isMsg = true
            self.navigationController?.pushViewController(completedDetailVC02, animated: true)
           break
        default:
            RNNoticeAlert.showError("提示", body: "未知状态订单,无法跳转")
            break
        }
        
    }
    
    func whichType(_ type: OrderType, model: Order){
        
        let commonDetailVC = RNCustomOrderDetailViewController(model: model, type: type)
        commonDetailVC.isDownload = true
        commonDetailVC.isMsg = true
//        let nav = RNBaseNavigationController(rootViewController: commonDetailVC)
//        RNHud().showHud(nil)
        self.navigationController?.pushViewController(commonDetailVC, animated: true)
        
    }
    
}

