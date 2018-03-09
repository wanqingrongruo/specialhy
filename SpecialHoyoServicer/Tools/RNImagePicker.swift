//
//  RNImagePicker.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/17.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit
//import Fusuma

@objc
protocol RNImagePickerProtocol{
//    @objc optional func imageSelected(_ image: UIImage, source: FusumaMode)
//    @objc optional func multipleImagesSelected(_ images: [UIImage], source: FusumaMode)
//    @objc optional func videoCompleted(withFileURL fileURL: URL)
//    @objc optional func cameraRollUnauthoried()
}

extension RNImagePickerProtocol {
    
//    func imageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {}
//    func dismissedWithImage(_ image: UIImage, source: FusumaMode) {}
//    func closed() {}
//    func willClosed() {}

}

class RNImagePicker{
    
//    var fusuma: FusumaViewController
//    public weak var delegate: RNImagePickerProtocol? = nil
//
//    init(viewController: UIViewController, hasVideo: Bool = false, allowMultipleSelection: Bool = false) {
//
//        self.fusuma = FusumaViewController()
//        self.fusuma.hasVideo = hasVideo
//        self.fusuma.allowMultipleSelection = allowMultipleSelection
//      //  self.fusuma.delegate = self as FusumaDelegate // Q: 在FusumaViewController中调用时发现 delegate = nil,, 但是一步一步断点过去就有值
//
//      //  viewController.present(self.fusuma, animated: true, completion: nil)
//
//    }
}


//extension RNImagePicker: FusumaDelegate {
//
//    func fusumaImageSelected(_ image: UIImage, source: FusumaMode){
//
//        delegate?.imageSelected?(image, source: source)
//    }
//    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode){
//
//        delegate?.multipleImagesSelected?(images, source: source)
//
//    }
//    func fusumaVideoCompleted(withFileURL fileURL: URL){
//
//        delegate?.videoCompleted?(withFileURL: fileURL)
//    }
//    func fusumaCameraRollUnauthorized(){
//
//        delegate?.cameraRollUnauthoried?()
//    }
//
//    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
//        delegate?.imageSelected(image, source: source, metaData: metaData)
//    }
//
//}

