//
//  RNPictureBroswer.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/14.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import SKPhotoBrowser


class RNPictureBroswer {
    
    var fromVC: UIViewController // 从此 vc 跳转
    var fromView: UIView // 原 view
    var originImage: UIImage // 原image
    var currentIndex: Int
    var photos = [SKPhoto]() // 无论本地还是网络,图片数组转化为此数组
    
    init(from vc: UIViewController, showView view: UIView, originImage image: UIImage, currentIndex index: Int) {
        self.fromVC = vc
        self.fromView = view
        self.originImage = image
        self.currentIndex = index
    }
    
    
    
    lazy var localImages: [UIImage] = { // 本地图片浏览
        return [UIImage]()
    }()
    
    lazy var urlImages: [String] = { // 网络图片浏览
        return [String]()
    }()
    
    // 本地
    func showBrowserForLocal() {
        
        for item in localImages {
            let photo = SKPhoto.photoWithImage(item)
            photos.append(photo)
        }
        
        let browser = SKPhotoBrowser(originImage: originImage, photos: photos, animatedFromView: fromView)
        browser.initializePageIndex(currentIndex)
        browser.delegate = self
        
        fromVC.present(browser, animated: true, completion: nil)
        
    }
    
    // 网络
    func showBrowserForUrl() {
        
        for item in urlImages {
            let photo = SKPhoto.photoWithImageURL(item, holder: nil)
            photo.shouldCachePhotoURLImage = true
            photos.append(photo)
        }
        
        
        let browser = SKPhotoBrowser(photos: photos) //SKPhotoBrowser(originImage: originImage, photos: photos, animatedFromView: fromView)
        browser.initializePageIndex(currentIndex)
        browser.delegate = self
        
        fromVC.present(browser, animated: true, completion: nil)
    }

}

// 未调用
extension RNPictureBroswer: SKPhotoBrowserDelegate{
    
    // MARK: - SKPhotoBrowserDelegate
    func didShowPhotoAtIndex(index: Int) {
        // when photo will be shown
    }
    
    func willDismissAtPageIndex(index: Int) {
        // when PhotoBrowser will be dismissed
    }
    
    func didDismissAtPageIndex(index: Int) {
        // when PhotoBrowser did dismissed
    }
}
