//
//  RNIdentityViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/3.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
//import Fusuma
import Kingfisher
import BSImagePicker
import Photos
import TZImagePickerController

class RNIdentityViewController: RNBaseInputViewController {
    
    @IBOutlet weak var sigalImageView: UIImageView!
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var identifierFrontImageView: UIImageView!
    @IBOutlet weak var identifierReverseImageView: UIImageView!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var scrollViewButtomSpace: NSLayoutConstraint!
    
    @IBAction func confirmAction(_ sender: UIButton) {
        // 确定
        uploadData()
    }
    
    var isPersonal = false
    
    lazy var paramters: [String: Any] = {
        return [String: Any]()
    }()
    var frontImage: UIImage? = nil
    var behindImage: UIImage? = nil
    var currentImageIndex = -1 // 0: 证明, 1: 反面
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 20.0
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        
        var title = "注册"
        if isPersonal {
            title = "实名认证"
        }
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: title, target: self, action: #selector(dismissFromVC))]
        
        if !isPersonal {
            navigationItem.rightBarButtonItem = UIBarButtonItem.createRightBarItemOnlyTitle("跳过", target: self, action: #selector(skipAction))
        }
        
        
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(tapFrontAction(sender:)))
        identifierFrontImageView.addGestureRecognizer(tap01)
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(tapReverseAction(sender:)))
        identifierReverseImageView.addGestureRecognizer(tap02)
        
        
        if isPersonal {
            getAuthInfo()
        }else{
            sigalImageView.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: - event reponse

extension RNIdentityViewController {
    
    @objc func tapFrontAction(sender: UITapGestureRecognizer) {
        
        // 正面事件
        currentImageIndex = 0
        
        pickImage(for: currentImageIndex)
        //        let imp = RNImagePicker(viewController: self)
        //        imp.fusuma.delegate = self as FusumaDelegate
        //        self.present(imp.fusuma, animated: true, completion: nil)
    }
    
    @objc func tapReverseAction(sender: UITapGestureRecognizer) {
        
        // 反面事件
        currentImageIndex = 1
        pickImage(for: currentImageIndex)
        
        //        let imp = RNImagePicker(viewController: self)
        //        imp.fusuma.delegate = self as FusumaDelegate
        //        self.present(imp.fusuma, animated: true, completion: nil)
    }
    
    
    @objc func dismissFromVC() {
        
        if isPersonal {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @objc func skipAction() {
        globalAppDelegate.showMainViewController()
    }
    
    func pickImage(for tag: Int) {
        
//        let imagePickerVC = BSImagePickerViewController()
//        imagePickerVC.maxNumberOfSelections = 1
//        imagePickerVC.takePhotos = true
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
//
//        bs_presentImagePickerController(imagePickerVC, animated: true, select: { (_) in
//            // 选择
//        }, deselect: { (_) in
//            // 取消选择
//        }, cancel: { (_) in
//            // 取消
//        }, finish: { (assets) in
//            self.getImageForPHAsset(with: assets, and: tag)
//        }, completion: {
//
//        })
        
         let imagePickerVC = TZImagePickerController()
         imagePickerVC.maxImagesCount = 1
         imagePickerVC.allowPickingOriginalPhoto = false
         imagePickerVC.didFinishPickingPhotosHandle = { (photos, assets, isSelectOriginalPhoto) in
            guard let photos = photos else {
                return
            }
            if let im = photos.first {
                DispatchQueue.main.async {
                    switch tag {
                    case 0:
                        self.frontImage = im
                        self.identifierFrontImageView.image = im
                    case 1:
                        self.behindImage = im
                        self.identifierReverseImageView.image = im
                    default:
                        break
                    }
                }
            }
            
        }
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    func getImageForPHAsset(with assets: [PHAsset], and tag: Int) {
        
        guard assets.count > 0 else {
            return
        }
        RNHud().showHud(nil)
        
        let imageManager = PHImageManager()
        let imageOption = PHImageRequestOptions()
        imageOption.isSynchronous = true
        imageOption.isNetworkAccessAllowed = true // 允许打开网络获取 icloud 图片
        
        let group = DispatchGroup()
        if let item  = assets.last {
            let queue = DispatchQueue(label: "IdentityQueue", qos: .default, attributes: .concurrent)
            group.enter()
            queue.async(group: group, execute: {
                _ = imageManager.requestImage(for: item, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageOption, resultHandler: { (image, dic) in
                    
                    if let im = image {
                        DispatchQueue.main.async {
                            switch tag {
                            case 0:
                                self.frontImage = im
                                self.identifierFrontImageView.image = im
                            case 1:
                                self.behindImage = im
                                self.identifierReverseImageView.image = im
                            default:
                                break
                            }
                        }
                    }
                    
                })
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            RNHud().hiddenHub()
        }
    }
    
}

//MARK: - custom methods

extension RNIdentityViewController {
    
    func checkparam() -> Bool {
        
        guard let indentifier = identifierTextField.text, indentifier != "" else{
            RNNoticeAlert.showError("提示", body: "身份证号不能为空")
            return false
        }
        
        guard let name = nameTextField.text, name != "" else{
            RNNoticeAlert.showError("提示", body: "姓名不能为空")
            return false
        }
        
        guard let _ = frontImage else {
            RNNoticeAlert.showError("提示", body: "请上传身份证正面图")
            return false
        }
        guard let _ = behindImage else {
            RNNoticeAlert.showError("提示", body: "请上传身份证反面图")
            return false
        }
        
        paramters["cardid"] = indentifier
        paramters["name"] = name
        
        guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
            RNNoticeAlert.showError("提示", body: "未获取到 userToken")
            return false
        }
        
        paramters["usertoken"] = token
        
        return true
    }
    
    // 获取数据
    func getAuthInfo() {
        
        RNHud().showHud(nil)
        UserServicer.getAuthinfo([String: Any](), successClourue: { (state, model) in
            RNHud().hiddenHub()
            
            switch state {
            case 1:
                // 暂未提交不做任何事情
                break
            case 2:
                // 正在审核
                self.showInfo(model: model)
                self.waitOrShow(des: "log_checking")
                break
            case 3:
                // 已通过审核
                self.showInfo(model: model)
                self.waitOrShow(des: "log_checkSuccess")
                
                break
            case 4:
                
                self.sigalImageView.image = UIImage(named: "log_checkFail")
                self.showInfo(model: model)
                let alert = UIAlertController(title: "提示", message: "审核失败, 请检查身份信息再重交提交审核", preferredStyle: .alert)
                let deletaButton = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                    //
                })
                alert.addAction(deletaButton)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.present(alert, animated: true, completion: nil)
                }
                
                break
            default:
                break
            }
        }) { (msg, code) in
            RNHud().hiddenHub()
            self.waitOrShow(des: "获取认证信息失败...")
            RNNoticeAlert.showError("提示", body:  msg)
        }
    }
    
    func showInfo(model: AuthInfoModel?) {
        
        guard let m = model else {
            return
        }
        
        identifierTextField.text = m.cardId
        nameTextField.text = m.name
        
        
        if let frontImageString = m.imageFront, let url = URL(string: frontImageString) {
            identifierFrontImageView.kf.setImage(with: url, placeholder: UIImage(named: "log_frontSide"), options: nil, progressBlock: nil, completionHandler: nil)
            frontImage = identifierFrontImageView.image
        }
        
        if let behindImageString = m.imageBehind, let url = URL(string: behindImageString) {
            identifierReverseImageView.kf.setImage(with: url, placeholder: UIImage(named: "log_reverseSide"), options: nil, progressBlock: nil, completionHandler: nil)
            behindImage = identifierReverseImageView.image
        }
        
    }
    
    func waitOrShow(des: String) {
        
        sigalImageView.image = UIImage(named: des)
        
        identifierTextField.isEnabled = false
        nameTextField.isEnabled = false
        
        identifierFrontImageView.isUserInteractionEnabled = false
        identifierReverseImageView.isUserInteractionEnabled = false
        
        buttonView.isHidden = true
        scrollViewButtomSpace.constant = 0
        //        confirmButton.backgroundColor = .gray
        //        confirmButton.isEnabled = false
        //        confirmButton.setTitle(des, for: .normal)
    }
    
    // 上传数据
    func uploadData() {
        
        if !checkparam() {
            return
        }
        
        RNHud().showHud(nil)
        UserServicer.uploadAuthinfo(paramters, frontImage: frontImage!, behindImage: behindImage!, successClourue: { (state) in
            RNHud().hiddenHub()
            
            let alert = UIAlertController(title: "提示", message: "上传资料成功,等待后台审核...", preferredStyle: .alert)
            let deletaButton = UIAlertAction(title: "确定", style: .default, handler: { (_) in
                
                //                if self.isPersonal {
                //                    self.dismiss(animated: true, completion: nil)
                //                }else{
                globalAppDelegate.showMainViewController()
                // }
                
            })
            alert.addAction(deletaButton)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.present(alert, animated: true, completion: nil)
            }
            
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
}
//extension RNIdentityViewController: FusumaDelegate{
//    
//    func fusumaImageSelected(_ image: UIImage, source: FusumaMode){
//        
//        switch currentImageIndex {
//        case 0:
//            frontImage = image
//            identifierFrontImageView.image = image
//        case 1:
//            behindImage = image
//            identifierReverseImageView.image = image
//        default:
//            break
//        }
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

