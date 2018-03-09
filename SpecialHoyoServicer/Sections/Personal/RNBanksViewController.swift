//
//  RNBanksViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import ESPullToRefresh

class RNBanksViewController: RNBaseTableViewController {
    
    fileprivate var tableView: UITableView!
    
    lazy var banks: [BankCardModel] = {
        
        let array = realmQueryResults(Model: BankCardModel.self)
        
        var arr = [BankCardModel]()
        for item in array {
            
            arr.append(item)
        }
        
        return arr.map({ (model) -> BankCardModel in
            return model.copy() as! BankCardModel
        })
        
    }()
    
    var callBack: (() -> ())?
    
    var banksChanged: Bool = false {
        didSet{
            callBack?()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "银行卡", target: self, action: #selector(dismissFromVC))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItem("nav_add", target: self, action: #selector(addBanks))
        
        setupTableView()
        
        if self.banks.count == 0 {
            self.getBanks()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK: event response
extension RNBanksViewController {
    
    @objc func addBanks() {
        
        let bindsBankVC = RNNewAddBankViewController(nibName: "RNNewAddBankViewController", bundle: nil)
        bindsBankVC.callBack = { [weak self] in
            self?.banksChanged = true
            self?.getBanks()
        }
        navigationController?.pushViewController(bindsBankVC, animated: true)
        
        
    }
    
    @objc func dismissFromVC(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension RNBanksViewController {
    
    func setupTableView() {
        
        if #available(iOS 11, *) {
            tableView = UITableView(frame: CGRect(x: 20, y: 64, width: SCREEN_WIDTH-40, height: SCREEN_HEIGHT-64), style: UITableViewStyle.grouped)
        }
        else{
             tableView = UITableView(frame: CGRect(x: 20, y: 0, width: SCREEN_WIDTH-40, height: SCREEN_HEIGHT), style: UITableViewStyle.grouped)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear
        
        tableView.register(UINib(nibName: "RNBankCell", bundle: Bundle.main), forCellReuseIdentifier: "RNBankCell")
        
        let header: ESRefreshHeaderAnimator = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
        
        header.pullToRefreshDescription = "下拉可以刷新"
        header.releaseToRefreshDescription = "松手刷新"
        header.loadingDescription = "刷新中..."
        
       
        
        tableView.es.addPullToRefresh(animator: header){ [weak self] in
            self?.getBanks()
        }
        
        tableView.refreshIdentifier = "defaulttype"
        tableView.expiredTimeInterval = 0.1 // 刷新过期时间

        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        
        view.addSubview(tableView)
    }

    
    
    func getBanks() {
        
        RNHud().showHud(nil)
        FinancialServicer.getOwnBankCards(successClourue: { (results) in
            
            RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            self.banks =  results.map({ (model) -> BankCardModel in
                return model.copy() as! BankCardModel
            })
            
            self.tableView.reloadData()
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            self.tableView.es.stopPullToRefresh()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func deleteBankCard(model: BankCardModel, indexPath: IndexPath) {
        
        guard let bankId = model.bankId else{
            return
        }
        
        FinancialServicer.deleteBankCard(["cid": bankId], successClourue: {
            
            // 删除数据库数据
            realmDeleteObject(Model: BankCardModel.self, condition: { (models) -> BankCardModel? in
                
                for item in models {
                    if (item.bankId != "") && (item.bankId == model.bankId) {
                        return item
                    }
                }
                
                return nil
            })
            self.banks.remove(at: indexPath.section)
            
            self.banksChanged = true
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.reloadEmptyDataSet()
//                let indexSet = NSIndexSet(index: indexPath.section)
//                self.tableView.beginUpdates()
//                self.tableView.deleteSections(indexSet as IndexSet, with: .fade)
//                
//                self.tableView.endUpdates()
            }
            
        }, failureClousure: { (msg, code) in
            RNNoticeAlert.showError("提示", body: msg)
        })

    }

}

// MARK: - UITableViewDelegate && UITabelViewDatasource

extension  RNBanksViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return banks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
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
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNBankCell", for: indexPath)
        
        let model = banks[indexPath.section]
        
        if let cell = cell as? RNBankCell {
            cell.configCell(model: model)
            
            cell.callBack = { [weak self] model in
                
                let alert = UIAlertController(title: "提示", message: "确认删除此卡?", preferredStyle: .alert)
                let deletaButton = UIAlertAction(title: "确定", style: .default) { [weak self](_) in
                    
                    self?.deleteBankCard(model: model, indexPath: indexPath)
                }
                let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alert.addAction(deletaButton)
                alert.addAction(cancelButton)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self?.present(alert, animated: true, completion: nil)
                }

            }
        }
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 8
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let model = banks[indexPath.section]
            
            deleteBankCard(model: model, indexPath: indexPath)
        }
    }

    
}
