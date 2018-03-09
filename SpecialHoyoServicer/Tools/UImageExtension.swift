//
//  UImageExtension.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/28.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    
    // Get avarage color
    func avarageColor() -> UIColor? {
        let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        guard let context = CGContext(
            data: rgba,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
        }
        if let cgImage = self.cgImage {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            
            return UIColor(
                red: CGFloat(rgba[0]) / 255.0,
                green: CGFloat(rgba[1]) / 255.0,
                blue: CGFloat(rgba[2]) / 255.0,
                alpha: CGFloat(rgba[3]) / 255.0
            )
        }
        return nil
    }

}

public extension UIImage {
    
    /// 绘制图片颜色
    ///
    /// - Parameter color: UIColor
    /// - Returns: New Image
    public func imageChange(color: UIColor) -> UIImage? {
        let imageReact = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(imageReact.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -imageReact.size.height)
        context?.clip(to: imageReact, mask: cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(imageReact)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 制作最佳的可压缩图片
    ///
    /// - ratio : 压缩系数 - 默认压缩系数0.5
    /// - Returns: 输出图片
    public func compress(with ratio: CGFloat = 0.5) -> UIImage? {
        let width = size.width
        let height = size.height
        
        var newWidth: CGFloat = width
        var newHeight: CGFloat = height
        
        if width <= 1280 && height <= 1280 {
            newWidth = width
            newHeight = height
        } else if (width > 1280 || height > 1280) && width/height <= 2.0 {
            if width > height {
                newWidth = 1280
                newHeight = 1280 * height / width
            } else {
                newWidth = 1280 * width / height
                newHeight = 1280
            }
        } else if (width > 1280 || height > 1280) && width/height > 2.0 && (width < 1280 || height < 1280) {
            newWidth = width
            newHeight = height
        } else if width > 1280 && height > 1280 && width/height > 2.0 {
            if width > height {
                newWidth = 1280 * width / height
                newHeight = 1280
            } else {
                newWidth = 1280
                newHeight = 1280 * height / width
            }
        }
        
        let imageSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(imageSize)
        draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        if let sm = scaledImage, let newData = UIImageJPEGRepresentation(sm, ratio) {
            return UIImage(data: newData)
        }
        
        return nil
    }
}
