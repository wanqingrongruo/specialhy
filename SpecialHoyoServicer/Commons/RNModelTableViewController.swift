//
//  RNModelTableViewController.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/21.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class RNModelTableViewController: ElasticModalViewController {
    
    // 关闭下拉dismiss 动画
    override var dismissByForegroundDrag: Bool{
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK: - DZNEmptyDataSetSource & DZNEmptyDataSetDelegate
extension RNModelTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    
//    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let text = "提示";
//        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(18.0)), NSForegroundColorAttributeName: MAIN_THEME_COLOR]
//        return NSAttributedString(string: text, attributes: attributes)
//        
//    }
    //描述为空的数据集
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = CGFloat(NSLineBreakMode.byWordWrapping.rawValue)
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: CGFloat(15.0)), NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.paragraphStyle: paragraph]
        
        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
            return NSAttributedString(string: "呃！好像网没通哦~\n请检查手机网络后重试", attributes: attributes)
        }
        return NSAttributedString(string: "您查询的内容好像没找到哦\n~请确定后重试", attributes: attributes)
    }
    ////空数据按钮图片
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if let isReachable = RNListeningNetwork.shared.manager?.isReachable, isReachable == false {
            return UIImage(named: "order_noNetwork")
        }
        return  UIImage(named: "order_noOrders")//UIImage(named: "order_emptyData")
    }

    
    //    //数据集加载动画
    //    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
    //        let animation = CABasicAnimation(keyPath: "transform")
    //        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
    //        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
    //        animation.duration = 0.25
    //        animation.isCumulative = true
    //        animation.repeatCount = MAXFLOAT
    //        return animation as CAAnimation
    //    }
    //    //按钮标题为空的数据集
    //    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
    //        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(16.0)), NSForegroundColorAttributeName: (state == UIControlState.normal) ? UIColor.brown : UIColor.green]
    //        return NSAttributedString(string: "重新加载", attributes: attributes)
    //    }
    //
    //    ////重新加载按钮背景图片
    //    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
    //        let image = UIImage(named: state == UIControlState.normal ? "button_background_foursquare_normal" : "button_background_foursquare_highlight")
    //        return image?.resizableImage(withCapInsets: UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0), resizingMode: .stretch).withAlignmentRectInsets(UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0))
    //
    //    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 10
    }
    
    //MARK: -- DZNEmptyDataSetDelegate
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}
