//
//  RNScreenShot.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit

struct RNScreenShotManager {
    
    // 截图 - scrollView
    static func shot(for scrollView: UIScrollView, with opaque: Bool = true, and scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        var image: UIImage? = nil
        let currentScrollView = scrollView
        
        UIGraphicsBeginImageContextWithOptions(currentScrollView.contentSize, opaque, scale)
        
        // 保存
        let saveContentOffset = currentScrollView.contentOffset
        let saveFrame = currentScrollView.frame
        
        // 至0
        currentScrollView.contentOffset = CGPoint.zero
        currentScrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        // 上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        // 根据上下文渲染 scrollView
        currentScrollView.layer.render(in: context)
        // 生成 image
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        currentScrollView.contentOffset = saveContentOffset
        currentScrollView.frame = saveFrame
        
        UIGraphicsEndImageContext()
        
        if let im = image {
//            // 保存图片到相册 -- 未掉代理方法判断是否保存成功
//            UIImageWriteToSavedPhotosAlbum(im, self, nil, nil)
        }
        
        return image
    }
    
    // 拼接图片
    static func merge(image originImage: UIImage, with otherImage: UIImage, with opaque: Bool = true, and scale: CGFloat = UIScreen.main.scale, padding: CGFloat = 0, and bottom: CGFloat = 0) -> UIImage? {
        let size = CGSize(width: originImage.size.width, height: originImage.size.height + otherImage.size.height + padding + bottom)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        originImage.draw(in: CGRect(x: 0, y: 0, width: originImage.size.width, height: originImage.size.height))
        otherImage.draw(in: CGRect(x: 0, y: originImage.size.height + padding, width: originImage.size.width, height: otherImage.size.height))
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    // 保存图片到相册
    static func saveImageToAblum(image: UIImage) {
        //Selector(("image:didFinishSavingWithError:contextInfo:")) --  未写回调不知是否保存成功
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
    func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
           print("保存失败")
        } else {
           print("保存成功")
        }
    }
    
    // 加水印
    static func addTextToImage(image: UIImage, with text: String, ratio: CGFloat = 0.1) -> UIImage?{
        // print(image.size)
        
        let width = image.size.width
        let height = image.size.height
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
        
        let font = UIFont.systemFont(ofSize: (imageSize.width * 45) / 1656.0)
        let dic = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.red] as [NSAttributedStringKey: Any]
        let rect = text.sizeWithAttributes(text: (text as NSString), with: dic, and: CGSize(width: imageSize.width - 20, height: CGFloat(MAXFLOAT)))
        
        UIGraphicsBeginImageContext(imageSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let location = CGRect(origin: CGPoint(x: 10, y: imageSize.height-20-rect.size.height), size: rect.size)
        
        //  let d = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.red] as [NSAttributedStringKey: Any]
        (text as NSString).draw(in: location, withAttributes: dic)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let sm = newImage, let newData = UIImageJPEGRepresentation(sm, ratio) {
            return UIImage(data: newData)
        }
        
        return nil
    }
}
