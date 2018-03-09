//
//  RNQRGeneration.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/28.
//  Copyright © 2017年 roni. All rights reserved.
//

// https://github.com/EyreFree/EFQRCode/blob/master/README_CN.md

import Foundation
import EFQRCode

struct RNQRGeneration {

    
    ///  二维码生成
    ///
    /// - Parameters:
    ///   - content: 内容
    ///   - size: 尺寸
    ///   - backgroundColor: <#backgroundColor description#>
    ///   - foregroundColor: <#foregroundColor description#>
    ///   - watermark: <#watermark description#>
    /// - Returns: <#return value description#>
    static func qrGenerate(content: String, size: CGSize?, backgroundColor: UIColor = UIColor.white, foregroundColor: UIColor = UIColor.black, icon: UIImage?, iconSize: EFIntSize =  EFIntSize(width: 60, height: 60),watermark: UIImage?) -> (image: UIImage?, des: String){
        
        var mySize: EFIntSize = EFIntSize(width: 300, height: 300)
        if let s = size {
            mySize = EFIntSize(width: Int(s.width), height: Int(s.height))
        }
        
        let generator = EFQRCodeGenerator(content: content, size: mySize)
        generator.setInputCorrectionLevel(inputCorrectionLevel: .h)
        generator.setMode(mode: EFQRCodeMode.none)
        generator.setMagnification(magnification: nil)
        generator.setColors(backgroundColor: CIColor(color: backgroundColor), foregroundColor: CIColor(color: foregroundColor))
        
        generator.setIcon(icon: UIImage2CGimage(icon), size: iconSize)
        generator.setWatermark(watermark: UIImage2CGimage(watermark), mode: EFWatermarkMode.scaleAspectFill)
        generator.setForegroundPointOffset(foregroundPointOffset: 0)
        generator.setAllowTransparent(allowTransparent: true)
        generator.setBinarizationThreshold(binarizationThreshold: 0.5)
        generator.setPointShape(pointShape: EFPointShape.square)
        
        let result = generator.generate()
        
        if let res = result {
            
            let image = UIImage(cgImage: res)
            
            return (image, "二维码生成成功")
        }
        
        return (nil, "二维码生成失败")
    }
}

extension RNQRGeneration {
    
   static func UIImage2CGimage(_ image: UIImage?) -> CGImage? {
        if let tryImage = image, let tryCIImage = CIImage(image: tryImage) {
            return CIContext().createCGImage(tryCIImage, from: tryCIImage.extent)
        }
        return nil
    }

}
