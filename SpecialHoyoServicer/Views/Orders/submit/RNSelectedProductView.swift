//
//  RNSelectedProductView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/8.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import SnapKit

protocol RNSelectedProductViewProtocol {
    func deleteAll()
    
    func addAction(_ model: PartModel)
    func subAction(_ model: PartModel, _ isDeleteRow: Bool)
}

class RNSelectedProductView: UIView {

    var tableView: UITableView!
    var dataSource: [PartModel]
    
    var headView: RNSimpleTitleView?
    
    var delegate: RNSelectedProductViewProtocol?
    
    init(_ dataArray: [PartModel]) {
        
        self.dataSource = dataArray
        
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.color(249, green: 249, blue: 249, alpha: 1)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        var height: CGFloat = CGFloat(dataSource.count * 44 + 44)
        
        if height > SCREEN_HEIGHT*0.6 {
            height = SCREEN_HEIGHT*0.6
        }
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height), style: .plain)
        tableView.rowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNSimplePartCell", bundle: nil), forCellReuseIdentifier: "RNSimplePartCell")
        
        self.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
    }
    
    // 更新视图
    func updateFrame() {
        
        let height: CGFloat = CGFloat(dataSource.count * 44 + 44)
        
        if height >= SCREEN_HEIGHT*0.6 {
            return
        }
             
        self.frame = CGRect(x: 0, y: SCREEN_HEIGHT - height - 60, width: SCREEN_WIDTH, height: height)
        tableView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.layoutSubviews()
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNSelectedProductView: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headView = Bundle.main.loadNibNamed("RNSimpleTitleView", owner: nil, options: nil)?.last as? RNSimpleTitleView
        headView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44)
        headView?.backgroundColor = UIColor.color(239, green: 239, blue: 239, alpha: 1)
        
        headView?.deleteAllClosure = { [weak self] in
            // 清空所有数据
            self?.delegate?.deleteAll()
        }

        return headView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "RNSimplePartCell", for: indexPath)
        
        let model = dataSource[indexPath.row]
        
        if let cell = cell as? RNSimplePartCell {
            
            cell.config(model, indexPath: indexPath)
            
            cell.addCallBack = { (index, m) in
                
                // 修改数量
                let arr = self.dataSource.map({ (model) -> PartModel in
                    if model.productId == m.productId {
                        model.productAmount = m.productAmount
                    }
                    return model
                })
                
                self.dataSource = arr
                self.delegate?.addAction(m)
            }
            cell.subCallBack = { (index, m, isEmpty) in
                
                
                if isEmpty {
                    
                    // 完全删除一行
                    var arr = [PartModel]()
                    for model in self.dataSource {
                        if model.productId != m.productId{
                            arr.append(model)
                        }
                    }
                    self.dataSource = arr
                    
                    self.updateFrame()

                    tableView.reloadData()
               //     tableView.deleteRows(at: [index], with: .fade)
                    
                }else{
                   
                    // 单纯修改数量
                    let arr = self.dataSource.map({ (model) -> PartModel in
                        if model.productId == m.productId {
                            model.productAmount = m.productAmount
                        }
                        return model
                    })
                    
                    self.dataSource = arr

                }
                
                self.delegate?.subAction(m, isEmpty)
                
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


