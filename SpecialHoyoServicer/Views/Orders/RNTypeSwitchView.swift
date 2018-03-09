//
//  RNTypeSwitchView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNTypeSwitchView: UIView {
    
    var types: [(code: String, title: String)]
    var collectionView: UICollectionView!
    fileprivate var paading: CGFloat = 10
    fileprivate var selectedIndex: IndexPath?
    internal var callBack: ((_ indexPath: IndexPath) -> ())?
    
    init(frame: CGRect, types: [(code: String, title: String)]) {
        self.types = types
        super.init(frame: frame)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: layout)
        self.collectionView.register(UINib.init(nibName: "RNtTypeSwitchCell", bundle: nil), forCellWithReuseIdentifier: "RNtTypeSwitchCell")
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        addSubview(self.collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension RNTypeSwitchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RNtTypeSwitchCell", for: indexPath) as! RNtTypeSwitchCell
        
        configureCell(cell, indexpath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: RNtTypeSwitchCell, indexpath: IndexPath) {
        let tupleForItem = types[indexpath.item].title
        cell.titleLabel.text = tupleForItem
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selected = self.selectedIndex else {
            if let cell = collectionView.cellForItem(at: indexPath) as? RNtTypeSwitchCell {
                cell.titleLabel.textColor = MAIN_THEME_COLOR
            }
            selectedIndex = indexPath
            callBack?(indexPath)
            return
        }
        
        guard selected != indexPath else {
            return
        }
        
        if let cell = collectionView.cellForItem(at: selected) as? RNtTypeSwitchCell {
            cell.titleLabel.textColor = UIColor.black
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? RNtTypeSwitchCell {
            cell.titleLabel.textColor = MAIN_THEME_COLOR
        }
        
        selectedIndex = indexPath
        
        callBack?(indexPath)
    }
}

extension RNTypeSwitchView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var font = UIFont.systemFont(ofSize: 17)
        if let cell = collectionView.cellForItem(at: indexPath) as? RNtTypeSwitchCell {
            font = cell.titleLabel.font
        }
        let title = types[indexPath.item].title
        let rect = title.sizeWithText(text: (title as NSString), font: font, size: CGSize(width: Double(MAXFLOAT), height: 25.0))
        let size = CGSize(width: rect.size.width + self.paading * 2, height: 44)
        
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
}
