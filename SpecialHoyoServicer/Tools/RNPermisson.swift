//
//  RNPermisson.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2018/1/3.
//  Copyright © 2018年 roni. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import AssetsLibrary

struct RNPermission {
    //MARK: ----获取相册权限
    static func authorizePhotoWith(comletion:@escaping (Bool)->Void ){
        let granted = PHPhotoLibrary.authorizationStatus()
        switch granted {
        case PHAuthorizationStatus.authorized:
            comletion(true)
        case PHAuthorizationStatus.denied,PHAuthorizationStatus.restricted:
            comletion(false)
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                comletion(status == PHAuthorizationStatus.authorized ? true:false)
            })
        }
        
    }
    
    //MARK: ---相机权限
    static func authorizeCameraWith(comletion:@escaping (Bool)->Void ){
        let granted = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        
        switch granted {
        case AVAuthorizationStatus.authorized:
            comletion(true)
            break;
        case AVAuthorizationStatus.denied:
            comletion(false)
            break;
        case AVAuthorizationStatus.restricted:
            comletion(false)
            break;
        case AVAuthorizationStatus.notDetermined:
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) in
                comletion(granted)
            })
        }
    }
    
    //MARK:跳转到APP系统设置权限界面
    static func jumpToSystemPrivacySetting(){
        let appSetting = URL(string:UIApplicationOpenSettingsURLString)
        
        if appSetting != nil{
            if #available(iOS 10, *) {
                UIApplication.shared.open(appSetting!, options: [:], completionHandler: nil)
            }
            else{
                UIApplication.shared.openURL(appSetting!)
            }
        }
    }
}
