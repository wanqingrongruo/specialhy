//
//  RNPayWayViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/11.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNPayWayViewController: UIViewController {
    
    var payWay:String
    var dataCallBack: (String) ->() // 数据回调
    
    init(payWay pw: String, callback cb: @escaping (String)->()) {
        self.payWay = pw
        self.dataCallBack = cb
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT) , style: .grouped)
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    lazy var dataSource: [String] = {
        let ones = ["现金支付", "微信支付", "Pos机支付", "无需支付"]
        return ones
    }()

    var selectedIndex = -1 // 选中的行

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "支付方式", target: self, action: #selector(dismissFromVC))]
        
        switch payWay {
        case PayWay.Cash.rawValue:
            selectedIndex = 0
        case PayWay.Wx.rawValue:
            selectedIndex = 1
        case PayWay.Pos.rawValue:
            selectedIndex = 2
        case PayWay.NoPay.rawValue:
            selectedIndex = 3
        default:
            break
        }

        view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissFromVC(){
       _ = self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNPayWayViewController: UITableViewDelegate, UITableViewDataSource{
    
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
            cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.text = dataSource[indexPath.row]
        }
        
        if indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        var way = ""
        switch indexPath.row {
        case 0:
            way = PayWay.Cash.rawValue
        case 1:
            way = PayWay.Wx.rawValue
        case 2:
            way = PayWay.Pos.rawValue
        case 3:
            way = PayWay.NoPay.rawValue
        default:
            break
        }
        
        dataCallBack(way)
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
}

