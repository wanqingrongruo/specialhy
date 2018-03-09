//
//  RNCompletedImageCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Kingfisher

class RNCompletedImageCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView01: UIImageView! //100
    @IBOutlet weak var imageView02: UIImageView! //101
    @IBOutlet weak var imageView03: UIImageView! //102
    @IBOutlet weak var imageView04: UIImageView! //103
    
    var index: IndexPath?
    var vc: UIViewController?
    var currentTag: Int = 100
    lazy var images: [ImageModel] = {
        return [ImageModel]()
    }()
    lazy var imageArray:[String] = {
        return [String]()
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap01 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView01.addGestureRecognizer(tap01)
        let tap02 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView02.addGestureRecognizer(tap02)
        let tap03 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView03.addGestureRecognizer(tap03)
        let tap04 = UITapGestureRecognizer(target: self, action: #selector(imagePick(tap:)))
        imageView04.addGestureRecognizer(tap04)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func config(indexPath index: IndexPath, images: [ImageModel], viewController: UIViewController) {
        
        self.index = index
        self.images = images
        self.vc = viewController
        
        for (index, value) in images.enumerated() {
            
            if index < backView.subviews.count {
               let imageView = backView.subviews[index] as! UIImageView
                imageView.isHidden = false
                if let im = value.imageUrl, let url = URL(string: im) {
                   imageView.kf.setImage(with: url, placeholder: UIImage(named: "other_noFound"), options: nil, progressBlock: nil, completionHandler: nil)
                }else{
                   imageView.kf.setImage(with: value.imageUrl as? Resource, placeholder: UIImage(named: "other_noFound"), options: nil, progressBlock: nil, completionHandler: nil)
                }
                
            }
            
            if let url = value.imageUrl {
                imageArray.append(url)
            }
            
        }
    }
    

    @objc func imagePick(tap: UITapGestureRecognizer){
        
        currentTag = (tap.view as! UIImageView).tag
        
        guard let v = vc else {
            return
        }
        
        
        let t = (tap.view as! UIImageView).tag - 100
        guard imageArray.count > 0, t < imageArray.count else {
            return
        }
        
        let imageView = tap.view as! UIImageView
      //  let image = imageArray[currentTag-100] 
        let pictureBrowser = RNPictureBroswer(from: v, showView: imageView, originImage: UIImage(), currentIndex: currentTag-100)
        pictureBrowser.urlImages = imageArray
        pictureBrowser.showBrowserForUrl()

    }

}
