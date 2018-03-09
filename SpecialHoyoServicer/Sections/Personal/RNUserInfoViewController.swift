//
//  RNUserInfoViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/13.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Kingfisher
//import Fusuma
import BSImagePicker
import Photos
import TZImagePickerController

class RNUserInfoViewController: ElasticModalViewController {
    
    
    // 关闭下拉dismiss 动画
    override var dismissByForegroundDrag: Bool{
        return false
    }
    
    fileprivate var myNav: RNCustomNavBar = {
        
        let nav = RNCustomNavBar(frame:  CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64), leftIcon: "nav_back", leftTitle: "个人中心", rightIcon:  nil, rightTitle: nil)
        nav.createLeftView(target: self as AnyObject, action: #selector(popToLastVC))
        return nav
    }()
    
    var tableView: UITableView!
    
    lazy var titles: [[String]] = {
        
        let arr01 = ["头像"]
        let arr02 = ["姓名", "手机号", "评分"]
        let arr03 = ["性别", "地区"]
        
        return [arr01, arr02, arr03]
    }()
    
    lazy var contents: [[String]] = {
        
        let userInfo = realmQueryResults(Model: UserModel.self).first
        
        guard let user = userInfo else {
            
            return [[String]]()
        }
        
        let headImageUrl = user.headImageUrl ?? ""
        let name = user.realName ?? "佚名"
        let mobile = user.mobile ?? "未知"
        let score = user.score ?? "0"
        let sex = user.sex ?? "2"
        let address = (user.province ?? "") + " " + (user.city ?? "")
        
        return [[headImageUrl], [name, mobile, score], [sex, address]]
    }()
    
    var headImageView: UIImageView?
    var sexLabel: UILabel?
    var addressLabel: UILabel?
    var currentSex: String?
    var address: String?
    
    var paramter = [String: Any]() //  参数
    var headImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "个人中心", target: self, action: #selector(popToLastVC))]
        
        setupUI()
        
        if contents.count == 0 {
            
            UserServicer.getCurrentUser(successClourue: { (user) in
                
                let headImageUrl = user.headImageUrl ?? ""
                let name = user.realName ?? "佚名"
                let mobile = user.mobile ?? "未知"
                let score = user.score ?? "0"
                let sex = user.sex ?? "2"
                let address = (user.province ?? "") + " " + (user.city ?? "")
                
                self.contents =  [[headImageUrl], [name, mobile, score], [sex, address]]
                
                self.tableView.reloadData()
                
            }, failureClousure: { (msg, code) in
                RNNoticeAlert.showError("提示", body: msg)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: - custom methods
extension RNUserInfoViewController {
    
    func setupUI() {
        
        //  view.addSubview(myNav)
        
        // TO DO: - 封装成模块
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .grouped)
        tableView.separatorStyle = .singleLine
        // tableView.separatorColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "RNInfoHeadCell", bundle: nil), forCellReuseIdentifier: "RNInfoHeadCell")
        tableView.register(UINib.init(nibName: "RNInfoListCell", bundle: nil), forCellReuseIdentifier: "RNInfoListCell")
        
        view.addSubview(tableView)
    }
    
    
    @objc func popToLastVC() {
        
        self.dismiss(animated: true, completion: nil)
        // self.dismissFromTop(view)
        // self.dismissFromLeft(view)
    }
    
    func selectAreaInfo() {
        
        let jsonPath = Bundle.main.path(forResource: "china_cities_three_level", ofType: "json")
        let jsonData = (try! Data(contentsOf: URL(fileURLWithPath: jsonPath!))) as Data
        let tmpObject: AnyObject?
        do{
            tmpObject = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        }
        let adressArray = tmpObject as! NSMutableArray
        var provinceArr = [String]()
        for item in adressArray {
            let str = (item as AnyObject)["name"] as! String
            provinceArr.append(str)
        }
        let selectAreaVC = RNSelectAreaTableViewController(index: 0, data: provinceArr, location: "", selected:"")
        selectAreaVC.delegate = self
        
        let nav = RNBaseNavigationController(rootViewController: selectAreaVC)
        present(nav, animated: true, completion: nil)
    }
    
    
    
    
    func uploadData(){
        
        guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
            RNNoticeAlert.showError("提示", body: "未获取到 userToken")
            return
        }
        
        paramter["usertoken"] = token
        RNHud().showHud(nil)
        UserServicer.updateUserInfo(paramter, headImage: headImage, successClourue: { [weak self] in
            RNHud().hiddenHub()
            
            self?.getCurrentuserInfo()
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    
    // 获取个人信息
    func getCurrentuserInfo() {
        
        UserServicer.getCurrentUser(successClourue: { (user) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PersonalInfoUpdate), object: nil) // 个人信息更新通知发出通知
            
        }) { (msg, code) in
            RNNoticeAlert.showError("提示", body: "获取个人信息失败")
            print("错误提示: \(msg) + \(code)")
        }
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
                        self.headImageView?.image = im
                        // 上传头像
                        self.headImage = im
                        self.uploadData()
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
        
        if let item  = assets.last {
            _ = imageManager.requestImage(for: item, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageOption, resultHandler: { (image, dic) in
                
                if let im = image {
                    DispatchQueue.main.async {
                        
                        switch tag {
                        case 0:
                            self.headImageView?.image = im
                            // 上传头像
                            self.headImage = im
                            self.uploadData()
                        default:
                            break
                        }
                    }
                }
                
            })
        }
        
        RNHud().hiddenHub()
    }
    
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension RNUserInfoViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "RNInfoHeadCell", for: indexPath)
            
            if let cell = cell as? RNInfoHeadCell {
                
                cell.titleLabel.text = titles[indexPath.section][indexPath.row]
                
                var urlString = contents[indexPath.section][indexPath.row]
                if urlString.contains("http") == false {
                    urlString = BASEURL + urlString
                }
                let url = URL(string: urlString)
                cell.headImageView.kf.setImage(with: url, placeholder: UIImage(named: "person_defaultHeadImage"), options: nil, progressBlock: nil, completionHandler: nil)
                
                self.headImageView = cell.headImageView
            }
            
            
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "RNInfoListCell", for: indexPath)
            
            if let cell = cell as? RNInfoListCell {
                
                if indexPath.section == 2 {
                    cell.accessoryType = .disclosureIndicator
                }else{
                    cell.accessoryType = .none
                }
                
                cell.titleLabel.text = titles[indexPath.section][indexPath.row]
                
                if indexPath.section == 2 && indexPath.row == 0 {
                    
                    let s = contents[indexPath.section][indexPath.row]
                    
                    self.sexLabel = cell.contentLabel
                    
                    switch s {
                    case "0":
                        cell.contentLabel.text = "女"
                    case "1":
                        cell.contentLabel.text = "男"
                    default:
                        cell.contentLabel.text = "保密"
                    }
                }else if indexPath.section == 2 && indexPath.row == 1 {
                    cell.contentLabel.text = contents[indexPath.section][indexPath.row]
                    
                    self.addressLabel = cell.contentLabel
                    
                }else{
                    cell.contentLabel.text = contents[indexPath.section][indexPath.row]
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                //                let imp = RNImagePicker(viewController: self)
                //                imp.fusuma.delegate = self
                //               // imp.delegate = self as RNImagePickerProtocol
                //                self.present(imp.fusuma, animated: true, completion: nil)
                
                pickImage(for: 0)
                break
            default:
                break
            }
            
        }else if indexPath.section == 2{
            
            switch indexPath.row {
            case 0:
                let sexVC = RNSexViewController(sex: sexLabel?.text, callBack: { [weak self](sex) in
                    // 更新 UI
                    self?.currentSex = sex
                    self?.sexLabel?.text = sex
                    
                    var sexParam = "0"
                    switch sex {
                    case "男":
                        sexParam = "1" //男
                    case "女":
                        sexParam = "0" //女
                    case "保密":
                        sexParam = "2" //保密
                    default:
                        break
                    }
                    
                    self?.paramter["sex"] = sexParam
                    self?.uploadData()
                    
                })
                //                sexVC.modalTransition.edge = .right
                //                present(sexVC, animated: true, completion: nil)
                self.navigationController?.pushViewController(sexVC, animated: true)
                break
            case 1:
                selectAreaInfo()
                break
            default:
                break
            }
            
        }else{
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -124 {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

////MARK: - RNImagePickerProtocol
//extension RNUserInfoViewController:  FusumaDelegate /*RNImagePickerProtocol*/{
//    
////    func imageSelected(_ image: UIImage, source: FusumaMode) {
////        // -- 上传头像 --- 刷新界面
////        self.headImageView?.image = image
////        
////    }
////    
////    func multipleImagesSelected(_ images: [UIImage], source: FusumaMode) {
////        // ---- 多选
////    }
////    
////    func videoCompleted(withFileURL fileURL: URL) {
////        //
////    }
////    func cameraRollUnauthoried() {
////        RNNoticeAlert.showError("提示", body: "本应用未获得相机/相册权限")
////    }
//    
//    func fusumaImageSelected(_ image: UIImage, source: FusumaMode){
//        
//        self.headImageView?.image = image
//        
//        // 上传头像
//        headImage = image
//        uploadData()
//    }
//    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode){
//        
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

// MARK: - RNSelectAreaTableViewControllerDelegate

extension RNUserInfoViewController: RNSelectAreaTableViewControllerDelegate {
    
    func reloadInstallInfoUI(_ loaction: String) {
        self.address = loaction // 更新区域信息
        self.addressLabel?.text = loaction
        
        let arr = loaction.components(separatedBy: " ")
        paramter["province"] =  arr.first
        paramter["city"] = arr.last
        
        uploadData()
    }
}

