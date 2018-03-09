//
//  RNFeeDetailViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/10/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNFeeDetailViewController: RNBaseTableViewController {

    
    var tableView: UITableView!
    
    var dataSource: [MoneyModel]
    
    
    init(_ array: [MoneyModel]) {
        self.dataSource = array
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "费用详情", target: self, action: #selector(dismissFromVC))]
        
        setupUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissFromVC(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}


extension RNFeeDetailViewController {
    
    func setupUI() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .plain)
        tableView.rowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNFeeDetailCell", bundle: nil), forCellReuseIdentifier: "RNFeeDetailCell")
        tableView.tableFooterView = UIView()
        
        // 空数据
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        view.addSubview(tableView)
        
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNFeeDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNFeeDetailCell", for: indexPath)
        let model = dataSource[indexPath.row]
        if let cell = cell as? RNFeeDetailCell {
            cell.configCell(model)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
