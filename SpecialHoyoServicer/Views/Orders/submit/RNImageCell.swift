//
//  RNImageCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/10.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
//import Fusuma
import BSImagePicker
import Photos
import TZImagePickerController
import CoreLocation

protocol RNImageCellProtocol {
    func getImages(images arr: [UIImage])
}

class RNImageCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView01: UIImageView! //100
    @IBOutlet weak var imageView02: UIImageView! //101
    @IBOutlet weak var imageView03: UIImageView! //102
    @IBOutlet weak var imageView04: UIImageView! //103
    
    var index: IndexPath?
    var vc: UIViewController?
    var currentTag: Int = 100
    var finishedTag: Int = 100
    lazy var imageArray:[UIImage] = {
        return [UIImage]()
    }()
    
    var delegate: RNImageCellProtocol?
    
    var locationAddress: String = ""
    lazy var selectedAssest = {
        return [TZAssetModel]()
    }()
    
    lazy var imagePickVc: UIImagePickerController  = {
        let imagePickVC = UIImagePickerController()
        imagePickVC.delegate = self
        // 改变导航
        imagePickVC.navigationBar.tintColor = self.vc?.navigationController?.navigationBar.barTintColor
        let tzBarItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [TZImagePickerController.self])
        let barItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIImagePickerController.self])
        let titleTextAttributes = tzBarItem.titleTextAttributes(for: .normal)
        var dic = [NSAttributedStringKey: Any]()
        
        if let attrs = titleTextAttributes {
            for (key, value) in attrs {
                let k = NSAttributedStringKey.init(key)
                dic[k] = value
            }
            barItem.setTitleTextAttributes(dic, for: .normal)
        }
       
        return imagePickVC
    }()
    var location: CLLocation? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView01.addGestureRecognizer(tap01)
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView02.addGestureRecognizer(tap02)
        let tap03 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView03.addGestureRecognizer(tap03)
        let tap04 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView04.addGestureRecognizer(tap04)
        
        
        let press01 = UILongPressGestureRecognizer(target: self, action: #selector(browser(tap:)))
        imageView01.addGestureRecognizer(press01)
        let press02 = UILongPressGestureRecognizer(target: self, action: #selector(browser(tap:)))
        imageView02.addGestureRecognizer(press02)
        let press03 = UILongPressGestureRecognizer(target: self, action: #selector(browser(tap:)))
        imageView03.addGestureRecognizer(press03)
        let press04 = UILongPressGestureRecognizer(target: self, action: #selector(browser(tap:)))
        imageView04.addGestureRecognizer(press04)
        
        globalAppDelegate.locationManager?.detialAddress = { ad in
            self.locationAddress = ad
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func configCell(title: String, indexPath: IndexPath, viewController: UIViewController){
        
        self.index = indexPath
        self.vc = viewController
    }
    
    @objc func imagePick(tap: UITapGestureRecognizer){
        
        currentTag = (tap.view as! UIImageView).tag
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takeButton = UIAlertAction(title: "拍照", style: .default) { [weak self](_) in
            self?.takePhoto()
        }
        let pictureButton = UIAlertAction(title: "去相册选择", style: .default) { [weak self](_) in
            self?.pushTZImagePickerController(tap: tap)
        }
        let cancelButton = UIAlertAction(title: "取消", style: .cancel) { (_) in}
        actionSheet.addAction(takeButton)
        actionSheet.addAction(pictureButton)
        actionSheet.addAction(cancelButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.vc?.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func takePhoto() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied {
            alertShow()
        }
        else if authStatus == .notDetermined {
            takePhoto()
        }
        else if TZImageManager.authorizationStatus() == 2 {
            alertShow()
        }
        else if TZImageManager.authorizationStatus() == 0 {
            TZImageManager.default().requestAuthorization(completion: { [weak self] in
                self?.takePhoto()
            })
        }
        else {
            self.pushImagePickerController()
        }
    }
    
    func alertShow(title: String = "无法使用相机", msg: String = "请在iPhone的 '设置-隐私-相机' 中允许访问相机", cancel: String = "取消", other: String = "确定") {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: other, style: .default) {(_) in}
        let cancelButton = UIAlertAction(title: cancel, style: .cancel) { (_) in}
        alert.addAction(confirmButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.vc?.present(alert, animated: true, completion: nil)
        }
    }
    
    func pushTZImagePickerController(tap: UITapGestureRecognizer){
        
      //  currentTag = (tap.view as! UIImageView).tag
        
        //        let imp = RNImagePicker(viewController: vc!)
        //        imp.fusuma.delegate = self
        //        vc?.present(imp.fusuma, animated: true, completion: nil)
        // let imagePickerVC = BSImagePickerViewController()
        let imagePickerVC = TZImagePickerController()
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowTakePicture = false
        if currentTag - 100 < imageArray.count {
            //imagePickerVC.maxNumberOfSelections = 1
            imagePickerVC.maxImagesCount = 1
        }else{
            //imagePickerVC.maxNumberOfSelections = 104 - finishedTag
            imagePickerVC.maxImagesCount = 104 - finishedTag
        }
        //  imagePickerVC.maxImagesCount = 4
        imagePickerVC.allowPickingOriginalPhoto = false
        //   imagePickerVC.selectedAssets = NSMutableArray(array: self.selectedAssest)
        //   imagePickerVC.selectedAssets =
        
        // imagePickerVC.takePhotos = true
        
        //        imagePickerVC.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
        //            switch (verticalSize, horizontalSize) {
        //            case (.compact, .regular): // iPhone5-6 portrait
        //                return 2
        //            case (.compact, .compact): // iPhone5-6 landscape
        //                return 2
        //            case (.regular, .regular): // iPad portrait/landscape
        //                return 3
        //            default:
        //                return 2
        //            }
        //        }
        
        //        vc?.bs_presentImagePickerController(imagePickerVC, animated: true, select: { (_) in
        //            // 选择
        //        }, deselect: { (_) in
        //            // 取消选择
        //        }, cancel: { (_) in
        //            // 取消
        //        }, finish: { (assets) in
        //
        ////            let group = DispatchGroup()
        ////            let queue = DispatchQueue(label: "finished")
        ////            queue.async(group: group, execute: {
        //                 self.getImageForPHAsset(with: assets)
        //          //  })
        //
        //          //  group.notify(queue: DispatchQueue.main, execute: {
        //
        //
        //         //   })
        //
        //        }, completion: {
        //
        //        })
        
        imagePickerVC.didFinishPickingPhotosHandle = { (photos, assets, isSelectOriginalPhoto) in
            
            //            self.selectedAssest = [TZAssetModel]()
            //            if let assets = assets {
            //                for item in assets {
            //                    let model = TZAssetModel(asset: item, type: TZImageManager().getAssetType(item))
            //                    model?.isSelected = true
            //                    if let m = model {
            //                         self.selectedAssest.append(m)
            //                    }
            //                }
            //            }
            
            guard let photos = photos else {
                return
            }
            var tmpArrr = [UIImage]()
            for im in photos {
                tmpArrr.append(im)
            }
            
            for (index, im) in tmpArrr.enumerated(){
                DispatchQueue.main.async {
                    let imageView = self.backView.viewWithTag(self.currentTag + index) as! UIImageView
                    imageView.isHidden = false
                    imageView.contentMode = .scaleToFill
                    imageView.image = im
                }
                
                if (self.currentTag + index - 100) < self.imageArray.count{
                    self.imageArray[self.currentTag + index - 100] = im
                }else{
                    self.imageArray.append(im)
                }
            }
            
            self.finishedTag = 100 + self.imageArray.count
            
            //  print("my Finished tag is \(self.finishedTag)")
            
            if self.finishedTag < 104 {
                let tag = self.finishedTag
                
                DispatchQueue.main.async {
                    let im = self.backView.viewWithTag(tag) as! UIImageView
                    im.isHidden = false
                    im.contentMode = .scaleToFill
                    im.image = UIImage(named: "order_addmore")
                }
            }
            self.delegate?.getImages(images: self.imageArray)
            //
            //            DispatchQueue.main.async {
            //                RNHud().hiddenHub()
            //            }
        }
        vc?.present(imagePickerVC, animated: true, completion: nil)
    }
    
    @objc func browser(tap: UILongPressGestureRecognizer) {
        
        guard let v = vc else {
            return
        }
        let t = (tap.view as! UIImageView).tag - 100
        guard imageArray.count > 0, t < imageArray.count else {
            return
        }
        
        currentTag = (tap.view as! UIImageView).tag
        
        let imageView = tap.view as! UIImageView
        let image = imageArray[currentTag-100] // 每次添加图片后自动+1,所以要-1
        let pictureBrowser = RNPictureBroswer(from: v, showView: imageView, originImage: image, currentIndex: currentTag-100)
        pictureBrowser.localImages = imageArray
        pictureBrowser.showBrowserForLocal()
    }
    
    func getImageForPHAsset(with assets: [PHAsset]) {
        
        guard assets.count > 0 else {
            return
        }
        RNHud().showHud(nil)
        let imageManager = PHImageManager()
        
        let imageOption = PHImageRequestOptions()
        imageOption.isSynchronous = false
        imageOption.isNetworkAccessAllowed = true // 允许打开网络获取 icloud 图片
        imageOption.deliveryMode = .opportunistic
        
        let group = DispatchGroup()
        var tmpArrr = [UIImage]()
        for (index, item) in assets.enumerated() {
            let queue = DispatchQueue(label: String(format: "picture%d", index), qos: .default, attributes: .concurrent)
            group.enter()
            queue.async(group: group, execute: {
                _ = imageManager.requestImage(for: item, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageOption, resultHandler: { (image, dic) in
                    
                    //                    print(item.location ?? "yyyyyyyyy")
                    //                    print(item.creationDate)
                    if let im = image {
                        let tmpDate = DateFormatter()
                        tmpDate.dateFormat = "yyyy/MM/dd hh:mm:ss"
                        let showText = tmpDate.string(from: Date()) + " " + self.locationAddress  // 时间+地点
                        var aimImage = im
                        if let newImage =  RNScreenShotManager.addTextToImage(image: im, with: showText) {
                            aimImage = newImage
                        }
                        
                        //                        if (self.currentTag + index - 100) < self.imageArray.count{
                        //                            self.imageArray[self.currentTag + index - 100] = aimImage
                        //                        }else{
                        //                            self.imageArray.append(aimImage)
                        //                        }
                        tmpArrr.append(aimImage)
                        group.leave()
                    }
                })
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            for (index, im) in tmpArrr.enumerated(){
                DispatchQueue.main.async {
                    let imageView = self.backView.viewWithTag(self.currentTag + index) as! UIImageView
                    imageView.isHidden = false
                    imageView.contentMode = .scaleToFill
                    imageView.image = im
                }
                
                if (self.currentTag + index - 100) < self.imageArray.count{
                    self.imageArray[self.currentTag + index - 100] = im
                }else{
                    self.imageArray.append(im)
                }
            }
            
            self.finishedTag = 100 + self.imageArray.count
            
            //  print("my Finished tag is \(self.finishedTag)")
            
            if self.finishedTag < 104 {
                let tag = self.finishedTag
                
                DispatchQueue.main.async {
                    let im = self.backView.viewWithTag(tag) as! UIImageView
                    im.isHidden = false
                    im.contentMode = .scaleToFill
                    im.image = UIImage(named: "order_addmore")
                }
            }
            self.delegate?.getImages(images: self.imageArray)
            
            DispatchQueue.main.async {
                RNHud().hiddenHub()
            }
            
        }
    }
    
    func showPhoto(image: UIImage) {
        let aimImage = addWaterMark(image: image)
        DispatchQueue.main.async {
            let imageView = self.backView.viewWithTag(self.currentTag) as! UIImageView
            imageView.isHidden = false
            imageView.contentMode = .scaleToFill
            imageView.image = aimImage
        }
        
        if (self.currentTag - 100) < self.imageArray.count{
            self.imageArray[self.currentTag - 100] = aimImage
        }else{
            self.imageArray.append(aimImage)
        }
        
        self.finishedTag = 100 + self.imageArray.count
        
        if self.finishedTag < 104 {
            DispatchQueue.main.async {
                let im = self.backView.viewWithTag(self.finishedTag) as! UIImageView
                im.isHidden = false
                im.contentMode = .scaleToFill
                im.image = UIImage(named: "order_addmore")
            }
        }
    }
    
    func addWaterMark(image: UIImage) -> UIImage { // 添加水印(时间地点)
        let tmpDate = DateFormatter()
        tmpDate.dateFormat = "yyyy/MM/dd hh:mm:ss"
        let showText = tmpDate.string(from: Date()) + " " + self.locationAddress  // 时间+地点
        var aimImage = image
        if let newImage =  RNScreenShotManager.addTextToImage(image: image, with: showText) {
            aimImage = newImage
        }
        return aimImage
    }
}

// ImagePickerController
extension RNImageCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate{
    func pushImagePickerController() {
        // 提前定位
        TZLocationManager().startLocation(successBlock: { [weak self](location, oldLocation) in
            self?.location = location
        }) { [weak self](error) in
            self?.location = nil
        }

        let sourceType = UIImagePickerControllerSourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePickVc.sourceType = sourceType
            imagePickVc.modalPresentationStyle = .currentContext
            self.vc?.present(imagePickVc, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let type = info["UIImagePickerControllerMediaType"] as? String
        if let type = type, type == "public.image" {
          //  let tzImagePickVc = TZImagePickerController(maxImagesCount: 1, delegate: self) --- 可以添加剪裁功能, 具体看库demo
           // RNHud().showHud(nil)
            let image = info["UIImagePickerControllerOriginalImage"] as? UIImage
            if let image = image { // 保存图片,获取 asset
                self.showPhoto(image: image)
//                TZImageManager.default().getCameraRollAlbum(false, allowPickingImage: true, completion: { (model) in
//                    if let model = model {
//                        TZImageManager.default().getAssetsFromFetchResult(model.result, allowPickingVideo: false, allowPickingImage: true, completion: { (models) in
//                            RNHud().hiddenHub()
//                            if let model = models?.first {
//                                self.showPhoto(image: image)
//                            }
//
//                        })
//                    }
//
//                })
//                TZImageManager.default().savePhoto(with: image, location: location ?? CLLocation(), completion: { (error) in
//                    guard error == nil else {
//                        RNHud().hiddenHub()
//                        print("保存图片到相册失败")
//                        return
//                    }
//
//                })
            }
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//extension RNImageCell: FusumaDelegate{
//
//    func fusumaImageSelected(_ image: UIImage, source: FusumaMode){
//
//        let imageView = backView.viewWithTag(currentTag) as! UIImageView
//        imageView.image = image
//
//
//        if (currentTag-100) < imageArray.count{
//            imageArray[currentTag-100] = image
//        }else{
//            imageArray.append(image)
//        }
//
//
//        if (currentTag + 1) < 104 {
//            currentTag += 1
//            let im = backView.viewWithTag(currentTag) as! UIImageView
//            im.isHidden = false
//            im.image = UIImage(named: "order_addmore")
//        }
//
//        delegate?.getImages(images: imageArray)
//    }
//    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode){
//
//    }
//    func fusumaVideoCompleted(withFileURL fileURL: URL){
//
//    }
//    func fusumaCameraRollUnauthorized(){
//
//    }
//
//}

