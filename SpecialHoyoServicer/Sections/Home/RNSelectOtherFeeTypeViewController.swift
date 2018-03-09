//
//  RNSelectOtherFeeTypeViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2016/10/31.
//  Copyright © 2016年 com.ozner.net. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift


typealias CallBack = ([(String, Double)]) -> ()

class RNSelectOtherFeeTypeViewController: UIViewController {
    
    internal var backClosure: CallBack
    
    fileprivate var tableView: UITableView!
    
    fileprivate lazy var dataSource = {
        return ["水费:","打孔费:","超区域服务费:","非标材料费:"]
    }()
    
    fileprivate var feeDic = [Int: Double]() // 
    fileprivate var feeTypeDic = [Int: String]()
    
    fileprivate lazy var feeArray = {
        return [(String, Double)]()
    }()
    
    fileprivate var selectedRows = [IndexPath]()
    fileprivate var selectedTitleInfos: [String]
    fileprivate var selectedFeeInfos:[Double]
    
    var tmpCell: RNOtherFeeTypeTableViewCell?
    
    init(selectedTitle:[String], selectedFees:[Double], callBack: @escaping ([(String, Double)])->()){
        
        selectedTitleInfos = selectedTitle
        selectedFeeInfos = selectedFees
        backClosure = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "服务费用", target: self, action: #selector(disMissBtn))]
        navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("保存", target: self, action: #selector(saveAction))
        
        loadHadData()
        
        setupTableView()

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
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    deinit{
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - custome Methods

extension  RNSelectOtherFeeTypeViewController{
    
    // 处理源数据(已选)
    func loadHadData(){
        for item in selectedTitleInfos {
            for (index, value) in dataSource.enumerated() {
                if item == value {
                    let path = IndexPath(row: index, section: 0)
                    selectedRows.append(path)
                }
            }
        }
    }
    // 常见tableView
    func setupTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UINib(nibName: "RNOtherFeeTypeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "RNOtherFeeTypeTableViewCell")
        
        
        view.addSubview(tableView)
    }
}


// MARK: - Event response - 按钮/手势等事件的回应方法

extension RNSelectOtherFeeTypeViewController{
    
    // 返回
    @objc func disMissBtn(){
        
//        getData()
//        backClosure(feeArray)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAction(){
        getData()
        backClosure(feeArray)
        _ = navigationController?.popViewController(animated: true)
    }
    
    func getData(){
        
        feeArray.removeAll()
        for item in selectedRows {
            let cell = self.tableView.cellForRow(at: item) as! RNOtherFeeTypeTableViewCell
            
            var money = 0.0
            if cell.moneyTextField.text! == "." {
                money = 0.0
            }else{
               money = cell.moneyTextField.text! == "" ? 0.0 : Double(cell.moneyTextField.text!)!
            }
            
            feeArray.append((cell.titleLabel.text!, money))
        }
        
    }
    
}

//extension RNSelectOtherFeeTypeViewController: RNOtherFeeTypeTableViewCellDelegate{
//    
////    func updateData(index: NSIndexPath) {
////        
////        feeArray.append((tmpCell?.feeTypeDic[index.row], tmpCell?.myMoney[index.row]))
////    }
//}


// MARK: - UITableViewDelegate && UITabelViewDatasource

extension  RNSelectOtherFeeTypeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RNOtherFeeTypeTableViewCell", for: indexPath)
        
        tmpCell = cell as? RNOtherFeeTypeTableViewCell
       
       // tmpCell?.delegate = self
        
        tmpCell?.configCell(dataSource[indexPath.row], hasTitles: selectedTitleInfos, hasFees: selectedFeeInfos, index: indexPath) 
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath) as! RNOtherFeeTypeTableViewCell
        
        
        cell.changeSelectedState(indexPath.row)
    
        if cell.isCellSelected! {
            if selectedRows.contains(indexPath) {
                //
            }else{
                 selectedRows.append(indexPath)
            }
          
        }else{
            for (index, value) in selectedRows.enumerated() {
                if value == indexPath{
                    selectedRows.remove(at: index)
                }
            }
        }
    }
    
}


