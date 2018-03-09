//
//  RNPushStringViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/9/27.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RealmSwift

class RNPushStringViewController: RNBaseTableViewController {
    
    var tableView: UITableView!
    
    lazy var dataSource: [PushStringModel] = {
        
        let array = realmQueryResults(Model: PushStringModel.self)
        
        var arr = [PushStringModel]()
        for item in array.reversed() { // 倒序
            arr.append(item)
        }
        return arr
        
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "浩优推送", target: self, action: #selector(dismissFromVC))]
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - event response
extension RNPushStringViewController {
    
    @objc func dismissFromVC(){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - custom methods
extension RNPushStringViewController {
    
    func setupUI() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .plain)
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GYDetailNewCell.self, forCellReuseIdentifier: "GYDetailNewCell")
        tableView.tableFooterView = UIView()
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNPushStringViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "GYDetailNewCell", for: indexPath)
        
        let model = dataSource[indexPath.row]
        
        if let cell = cell as? GYDetailNewCell {
            // 显示
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.lightGray
            cell.reloadUI(model)
        }
        
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
            
            let model = dataSource[indexPath.row]
            // 删除数据库数据
            realmDeleteObject(Model: PushStringModel.self, condition: { (models) -> PushStringModel? in
                
                for item in models {
                    if (item.msgId != "") && (item.msgId == model.msgId) {
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
    
}
