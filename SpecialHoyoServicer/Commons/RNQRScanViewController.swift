//
//  RNQRScanViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/1.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import swiftScan

class RNQRScanViewController: LBXScanViewController, ElasticMenuTransitionDelegate{

// MARK: - Elastic
    public var dragDownTransformType:ElasticTransitionBackgroundTransform = .subtle
    public var dragRightTransformType:ElasticTransitionBackgroundTransform = .translatePull
    
    lazy var modalTransition:ElasticTransition = {
        let transition = ElasticTransition()
        transition.edge = .bottom
        transition.sticky = true
        transition.panThreshold = 0.2
        transition.interactiveRadiusFactor = 0.4
        transition.showShadow = true
        return transition
    }()
    
    public var dismissByForegroundDrag:Bool {
        return modalTransition.edge == .bottom
    }

    
// MARK: - 闪光灯
    var isOpenedFlash:Bool = false // 闪光灯开启状态
    
// MARK: - 底部几个功能：开启闪光灯、相册
    
    var bottomItemsView:UIView?  //底部显示的功能项
    
    var btnPhoto:UIButton = UIButton()  //相册
    var btnFlash:UIButton = UIButton() //闪光灯

    public init(){
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = modalTransition
        modalPresentationStyle = .custom
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = modalTransition
        modalPresentationStyle = .custom
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        transitioningDelegate = modalTransition
        modalPresentationStyle = .custom
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "返回", target: self, action: #selector(dismissFromVC))]
        
        //需要识别后的图像
        setNeedCodeImage(needCodeImg: true)
        
        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        drawBottomItems()
        
        modalTransition.edge = .bottom
        modalTransition.transformType = dragDownTransformType
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func dismissFromTop(_ sender:UIView?){
        modalTransition.edge = .bottom
        modalTransition.transformType = dragDownTransformType
        modalTransition.startingPoint = sender?.center
        dismiss(animated: true, completion: nil)
    }
    public func dismissFromLeft(_ sender:UIView?){
        modalTransition.transformType = dragRightTransformType
        modalTransition.edge = .right
        modalTransition.startingPoint = sender?.center
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -  custom methods
extension RNQRScanViewController {
    
    @objc func dismissFromVC(){
        
        if self.presentingViewController != nil {
             self.dismiss(animated: true, completion: nil)
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
       
    }
    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        let yMax = self.view.frame.maxY - self.view.frame.minY
        
        bottomItemsView = UIView(frame:CGRect(x: 0.0, y: yMax-100,width: self.view.frame.size.width, height: 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSize(width: 65, height: 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: bottomItemsView!.frame.width/4, y: bottomItemsView!.frame.height/2)
        btnFlash.setImage(UIImage(named: "qr_flash_nor"), for:UIControlState.normal)
        btnFlash.addTarget(self, action: #selector(openOrCloseFlash), for: UIControlEvents.touchUpInside)
        
        
        self.btnPhoto = UIButton()
        btnPhoto.bounds = btnFlash.bounds
        btnPhoto.center = CGPoint(x: bottomItemsView!.frame.width * 3/4, y: bottomItemsView!.frame.height/2)
        btnPhoto.setImage(UIImage(named: "qr_photo_nor"), for: UIControlState.normal)
        btnPhoto.setImage(UIImage(named: "qr_photo_down"), for: UIControlState.highlighted)
        btnPhoto.addTarget(self, action: #selector(RNQRScanViewController.openLocalPhotoAlbum), for: UIControlEvents.touchUpInside)
        
        
        bottomItemsView?.addSubview(btnFlash)
        bottomItemsView?.addSubview(btnPhoto)
        
        self.view.addSubview(bottomItemsView!)
        
    }
    
    //开关闪光灯
    @objc func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "qr_flash_down"), for:UIControlState.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "qr_flash_nor"), for:UIControlState.normal)
        }
    }

    @objc func openLocalPhotoAlbum()
    {
        let alertController = UIAlertController(title: "title", message:"使用首页功能", preferredStyle: UIAlertControllerStyle.alert)
        
        let alertAction = UIAlertAction(title:  "知道了", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            
            
        }
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
}
