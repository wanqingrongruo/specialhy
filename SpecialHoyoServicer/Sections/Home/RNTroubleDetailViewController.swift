//
//  RNTroubleDetailViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import SwiftyJSON

class RNTroubleDetailViewController: UIViewController {
    
    weak var appWindow: UIWindow?
    var callBack: ((_ resultString: String) -> ())?
    
    static let titleHeight: CGFloat = 40
    static let selectViewHeight: CGFloat = 40
    
    lazy var contentView: UIView = {
        
        let v =  UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 0))
        v.backgroundColor = BASEBACKGROUNDCOLOR
        return v
    }()
    
    lazy var dataSource: [String: [String]] = {
        
        return [String: [String]]()
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: RNTroubleDetailViewController.titleHeight + RNTroubleDetailViewController.selectViewHeight + 4, width: SCREEN_WIDTH, height: SCREEN_HEIGHT*0.8 - 64 - RNTroubleDetailViewController.titleHeight - RNTroubleDetailViewController.selectViewHeight - 4) , style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    var backView = UIView()
    var reasonButton = UIButton(type: UIButtonType.custom)
    var solutionButton = UIButton(type: UIButtonType.custom)
    var slideView = UIView()
    
    var isReason: Bool = true // 是不是故障原因选择 - 默认 true
    var reasonString: String = "" // 原因
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.color(77, green: 77, blue: 77, alpha: 0.5)
        
        prepareData()
        
        setUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissVC(){
        
        UIView.animate(withDuration: 0.4, animations: {
            self.contentView.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 0)
        }) { (finish) in
            self.view.alpha = 0
            self.appWindow?.makeKeyAndVisible()
        }
    }
    
}


// MARK: - custom methods

extension RNTroubleDetailViewController {
    
    func setUI() {
        
        let upView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64 + SCREEN_HEIGHT*0.2))
        upView.backgroundColor = UIColor.clear
        view.addSubview(upView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        upView.addGestureRecognizer(tap)
        
        
        view.addSubview(contentView)
        
        createTitleView()
        createSelectView()
        
        contentView.addSubview(tableView)
        
        UIView.animate(withDuration: 1.0) {
            self.contentView.frame = CGRect(x: 0, y: 64 + SCREEN_HEIGHT*0.2, width: SCREEN_WIDTH, height: SCREEN_HEIGHT*0.8 - 64)
        }
        
    }
    
    func createTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: RNTroubleDetailViewController.titleHeight))
        titleView.backgroundColor = UIColor.white
        contentView.addSubview(titleView)
        
        let titleLabel = UILabel(frame: CGRect(x: SCREEN_WIDTH/2 - 100, y: RNTroubleDetailViewController.titleHeight/2 - 12.5, width: 200, height: 25))
        titleLabel.text = "故障&解决"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
        titleView.addSubview(titleLabel)
    }
    
    func createSelectView() {
        backView.frame = CGRect(x: 0, y: RNTroubleDetailViewController.titleHeight + 2, width: SCREEN_WIDTH, height: RNTroubleDetailViewController.selectViewHeight)
        backView.backgroundColor = UIColor.white
        contentView.addSubview(backView)
        
        reasonButton.frame = CGRect(x: 8, y: (RNTroubleDetailViewController.selectViewHeight-25)/2, width: 50, height: 25)
        reasonButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        reasonButton.setTitle("请选择", for: .normal)
        reasonButton.setTitleColor(UIColor.red, for: .normal)
        reasonButton.addTarget(self, action: #selector(reasonAction), for: .touchUpInside)
        backView.addSubview(reasonButton)
        
        solutionButton.frame = CGRect(x: 8 + reasonButton.frame.width + 12, y: (RNTroubleDetailViewController.selectViewHeight-25)/2, width: 50, height: 25)
        solutionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        solutionButton.setTitle("请选择", for: .normal)
        solutionButton.setTitleColor(UIColor.red, for: .normal)
        solutionButton.addTarget(self, action: #selector(solutionAction), for: .touchUpInside)
        solutionButton.isHidden = true
        backView.addSubview(solutionButton)
        
        slideView.frame = CGRect(x: 0, y: 0, width: 40, height: 2)
        slideView.center = CGPoint(x: reasonButton.center.x, y: RNTroubleDetailViewController.selectViewHeight-2)
        slideView.backgroundColor = UIColor.red
        backView.addSubview(slideView)
        
    }
    
    @objc func reasonAction() {
        
        isReason = true
        reasonString = ""
        solutionButton.isHidden = true
        
        reasonButton.frame = CGRect(x: 8, y: (RNTroubleDetailViewController.selectViewHeight-25)/2, width: 50, height: 25)
        reasonButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        reasonButton.setTitle("请选择", for: .normal)
        reasonButton.setTitleColor(UIColor.red, for: .normal)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.slideView.frame = CGRect(x: 0, y: 0, width: 40, height: 2)
            self.slideView.center = CGPoint(x: self.reasonButton.center.x, y: 40-2)
        }, completion: nil)
        
        backView.setNeedsLayout()
        backView.layoutIfNeeded()
        backView.layoutSubviews()
        
        tableView.reloadData()
    }
    
    @objc func solutionAction() {
        
    }
    
    func prepareData() {
        
        let jsonPath = Bundle.main.path(forResource: "trouble", ofType: "json")
        let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
        //        let tmpObject: AnyObject?
        //        do{
        //            tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        //        }
        //    let array = tmpObject as! [String: Any]
        let array = (try! JSON(data: jsonData, options: .mutableContainers)).array
        
        guard let a = array else{
            RNNoticeAlert.showError("提示", body: "故障问题以及解决方法数据解析失败")
            return
        }
        for item in a {
            let key = item["margin"].stringValue
            let values = item["subres"].array
            var arr = [String]()
            guard let vs = values else {
                RNNoticeAlert.showError("提示", body: "故障问题以及解决方法数据解析失败")
                return
            }
            for v in vs {
                arr.append(v.description)
            }
            dataSource[key] = arr
        }
        
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNTroubleDetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isReason {
            return dataSource.keys.count
        }else{
            
            let arr = dataSource[reasonString] ?? [String]()
            return arr.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        cell = UITableViewCell(style: .default, reuseIdentifier: "tableViewCell")
        
        if isReason {
            let reasons = Array(dataSource.keys)
            
            if indexPath.row < reasons.count {
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.text = reasons[indexPath.row]
            }
        }else{
            
            let solutions = dataSource[reasonString] ?? [String]()
            if indexPath.row < solutions.count {
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell.textLabel?.textColor = UIColor.lightGray
                cell.textLabel?.text = solutions[indexPath.row]
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isReason {
            let reasons = Array(dataSource.keys)
            if indexPath.row < reasons.count {
                reasonString = reasons[indexPath.row]
                isReason = false
                
                let rect = getTextRectSize(text: reasonString, font: UIFont.systemFont(ofSize: 14), size: CGSize(width: SCREEN_WIDTH-8-50-12-8, height: 25))
                reasonButton.frame =  CGRect(x: 8, y: (RNTroubleDetailViewController.selectViewHeight-25)/2, width: rect.size.width, height: 25)
                reasonButton.setTitle(reasonString, for: .normal)
                reasonButton.setTitleColor(UIColor.lightGray, for: .normal)
                
                solutionButton.frame = CGRect(x: 8 + reasonButton.frame.width + 12, y: (RNTroubleDetailViewController.selectViewHeight-25)/2, width: 50, height: 25)
                solutionButton.isHidden = false
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.slideView.frame = CGRect(x: 0, y: 0, width: 40, height: 2)
                    self.slideView.center = CGPoint(x: self.solutionButton.center.x, y: 40-2)
                }, completion: nil)
                
                backView.setNeedsLayout()
                backView.layoutIfNeeded()
                backView.layoutSubviews()
                
                tableView.reloadData()
            }
        }else{
            
            // 回调 -> 释放 window,
            var result = reasonString
            let solutions = dataSource[reasonString] ?? [String]()
            if indexPath.row < solutions.count {
                result = result + ":" + solutions[indexPath.row]
            }
            
            UIView.animate(withDuration: 0.4, animations: {
                self.contentView.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: 0)
            }) { (finish) in
                self.view.alpha = 0
                self.appWindow?.makeKeyAndVisible()
                self.callBack?(result)
            }
        }
        
    }
}
