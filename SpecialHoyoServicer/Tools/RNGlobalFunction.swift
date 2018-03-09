//
//  RNGlobalFunction.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/18.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import CoreLocation


/// 点击拨打电话
///
/// - Parameter number: 电话号码
func dailing(number: String) {
    
    let telephoneNum = "telprompt://\(number)"
    guard let tel = URL(string: telephoneNum) else{
        
        RNNoticeAlert.showError("提示", body: "联系号码格式不正确: \(number)")
        return
    }
    UIApplication.shared.openURL(tel)
    
}


/// 计算两个坐标之间的距离
///
/// - Parameters:
///   - latitude01: 纬度01 - 当前地点坐标
///   - longitude01: 经度01
///   - latitude02: 纬度02 -- 目标地点坐标
///   - longitude02: 经度02
/// - Returns: 距离, 单位 KM
func distanceBetweenLocationBy(latitude01: Double, longitude01: Double, latitude02: Double, longitude02: Double) -> Double{
    
    let currentLocation = CLLocation(latitude: latitude01, longitude: longitude01)
    let otherLocation = CLLocation(latitude: latitude02, longitude: longitude02)
    
    // 两个坐标直接的距离, 单位 KM
    let distance = currentLocation.distance(from: otherLocation) / 1000.0
    
    return distance
}



/// 计算字符串的 rect
///
/// - Parameters:
///   - text: 需要计算字符串
///   - font: 字体
///   - size: size
/// - Returns: 最大显示区域
func getTextRectSize(text: String,font: UIFont,size: CGSize) -> CGRect {
    
    let attributes = [NSAttributedStringKey.font: font]
    let option = NSStringDrawingOptions.usesLineFragmentOrigin
    let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
    return rect;
}



/// 压缩图片 -- 以绘制图片的形式压缩, 只改变大小不失真
///
/// - Parameters:
///   - image: 需要绘制的图片
///   - size: 目标尺寸
/// - Returns: 新图
func drawNewImageForCompress(origi image: UIImage, newSize size: CGSize) -> UIImage?{
    UIGraphicsBeginImageContext(size)
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

extension UIViewController
{
    // 获取当前显示的ViewController
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController
        {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController
        {
            return currentViewController(base: presented)
        }
        return base
    }
}

// 是否开启冲水功能
func getIsEnable(successClourue: ((Bool)->Void)?, failureClousure: ((String, Int) -> Void)?) {
    
    guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
        RNNoticeAlert.showError("提示", body: "未获取到 userToken")
        return
    }
    OrderServicer.getIsEnable(["usertoken": token], successClourue: { (state) in
        successClourue?(state)
    }) { (msg, code) in
        failureClousure?(msg, code)
    }
}


