//
//  RNNewFeeServiceViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/21.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNNewFeeServiceViewController: RNBaseTableViewController {
    
    typealias FeeCallback = (_ totalMoney: Double, _ allFee: AllFee, _ partArray: [PartModel]) -> ()
    
    private var currentMoney: Double // 当前服务费用
    private var model: OrderDetail
    private var allFee: AllFee // 包括各种服务费用的 model
    private var partArray: [PartModel] // 配件
    private var feeCallback: FeeCallback // 回调
    
    init(_ currentMoney: Double, model: OrderDetail, allFee: AllFee, partArray: [PartModel], feeCallback: @escaping FeeCallback) {
        self.currentMoney = currentMoney
        self.model = model
        self.allFee = allFee
        self.partArray = partArray
        self.feeCallback = feeCallback
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var detailFees: [DetailFee] = {
        return allFee.deatilFees
    }()
    private var totalMoney: Double = 0.0 {
        didSet {
            // 更新 UI
            headView.money = totalMoney
        }
    }
    private var partTotalPrice: Double = 0.0 {
        didSet {
             sectionView.money = partTotalPrice
        }
    }
    
    private var tableView: UITableView!
    private var headView: RNFeeHeadView!
    private var sectionView: RNPartHeadView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "费用统计", target: self, action: #selector(popBack))]
        
        setUI()
        
        totalMoney = currentMoney
        headView.orderId = model.crmId ?? ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// event response
extension RNNewFeeServiceViewController {
    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }
}

// custom methods
extension RNNewFeeServiceViewController {
    
    func setUI() {
        let showView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 100))
        showView.backgroundColor = BASEBACKGROUNDCOLOR
        
        headView = Bundle.main.loadNibNamed("RNFeeHeadView", owner: nil, options: nil)?.last as? RNFeeHeadView
        headView.frame = CGRect(x: 0, y: 0, width: showView.frame.size.width, height: 80)
        headView.completeCallback = { [weak self] in
            if let s = self {
                s.feeCallback(s.totalMoney, s.allFee, s.partArray)
                s.navigationController?.popViewController(animated: true)
            }
        }
        showView.addSubview(headView)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = BASEBACKGROUNDCOLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNFeeCell", bundle: nil), forCellReuseIdentifier: "RNFeeCell")
        tableView.register(UINib.init(nibName: "RNSelectedPartCell", bundle: nil), forCellReuseIdentifier: "RNSelectedPartCell")
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.tableHeaderView = showView
        view.addSubview(tableView)
    }
}

// UITableViewDelegate && UITableViewDataSource
extension RNNewFeeServiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return allFee.deatilFees.count
        }
        
        return partArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            sectionView = Bundle.main.loadNibNamed("RNPartHeadView", owner: nil, options: nil)?.last as? RNPartHeadView
            sectionView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
            sectionView.completeCallback = {
                
                var originalPrice = 0.0
                self.partArray.forEach({ (item) in
                    originalPrice += (Double(item.productPrice ?? "0.00") ?? 0.00) * Double(item.productAmount)
                })
                
                let partVC = RNPartViewController(selectedProducts: self.partArray, callBack: { [weak self](results) in
                    self?.partArray = results
                    
                    var tmpPartMoney = 0.0
                    if let currentMoney = self?.totalMoney {
                        var tmp = 0.0
                        for item in results {
                            tmp += (Double(item.productPrice ?? "0.00") ?? 0.00) * Double(item.productAmount)
                        }
                        tmpPartMoney = tmp
                        self?.totalMoney = currentMoney + tmp - originalPrice // 统计总服务费
                    }
                    let indexSet = IndexSet.init(integersIn: 1...1)
                    DispatchQueue.main.async {
                        self?.tableView.reloadSections(indexSet, with: .fade)
                        self?.partTotalPrice = tmpPartMoney
                    }
                    
                })
                self.navigationController?.pushViewController(partVC, animated: true)
            }
            var partPrice = 0.0
            partArray.forEach({ (item) in
                partPrice += (Double(item.productPrice ?? "0.00") ?? 0.00) * Double(item.productAmount)
            })
            self.partTotalPrice = partPrice
            
            return sectionView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNFeeCell", for: indexPath)
            if let cell = cell as? RNFeeCell {
                if indexPath.row < allFee.deatilFees.count {
                    var model = allFee.deatilFees[indexPath.row]
                    
                    if model.payKind == String(describing:PayKind.cleanFee.rawValue) {
                        cell.numLabel.isHidden = true
                        cell.isEnableBtn.isHidden = false
                        
                        if model.isSelected {
                            cell.isEnableBtn.setImage(UIImage(named: "log_agree"), for: .normal)
                        }
                        else {
                            cell.isEnableBtn.setImage(UIImage(named: "log_disagree"), for: .normal)
                        }
                        cell.isEnableBtn.isSelected = model.isSelected
                        
                        cell.callback = { [weak self](isEnable) in
                            guard let s = self else {
                                RNNoticeAlert.showError("提示", body: "操作失败,可能导致费用计算有误,请重试")
                                return
                            }
                            if isEnable {
                                s.totalMoney = s.totalMoney + model.money
                                var detailfees = s.allFee.deatilFees
                                model.isSelected = true
                                detailfees[indexPath.row] = model
                                s.allFee.deatilFees = detailfees
                            }
                            else {
                                s.totalMoney = s.totalMoney - model.money
                                var detailfees = s.allFee.deatilFees
                                model.isSelected = false
                                detailfees[indexPath.row] = model
                                s.allFee.deatilFees = detailfees
                            }
                        }
                    }
                    else {
                        cell.numLabel.isHidden = false
                        cell.isEnableBtn.isHidden = true
                    }
                    if model.isPaid == PayState.paied.rawValue {
                        cell.containerView.backgroundColor = UIColor.gray
                    }
                    else {
                        cell.containerView.backgroundColor = UIColor.white
                    }
                    cell.configure(model: model)
                }
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "RNSelectedPartCell", for: indexPath)
            if let cell = cell as? RNSelectedPartCell {
                if indexPath.row < partArray.count {
                    let model = partArray[indexPath.row]
                    cell.configure(model: model)
                }
            }
        default:
            cell = UITableViewCell()
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
