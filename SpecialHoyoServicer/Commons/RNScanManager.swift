//
//  RNScanManager.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/1.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import swiftScan
import AVFoundation
import Photos
import AssetsLibrary

protocol RNScanManagerProtocol {
    func scanFinished(scanResult: RNScanResult, error: String?)
}


// 扫描 manager

struct RNScanManager {
    var animationImage: String
    var fromViewController: UIViewController
    var toViewController: UIViewController?
    
    var delegate: RNScanManagerProtocol?
    
    init(animationImage image: String, viewController: UIViewController) {
        self.animationImage = image
        self.fromViewController = viewController
    }
    
    // present
    mutating func beginScan() {
        let vc = RNQRScanViewController()
        self.toViewController = vc
        
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: animationImage)
        style.colorAngle = MAIN_THEME_COLOR
        vc.scanStyle = style
        vc.scanResultDelegate = self as LBXScanViewControllerDelegate
        
        let nav = RNBaseNavigationController(rootViewController: vc)
        self.fromViewController.present(nav, animated: true, completion: nil)
    }
    
    // push
    mutating func beginScanWithPush() {
        let vc = RNQRScanViewController()
        self.toViewController = vc
        
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: animationImage)
        style.colorAngle = MAIN_THEME_COLOR
        vc.scanStyle = style
        vc.scanResultDelegate = self as LBXScanViewControllerDelegate
        
        let nav = RNBaseNavigationController(rootViewController: vc)
        self.fromViewController.navigationController?.pushViewController(nav, animated: true)
    }
}

struct RNScanResult {
    
    public var strScanned:String? = "" //码内容
    public var imgScanned:UIImage?  //扫描图像
    public var strBarCodeType:String? = "" //码的类型
    public var arrayCorner:[AnyObject]? //码在图像中的位置
    
    public init(str:String?,img:UIImage?,barCodeType:String?,corner:[AnyObject]?)
    {
        self.strScanned = str
        self.imgScanned = img
        self.strBarCodeType = barCodeType
        self.arrayCorner = corner
    }
}

// LBXScanViewControllerDelegate
extension RNScanManager: LBXScanViewControllerDelegate{
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        
        
        if self.toViewController?.presentingViewController != nil {
            self.toViewController?.dismiss(animated: true, completion: {
                let result = RNScanResult(str: scanResult.strScanned, img: scanResult.imgScanned, barCodeType: scanResult.strBarCodeType, corner: scanResult.arrayCorner)
                self.delegate?.scanFinished(scanResult: result, error: error)
            })
        }else{
            let result = RNScanResult(str: scanResult.strScanned, img: scanResult.imgScanned, barCodeType: scanResult.strBarCodeType, corner: scanResult.arrayCorner)
            self.delegate?.scanFinished(scanResult: result, error: error)
            _ = self.toViewController?.navigationController?.popViewController(animated: true)
        }
    }
}
