//
//  RNPartInfoView.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/8/7.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Spring
import Kingfisher

class RNPartInfoView: SpringView {

    @IBOutlet weak var imgeView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productModelName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var model: PartModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func config(model: PartModel){
        
        self.model = model
        
        
        var urlString = model.productImageUrl ?? ""
        if urlString.contains("http") == false {
            urlString = BASEURL + urlString
        }
        let url = URL(string: urlString)
       // RNHud().showHud(nil)
        imgeView.kf.setImage(with: url, placeholder: UIImage(named: "order_productDefaultImage"), options: nil, progressBlock: nil) { (_, _, _, _) in
          //  RNHud().hiddenHub()
        }

        
        productNameLabel.text = model.productName
        productModelName.text = model.productModel
        priceLabel.text = String(format: "¥%@", model.productPrice ?? "")
        
    }
}
