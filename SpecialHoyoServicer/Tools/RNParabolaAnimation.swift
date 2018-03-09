//
//  RNParabolaAnimation.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/4.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit

class RNParabolaAnimation: NSObject{
    
    var layer: CALayer = CALayer()
    
    var animationClosure: ((_ isFinished: Bool)->())? // 回调
    
    func startAnimation(view animationView: UIView, startRect: CGRect, finishedPoint: CGPoint, duration: Double = 1.0, finishedClosure: @escaping (_ isFinished: Bool)->()){
        
        let imageView = (animationView as! UIButton).imageView!
      //  let imageView = animationView as! UIImageView
        layer.contents = imageView.layer.contents
        layer.contentsGravity = kCAGravityResizeAspectFill
        
        var rect = startRect
        rect.size.width = 20
        rect.size.height = 20
        layer.bounds = rect
        layer.cornerRadius = rect.size.width/2
        layer.masksToBounds = true
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.layer.addSublayer(layer)
       
        layer.position = CGPoint(x: rect.origin.x+animationView.frame.size.width/2, y: startRect.midY)
        
        // 贝塞尔曲线
        let path = UIBezierPath()
        path.move(to: layer.position)
        let processPoint: CGPoint  = CGPoint(x: SCREEN_WIDTH/2, y: rect.origin.y - 80)
        path.addQuadCurve(to: finishedPoint, controlPoint: processPoint)
        
        // 关键帧动画
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath
       // pathAnimation.rotationMode = kCAAnimationRotateAuto
        // 旋转
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.isRemovedOnCompletion = true
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 12
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        // 组合
        let group = CAAnimationGroup()
        group.animations = [pathAnimation, rotateAnimation]
        group.duration = duration
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate =  self
        layer.add(group, forKey: "group")
        
        animationClosure = finishedClosure
        
    }
    
    
     //购物车抖动
    class func shakeAnimation(shakeView: UIView) {
        
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.translation.y")
        shakeAnimation.duration = 0.25
        shakeAnimation.fromValue = NSNumber.init(value: -5)
        shakeAnimation.toValue = NSNumber.init(value: 5)
        shakeAnimation.autoreverses = true
        shakeView.layer.add(shakeAnimation, forKey: nil)
    }
}

extension RNParabolaAnimation: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == self.layer.animation(forKey: "group"){
            
            self.layer.removeFromSuperlayer()
            self.layer = CALayer()
            
            if animationClosure != nil {
                animationClosure!(true)
            }
        }
    }
}

