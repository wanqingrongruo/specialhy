//
//  RNReceiptViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos


class RNReceiptViewController: UIViewController {
    
    private var crmId: String
    private var oznerId: String
    init(_ crmId: String, oznerId: String) {
        self.crmId = crmId
        self.oznerId = oznerId
        
        super.init(nibName: "RNReceiptViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var hoyoLabel: UILabel!
    @IBOutlet weak var oznerLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBAction func comfirmAction(_ sender: UIButton) {
        guard let image = receiptImage else {
            RNNoticeAlert.showError("提示", body: "请先选择凭票图片")
            return
        }
        
        uploadImage(with: image)
    }
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBAction func removeImageAction(_ sender: UIButton) {
        receiptImage = nil
        DispatchQueue.main.async {
            self.receiptImageView.contentMode = .center
            self.receiptImageView.image = UIImage(named: "newFee_receipt")
        }
    }
    
    private var hoyoId: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.hoyoLabel.text = String(format: "浩优编号: %@", self.hoyoId)
            }
        }
    }
    private var documentNo: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.oznerLabel.text = String(format: "浩泽编号: %@", self.documentNo)
            }
        }
    }
    
    private var receiptImage: UIImage? = nil {
        didSet {
            DispatchQueue.main.async {
                self.receiptImageView.contentMode = .scaleToFill
                self.receiptImageView.image = self.receiptImage
                
                if self.receiptImage == nil {
                    self.crossBtn.isHidden = true
                }
                else {
                    self.crossBtn.isHidden = false
                }
            }
        }
    }
    
    var isWaitPay = false //  是否是从待支付界面进入
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BASEBACKGROUNDCOLOR
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "上传凭票", target: self, action: #selector(popBack))]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPicture(gesture:)))
        receiptImageView.addGestureRecognizer(tap)
        
        self.hoyoId = crmId
        self.documentNo = oznerId
        
        self.confirmBtn.layer.masksToBounds = true
        self.confirmBtn.layer.cornerRadius = 5.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// event response
extension RNReceiptViewController {
    
    @objc func popBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func selectPicture(gesture: UITapGestureRecognizer) {
        let imagePickerVC = BSImagePickerViewController()
        imagePickerVC.maxNumberOfSelections = 1
        imagePickerVC.takePhotos = true
        
        self.bs_presentImagePickerController(imagePickerVC, animated: true, select: { (_) in
            // 选择
        }, deselect: { (_) in
            // 取消选择
        }, cancel: { (_) in
            // 取消
        }, finish: { (assets) in
            self.getImageForPHAsset(with: assets)
            
        }, completion: {
            
        })
    }
}

// custom methods
extension RNReceiptViewController {
    
    private func uploadImage(with image: UIImage) {
        guard let token = UserDefaults.standard.object(forKey: UserDefaultsUserTokenKey) else{
            RNNoticeAlert.showError("提示", body: "未获取到 userToken")
            return
        }
        RNHud().showHud(nil)
        let parameter = ["CRMID": crmId, "PayModel": PayWay.Pos.rawValue, "usertoken": token]
        OrderServicer.uploadPosImage(parameter, imageData: image, successClourue: { (_) in
            RNHud().hiddenHub()
            self.showTip()
        }) { (msg, code) in
            RNHud().hiddenHub()
            RNNoticeAlert.showError("提示", body: msg)
        }
    }
    
    func showTip() {
        let alert = UIAlertController(title: "提示", message: "Pos机支付凭票上传成功", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "确定", style: .cancel) { [weak self](_) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaySuccessNotification), object: nil) // 发送通知
            if let s = self, s.isWaitPay {
                if let vcs = s.navigationController?.viewControllers, let vc = vcs.first, vc.isKind(of: RNWaitPayViewController.self) == true {
                    s.navigationController?.popToViewController(vc, animated: true)
                }
            }else{
                self?.dismiss(animated: true, completion: nil) // 跳转控制器
            }
        }
        alert.addAction(cancelButton)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getImageForPHAsset(with assets: [PHAsset]) {
        guard assets.count > 0 else {
            return
        }
        RNHud().showHud(nil)
        let imageManager = PHImageManager()
        let imageOption = PHImageRequestOptions()
        imageOption.isSynchronous = true
        imageOption.isNetworkAccessAllowed = true // 允许打开网络获取 icloud 图片
        
        let group = DispatchGroup()
        if let item = assets.first {
            let queue = DispatchQueue(label: "firstItem", qos: .default, attributes: .concurrent)
            group.enter()
            queue.async(group: group, execute: {
                _ = imageManager.requestImage(for: item, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: imageOption, resultHandler: { (image, dic) in
                    self.receiptImage = image
                    group.leave()
                })
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            RNHud().hiddenHub()
        }
        
    }
}
