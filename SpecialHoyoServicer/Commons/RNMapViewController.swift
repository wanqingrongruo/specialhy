//
//  RNMapViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/19.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import MapKit
import SnapKit

protocol MapViewControllerProtocol {
    func showMapView(destinationLocation:CLLocationCoordinate2D, destinationString: String) // 跳转地图界面
}

class RNMapViewController: UIViewController {
    
    var lastTitle: String
    var destinationLocation: CLLocationCoordinate2D
    var destinationString: String
    
    var mapView: MKMapView?
    
    var myOverlays: [MKOverlay]? = nil // 路线上步数集合
    var isShowRoute = true
    
    init(_ title: String, destinationLocation: CLLocationCoordinate2D, destinationString: String) {
        
        self.lastTitle = title
        self.destinationLocation = destinationLocation
        self.destinationString = destinationString
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = -8
        navigationItem.leftBarButtonItems = [space, UIBarButtonItem.createLeftBarItem(title: "返回", target: self, action: #selector(dismissFromVC))]
        
        createMapView()
        
        setupBottomView(destinationString)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MAKK: - custom methods
extension RNMapViewController {
    
    func createMapView() {
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64))
        mapView?.mapType = .standard // 标准模式
        mapView?.showsUserLocation = true // 显示当前位置
        mapView?.delegate = self
        mapView?.isZoomEnabled = true // 支持缩放
        
        view.addSubview(mapView!)
        
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(destinationLocation, 3000, 3000) // 以destinationLocation为中心, 显示周围3000米范围
        let adjustedRegion = mapView!.regionThatFits(viewRegion) //适配mapView的尺寸
        mapView?.setRegion(adjustedRegion, animated: true)
        //        let span = MKCoordinateSpanMake(0.05, 0.05)
        //        let region = MKCoordinateRegionMake(destinationLocation, span)
        //        mapView?.region = region
        
        
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = destinationLocation
        mapView?.addAnnotation(pointAnnotation)
    }
    
    func setupBottomView(_ title: String){
        
        let h: CGFloat = 80
        
        let bottomView = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT - h, width: SCREEN_WIDTH, height: h))
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView)
        
        let contentLabel = RNMultiFunctionLabel()
        contentLabel.text = title
        contentLabel.numberOfLines = 0
        bottomView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named:"order_goAddress"), for: .normal)
        btn.backgroundColor = UIColor.cyan
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = (h-30)/2.0
       // btn.layer.shouldRasterize = true
        btn.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        bottomView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.leading.equalTo(contentLabel.snp.trailing).offset(20)
            make.trailing.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(h-30)
            make.height.equalTo(h-30)
        }
        
    }
    
    // 判断是否获取到当前位置
    func getCurrentLocation() -> (isUpdatedSuccess: Bool, origin: CLLocationCoordinate2D?) {
        
        let origin = self.mapView?.userLocation.location?.coordinate
        
        guard let _ = origin else{
            
            RNNoticeAlert.showError("提示", body: "正在获取当前位置, 请稍等")
            
            return (false, nil)
        }
        
        return (true, origin)
        
    }
    
    // 绘制路线
    func makeRoute(_ origin: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) {
        
        let originPlaceMark = MKPlacemark(coordinate: origin, addressDictionary: nil)
        let originMapItem = MKMapItem(placemark: originPlaceMark)
        
        let destinationPlaceMark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
        
        let request = MKDirectionsRequest()
        request.source = originMapItem
        request.destination = destinationMapItem
        
        // pull request to server of apple
        
        // 用于发送请求去服务器,获取规划好的路线
        let directs = MKDirections(request: request)
        directs.calculate { (response, error) in
            
            // 获取所有规划路径
            let routes = response?.routes
            let route = routes?.last
            
            // 保存路线中的每一步
            let steps = route?.steps
            
            guard let _ = steps else{
                return
            }
            for step in steps!{
                
                // 绘制遮盖打印到地图上
                self.mapView?.add(step.polyline, level: .aboveRoads)
                
                // self.myOverlays?.append(step.polyline)
            }
        }
        
        
    }
    
}

//MARK: - event response
extension RNMapViewController {
    
    @objc func dismissFromVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showMap(){
        
        // 检测手机上的地图
        let isBaiduMap = UIApplication.shared.canOpenURL(URL(string: "baidumap://")!)
        let isTencentMap = UIApplication.shared.canOpenURL(URL(string: "sosomap://")!)
        let isGaodeMap = UIApplication.shared.canOpenURL(URL(string: "iosamap://")!)
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let routeTitle = "显示路线"
        if !isShowRoute {
            
            // routeTitle = "隐藏路线"
        }
        
        let showRoute = UIAlertAction(title: routeTitle, style: .default) { (action) in
            
            
            if self.isShowRoute{
                
                
                RNHud().showHud(nil)
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    
                    RNHud().hiddenHub()
                    return
                }
                
                self.makeRoute(self.getCurrentLocation().origin!, self.destinationLocation)
            }else{
                
                //                if let overlays = self.myOverlays {
                //                   // 移除路线 -- 不成功舍弃
                //                    self.mkMapView.removeOverlays(overlays)
                //                    self.myOverlays = nil
                //                }
                
            }
            
            //  self.isShowRoute = !self.isShowRoute
            
        }
        
        alertViewController.addAction(showRoute)
        
        if isBaiduMap {
            
            let baiduAction = UIAlertAction(title: "百度地图", style: .default) { (action) in
                
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    return
                }
                
                let ori = self.getCurrentLocation().origin!
                
                let str = "baidumap://map/direction?origin=\(ori.latitude),\(ori.longitude)&destination=\(self.destinationLocation.latitude),\(self.destinationLocation.longitude)&name=\(self.destinationString)&mode=driving&coord_type=gcj02&src=浩优服务家"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(baiduAction)
        }
        
        if isTencentMap {
            
            let tencentAction = UIAlertAction(title: "腾讯地图", style: .default) { (action) in
                
                guard self.getCurrentLocation().isUpdatedSuccess else{
                    return
                }
                
                let ori = self.getCurrentLocation().origin!
                
                let str = "qqmap://map/routeplan?type=drive&from=我的位置&fromcoord=\(ori.latitude),\(ori.longitude)&to=\(self.destinationString)&tocoord=\(self.destinationLocation.latitude),\(self.destinationLocation.longitude)&policy=0&referer=浩优服务家"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(tencentAction)
        }
        
        if isGaodeMap {
            
            let gaodeAction = UIAlertAction(title: "高德地图", style: .default) { (action) in
                
                //                guard self.getCurrentLocation().isUpdatedSuccess else{
                //                    return
                //                }
                //
                //                let ori = self.getCurrentLocation().origin!
                
                //&slat=\(ori.latitude)&slon=\(ori.longitude)&sname=我的位置&did=BGVIS2&d
                let str = "iosamap://navi?sourceApplication=浩优服务家&backScheme=hoyoServicer&lat=\(self.destinationLocation.latitude)&lon=\(self.destinationLocation.longitude)&name=\(self.destinationString)&dev=0&style=2"
                // 对汉字进行转码 stringByAddingPercentEscapesUsingEncoding => iOS9.0 addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let urlStr = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                guard let us = urlStr, let u = URL(string: us) else{
                    return
                }
                UIApplication.shared.openURL(u)
            }
            alertViewController.addAction(gaodeAction)
        }
        
        let appleAction = UIAlertAction(title: "苹果地图", style: .default) { (action) in
            
            let destinationPlaceMark = MKPlacemark(coordinate: self.destinationLocation, addressDictionary: nil)
            let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
            destinationMapItem.name = self.destinationString
            
            let currentLocation = MKMapItem.forCurrentLocation()
            currentLocation.name = "我的位置"
            MKMapItem.openMaps(with: [currentLocation, destinationMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: NSNumber.init(value: true)])
        }
        alertViewController.addAction(appleAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (cation) in}
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true) {}
    }
    
}

//MARK: - MKMapViewDelegate
extension RNMapViewController: MKMapViewDelegate {
    
    // 返回指定的遮盖模型所对应的遮盖视图
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // 针对线段,系统有提供好的遮盖视图
        let render = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        // 配置遮盖的宽度-颜色
        render.lineWidth = 5.0
        render.strokeColor = UIColor.red
        
        RNHud().hiddenHub()
        
        return render
    }
    
}
