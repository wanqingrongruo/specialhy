//
//  RNSettingViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/15.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNSettingViewController: ElasticModalViewController {
    
    // 关闭下拉dismiss 动画
    override var dismissByForegroundDrag: Bool{
        return false
    }
    
    fileprivate var myNav: RNCustomNavBar = {
        
        let nav = RNCustomNavBar(frame:  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: "nav_back", leftTitle: "个人中心", rightIcon:  nil, rightTitle: nil)
        nav.createLeftView(target: self as AnyObject, action: #selector(popToLastVC))
        return nav
    }()
    
    var tableView: UITableView!
    
    lazy var titles: [String] = {
        
        let arr01 = ["当前版本", "退出登录"]
        
        return arr01
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BASEBACKGROUNDCOLOR

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: - custom methods
extension RNSettingViewController {
    
    func setupUI() {
        
        view.addSubview(myNav)
        
        // TO DO: - 封装成模块
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = BASEBACKGROUNDCOLOR
        tableView.separatorColor = BASEBACKGROUNDCOLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT*0.4))
        myView.backgroundColor = UIColor.clear
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT*0.2, height: SCREEN_HEIGHT*0.2))
        imageView.center = myView.center
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named:"log_appIcon")
        myView.addSubview(imageView)
        
        tableView.tableHeaderView = myView
    }
    
    
    @objc func popToLastVC() {
        
        self.dismissFromTop(view)
        //self.dismissFromLeft(view)
    }

}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSettingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return SCREEN_HEIGHT*0.4
//        // return CGFloat.leastNormalMagnitude
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//      
//        
//        return view
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = titles[indexPath.row]
            cell.detailTextLabel?.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            cell.selectionStyle = .none
        }else{
            
            cell.textLabel?.text =  titles[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            
            let alert = UIAlertController(title: "提示", message: "退出后将不再接受通知消息", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title: "确定", style: .destructive) { (_) in
                
                // 解绑推送
                UserServicer.bingJpush(["notifyid": "loginout"], successClourue: {
                    
                   // self.dismiss(animated: false, completion: {
                         globalAppDelegate.isValidToken = true
                         globalAppDelegate.logOut()
                  //  })
                   
                }) { (msg, code) in
                 //   RNNoticeAlert.showError("提示", body: "推送解绑失败")
                    globalAppDelegate.logOut()
                }

            }
            let cancelButton = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancelButton)
            alert.addAction(deletaButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -124 {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
