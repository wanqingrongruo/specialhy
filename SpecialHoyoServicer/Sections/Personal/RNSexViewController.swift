//
//  RNSexViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSexViewController: ElasticModalViewController {
    
    var callBack: ((_ sex: String) -> ())
    var currentSex: String?
    
    // 关闭下拉dismiss 动画
    override var dismissByForegroundDrag: Bool{
        return false
    }
    
    fileprivate var myNav: RNCustomNavBar = {
        
        let nav = RNCustomNavBar(frame:  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: "nav_back", leftTitle: "个人资料", rightIcon:  nil, rightTitle: nil)
        nav.createLeftView(target: self as AnyObject, action: #selector(popToLastVC))
        return nav
    }()
    
    var tableView: UITableView!
    
    lazy var titles: [String] = {
        
        return ["男", "女", "保密"]
    }()

    
    init(sex: String?, callBack: @escaping (_ sex: String) -> ()) {
        self.currentSex = sex
        self.callBack = callBack
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "个人资料", target: self, action: #selector(popToLastVC))]
         setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
}

//MARK: - custom methods
extension RNSexViewController {
    
    func setupUI() {
        
       // view.addSubview(myNav)
        
        // TO DO: - 封装成模块
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .grouped)
        tableView.separatorStyle = .singleLine
        // tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
    }
    
    
    @objc func popToLastVC() {
        
        self.navigationController?.popViewController(animated: true)
//        self.dismissFromLeft(view)
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSexViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
        // return CGFloat.leastNormalMagnitude
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        
        cell.textLabel?.text = titles[indexPath.row]
        
        if currentSex == titles[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        
//       let cell =  tableView.cellForRow(at: indexPath)
////        if cell?.accessoryType != UITableViewCellAccessoryType.checkmark {
////            cell?.accessoryType = .checkmark
////        }
//        self.currentSex = cell?.textLabel?.text
//        let set = IndexSet(integer: 0)
//        tableView.reloadSections(set, with: .none)
        
            
        let cSex = titles[indexPath.row]
        callBack(cSex)
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
