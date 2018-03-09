//
//  RNTjViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/11/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNTjViewController: UIViewController {
    
    // 动画参数 -- 具体参考 Spring 库
    var selectedRow: Int = 0
    var selectedEasing: Int = 0
    
    var selectedForce: CGFloat = 1
    var selectedDuration: CGFloat = 1
    var selectedDelay: CGFloat = 0
    
    var selectedDamping: CGFloat = 0.5
    var selectedVelocity: CGFloat = 0.7
    var selectedScale: CGFloat = 1
    var selectedX: CGFloat = 0
    var selectedY: CGFloat = 0
    var selectedRotate: CGFloat = 0
    
    var selectedAnimation: String = Spring.AnimationPreset.SlideDown.rawValue
    var selectedCurve: String = Spring.AnimationCurve.EaseInOut.rawValue
    
    weak var appWindow: UIWindow?
    var callBack: ((_ dic: [String: Any]) -> ())?
    
    var tipView: RNTjTipView? = nil
    lazy var paramsDic: [String: Any] = {
        return [String: Any]()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.color(77, green: 77, blue: 77, alpha: 0.5)

        let t = Bundle.main.loadNibNamed("RNTjTipView", owner: self, options: nil)?.last as? RNTjTipView
        t?.frame = CGRect(origin: .zero, size: CGSize(width: SCREEN_WIDTH - 80, height: 334))
        t?.center = view.center
        t?.layer.masksToBounds = true
        t?.layer.cornerRadius = 5
        tipView = t
        
        if let v = tipView {
           view.addSubview(v)
            
            setOptions()
            v.animate()
            v.paramCallBack = { [weak self]dic in
                self?.paramsDic = dic
                self?.dismissVC()
            }
            
        }
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
//        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOptions() {
        tipView?.force = selectedForce
        tipView?.duration = selectedDuration
        tipView?.delay = selectedDelay
        
        tipView?.damping = selectedDamping
        tipView?.velocity = selectedVelocity
        tipView?.scaleX = selectedScale
        tipView?.scaleY = selectedScale
        tipView?.x = selectedX
        tipView?.y = selectedY
        tipView?.rotate = selectedRotate
        
        tipView?.animation = selectedAnimation
        tipView?.curve = selectedCurve
    }


    func dismissVC(){
        
        self.view.alpha = 0
        self.appWindow?.makeKeyAndVisible()
        self.callBack?(paramsDic)
    }

}
