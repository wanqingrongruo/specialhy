//
//  RNTipHudViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring

class RNTipHudViewController:  ElasticModalViewController{
    
    var contentView: SpringView
    weak var appWindow: UIWindow?
    
    var callBack: (() -> ())?
    
    
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

    
    init(_ contentView: SpringView) {
        
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.color(77, green: 77, blue: 77, alpha: 0.5)
        
      
        self.view.addSubview(self.contentView)
        setOptions()
        contentView.animate()
      
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOptions() {
        contentView.force = selectedForce
        contentView.duration = selectedDuration
        contentView.delay = selectedDelay
        
        contentView.damping = selectedDamping
        contentView.velocity = selectedVelocity
        contentView.scaleX = selectedScale
        contentView.scaleY = selectedScale
        contentView.x = selectedX
        contentView.y = selectedY
        contentView.rotate = selectedRotate
        
        contentView.animation = selectedAnimation
        contentView.curve = selectedCurve
    }

    
    @objc func dismissVC(){
       // self.dismissFromTop(view)
        
        view.alpha = 0
        appWindow?.makeKeyAndVisible()
        
        callBack?()
    }

}
