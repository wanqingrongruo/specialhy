//
//  RNTroubleViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNTroubleViewController: RNBaseTableViewController {
    
    var window: UIWindow?
    var detailVC: RNTroubleDetailViewController?
    var bottomView: RNSigleButtonView?
    
    // 正式调用时使用的初始化方法
    var dataSource: [String] // 已选配件
    var dataCallBack: (([String]) ->()) // 数据回调
    
    init(dataSource datas: [String], callBack backClousure: @escaping ([String]) ->()) {
        self.dataSource = datas
        self.dataCallBack = backClousure
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 64+45, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64 - 45 - 60 - 5) , style: .plain)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "故障&解决", target: self, action: #selector(dismissFromVC))]
        
        setUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RNTroubleViewController {
    
    func setUI() {
        
        let titleView = UIView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: 40))
        titleView.backgroundColor = UIColor.white
        view.addSubview(titleView)
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: (40-25)/2, width: 200, height: 25))
        // titleLabel.center = CGPoint(x: 8, y: titleView.frame.height/2)
        titleLabel.text = "故障&解决"
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
        titleView.addSubview(titleLabel)
        
        
        let addButton = UIButton(type: .custom)
        addButton.frame = CGRect(x: SCREEN_WIDTH - 8 - 30, y: 5, width: 30, height: 30)
        addButton.setImage(UIImage(named: "order_add"), for: .normal)
        addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        titleView.addSubview(addButton)
        
        view.addSubview(tableView)
        
        bottomView = Bundle.main.loadNibNamed("RNSigleButtonView", owner: self, options: nil)?.last as? RNSigleButtonView
        bottomView?.frame = CGRect(x: 0, y: SCREEN_HEIGHT-60-5, width: SCREEN_WIDTH, height: 60)
        bottomView?.sigleButton.setTitle("完成", for: .normal)
        bottomView?.callBack = { [weak self] tag in
            
            // 返回操作
            self?.dataCallBack(self!.dataSource)
            _ = self?.navigationController?.popViewController(animated: true)
        }
        view.addSubview(bottomView!)
        
        
    }
    
    @objc func addAction() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let detailVC = RNTroubleDetailViewController()
        window?.windowLevel = UIWindowLevelNormal
        window?.rootViewController = detailVC
        
        detailVC.appWindow = UIApplication.shared.keyWindow
        
        detailVC.callBack = {  [weak self] (resultString) in
            
            self?.window = nil
            self?.dataSource.append(resultString)
            
            let indexPath = IndexPath(item: self!.dataSource.count-1, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .fade)
            self?.tableView.reloadEmptyDataSet()
            
           // self?.tableView.reloadData()
        }
        
        window?.makeKeyAndVisible()
        
    }
    @objc func dismissFromVC(){
        _ = self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNTroubleViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewCell")
        
        if indexPath.row < dataSource.count {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)//UIFont(name: "Helvetica-Bold", size: 14)
            cell.textLabel?.textColor = UIColor.gray
            cell.textLabel?.text = dataSource[indexPath.row]
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataSource.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadEmptyDataSet()
            self.tableView.endUpdates()
        }
    }
}
