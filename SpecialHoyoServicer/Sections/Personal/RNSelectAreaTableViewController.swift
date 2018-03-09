//
//  RNSelectAreaTableViewController.swift
//  HoyoServicer
//
//  Created by 婉卿容若 on 2017/3/15.
//  Copyright © 2017年 com.ozner.net. All rights reserved.
//

import UIKit

protocol RNSelectAreaTableViewControllerDelegate {
    func reloadInstallInfoUI(_ loaction: String) // 更新 UI
}


class RNSelectAreaTableViewController: UIViewController {
    
    var index:Int // 索引,表达跳转多少次, index = 1 //后 popToViewController
    var dataSource:[String] // 数据源
    var selectedStr: String // 选择的地区 (通过这个判定选择了地区数组的哪个城市)
    var location: String // 回调的数据
    
    var isThreeEdge = false // 是否是三级选择,, 默认二级
    
    var delegate: RNSelectAreaTableViewControllerDelegate?
    
//    // 关闭下拉dismiss 动画
//    override var dismissByForegroundDrag: Bool{
//        return false
//    }
    
//    fileprivate var myNav: RNCustomNavBar = {
//        
//        let nav = RNCustomNavBar(frame:  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: "nav_back", leftTitle: "选择地区", rightIcon:  nil, rightTitle: nil)
//        nav.createLeftView(target: self as AnyObject, action: #selector(popToLastVC))
//        return nav
//    }()
    
    var tableView: UITableView!

    
    var currentPresentingVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        switch index {
        case 0:
            // 第一次跳转
            navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "个人资料", target: self, action: #selector(dismissFromVC))]
            
        case 1:
            //第二次跳转
            navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "选择地区", target: self, action: #selector(popToLastVC))]
        case 2:
            // 第三次跳转
            navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "选择地区", target: self, action: #selector(popToLastVC))]
        default:
             break
        }
        
        setupUI()
        
    }
    
    init(index: Int, data: [String], location: String, selected: String) {
        self.index = index
        self.dataSource = data
        self.selectedStr = selected
        self.location = location
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidDisappear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}

//MARK: - custom methods
extension RNSelectAreaTableViewController {
    
    func setupUI() {
        
       // view.addSubview(myNav)
        
        
        // TO DO: - 封装成模块
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 0), style: .grouped)
        tableView.separatorStyle = .singleLine
        // tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableFooterView = UIView()
       
        
        view.addSubview(tableView)
    }
    
    
    @objc func popToLastVC() {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissFromVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSelectAreaTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        
        if indexPath.row < dataSource.count {
            cell.textLabel?.text = dataSource[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < dataSource.count else {
            return
        }
        
        let city = dataSource[indexPath.row]
        var loca = location + city
        
        switch index {
        case 0:
            
            loca += " "
            // 第二层
            let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
            let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
            let tmpObject: AnyObject?
            do{
                tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            let adressArray = tmpObject as! NSMutableArray
            
            var provinceArr = [String]()
            for item in adressArray {
                let str = (item as AnyObject)["name"] as! String
                
                if str == city {
                    
                    let arr = (item as AnyObject)["cities"] as! NSMutableArray
                    
                    for item02 in arr {
                        
                        let str02 = (item02 as AnyObject)["name"] as! String
                        provinceArr.append(str02)
                    }
                    
                }
            }
            let selectAreaVC = RNSelectAreaTableViewController(index: 1, data: provinceArr, location: loca, selected: city)
            selectAreaVC.delegate = delegate
            selectAreaVC.isThreeEdge = isThreeEdge
            navigationController?.pushViewController(selectAreaVC, animated: true)

            
            break
        case 1:
            
            if !isThreeEdge {
                
                // 返回最上层
                self.delegate?.reloadInstallInfoUI(loca)
                // self.presentingViewController = self.currentPresentingVC
                self.dismiss(animated: true, completion: nil)
                return

            }
            loca += " "
            // TO DO: 更好的封装
            // 第三层
            let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
            let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
            let tmpObject: AnyObject?
            do{
                tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
            }
            let adressArray = tmpObject as! NSMutableArray
            
            var provinceArr = [String]()
            for item in adressArray {
                
                let arr = (item as AnyObject)["cities"] as! NSMutableArray
                
                for item02 in arr {
                    
                    let str02 = (item02 as AnyObject)["name"] as! String
                    
                    if str02 == city {
                        
                        let arr02 = (item02 as AnyObject)["area"] as! [String]
                        
                        for item03 in arr02 {
                            provinceArr.append(item03)
                        }
                    }
                }
                
                
            }
            let selectAreaVC = RNSelectAreaTableViewController(index: 2, data: provinceArr, location: loca, selected: city)
            selectAreaVC.delegate = delegate
            navigationController?.pushViewController(selectAreaVC, animated: true)
            break
            
        case 2:
            // 返回最上层
            self.delegate?.reloadInstallInfoUI(loca)
            self.dismiss(animated: true, completion: nil)
            return

        default:
            break
        }

    
    }
}

extension RNSelectAreaTableViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.index == 0 && targetContentOffset.pointee.y < -44 {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

