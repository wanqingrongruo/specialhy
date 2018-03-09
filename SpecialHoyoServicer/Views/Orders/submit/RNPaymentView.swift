//
//  RNPaymentView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class HeightView: UIView {
    
  
}

class RNPaymentView: UIView {
    
    typealias CompleteCallback = (_ tag: Int) -> ()
    // xib 不能复用真是麻烦... 特么手写代码这个实现起来so easy...然而就是要埋个坑
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scanView: RNHeightView!
    @IBOutlet weak var scanImageView: UIImageView!
    @IBOutlet weak var scanLabel: UILabel!
    @IBOutlet weak var cardView: RNHeightView!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var cashView: RNHeightView!
    @IBOutlet weak var cashImageView: UIImageView!
    @IBOutlet weak var cashLabel: UILabel!
    
    @IBOutlet weak var tapScanView: RNHeightView!
    @IBOutlet weak var tapCardView: RNHeightView!
    @IBOutlet weak var tapCashView: RNHeightView!
    
    
    internal var completeCallback: CompleteCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scanView.layer.masksToBounds = true
        scanView.layer.cornerRadius = 5.0
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 5.0
        cashView.layer.masksToBounds = true
        cashView.layer.cornerRadius = 5.0
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let scanTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scanAction(gesture:)))
        tapScanView.addGestureRecognizer(scanTap)
        let cardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardAction(gesture:)))
        tapCardView.addGestureRecognizer(cardTap)
        let cashTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cashAction(gesture:)))
        tapCashView.addGestureRecognizer(cashTap)
    }
    
}

extension RNPaymentView {
    
    @objc func scanAction(gesture: UITapGestureRecognizer) {
        completeCallback?(tapScanView.tag)
    }
    
    @objc func cardAction(gesture: UITapGestureRecognizer) {
        completeCallback?(tapCardView.tag)
    }
    
    @objc func cashAction(gesture: UITapGestureRecognizer) {
        completeCallback?(tapCashView.tag)
    }
}

class RNHeightView: UIView {
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.point(inside: point, with: event) {
////            let imageView = self.viewWithTag(100) as? UIImageView
////            let label = self.viewWithTag(200) as? UILabel
////
////            self.backgroundColor = MAIN_THEME_COLOR
////            label?.textColor = UIColor.white
////
////            switch self.tag {
////            case 0:
////                imageView?.image = UIImage(named: "newFee_scan_selected")
////            case 1:
////                imageView?.image = UIImage(named: "newFee_card_selected")
////            case 2:
////                imageView?.image = UIImage(named: "newFee_cash_selected")
////            default:
////                break
////            }
//            return self
//        }
//
//        return nil
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard touches.count > 0 else {
//            return
//        }
//        var view: RNHeightView?
//        for item in touches {
//            view = item.view as? RNHeightView
//            break
//        }
        
        let view = self.superview
        
        if let v = view {
            let imageView = v.viewWithTag(100) as? UIImageView
            let label = v.viewWithTag(200) as? UILabel
            
            v.backgroundColor = MAIN_THEME_COLOR
            label?.textColor = UIColor.white
            
            switch v.tag {
            case 0:
                imageView?.image = UIImage(named: "newFee_scan_selected")
            case 1:
                imageView?.image = UIImage(named: "newFee_card_selected")
            case 2:
                imageView?.image = UIImage(named: "newFee_cash_selected")
            default:
                break
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let view = self.superview
        
        if let v = view {
            let imageView = v.viewWithTag(100) as? UIImageView
            let label = v.viewWithTag(200) as? UILabel
            
            v.backgroundColor = UIColor.white
            label?.textColor = UIColor.color(44, green: 44, blue: 44, alpha: 1)
            
            switch v.tag {
            case 0:
                imageView?.image = UIImage(named: "newFee_scan")
            case 1:
                imageView?.image = UIImage(named: "newFee_card")
            case 2:
                imageView?.image = UIImage(named: "newFee_cash")
            default:
                break
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let view = self.superview
        
        if let v = view {
            let imageView = v.viewWithTag(100) as? UIImageView
            let label = v.viewWithTag(200) as? UILabel
            
            v.backgroundColor = UIColor.white
            label?.textColor = UIColor.color(44, green: 44, blue: 44, alpha: 1)
            
            switch v.tag {
            case 0:
                imageView?.image = UIImage(named: "newFee_scan")
            case 1:
                imageView?.image = UIImage(named: "newFee_card")
            case 2:
                imageView?.image = UIImage(named: "newFee_cash")
            default:
                break
            }
        }
    }
}
