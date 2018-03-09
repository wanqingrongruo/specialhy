//
//  DetailFee.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/12/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation

struct DetailFee {
    var money: Double = 0.0
    var title: String = ""
    var number: Int = 1
    var imageUrl: URL? = nil
    var url: String = "" {
        didSet {
            if url.hasPrefix("http") {
                let urlString = url
                imageUrl = URL(string: urlString)
            }
            else {
                let urlString = BASEURL + url
                imageUrl = URL(string: urlString)
            }
        }
    }
    var remark: String = ""
    var payKind: String = ""
    var validity: String = ""
    var isPaid: String = ""
    var isSelected: Bool = true // 是否选中
}
