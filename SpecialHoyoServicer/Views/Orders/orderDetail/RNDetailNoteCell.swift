//
//  RNDetailNoteCell.swift
//  SpecialHoyoServicer
//
//  Created by roni on 2017/7/20.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

class RNDetailNoteCell: UITableViewCell {
    
    var model: OrderDetail?
    var completedModel: CompletedOrderDetail?
    
    var phoneNmuber: NSAttributedString? = nil
    
    @IBOutlet weak var noteLabel: MLEmojiLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        noteLabel.emojiDelegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func config(_ model: OrderDetail, titleString: String) {
        
        self.model = model
        
        guard let note = model.decribe, note != "" else {
            noteLabel.text = model.decribe
            return
        }
        
        noteLabel.emojiText = note
        
//        if let note = model.decribe {
//            numberDistingush(label: noteLabel, string: note)
//        }
//        
//        
//        noteLabel.text = (model.decribe == "") ? "无" : model.decribe
//        
//        noteLabel.pressClosure =  { [weak self](gesture) in
//            
//            if let text = self?.noteLabel.text, text != "" {
//                
//                if gesture.state == .began{
//                    
//                    self?.noteLabel.pressAction(whichLabel: (self?.noteLabel)!)                }
//                
//            }
//        }
        
    }
    
}

//MARK: - completedOrder

extension RNDetailNoteCell{
    
    func config02(_ model: CompletedOrderDetail, titleString: String){
        
        self.completedModel = model
        
        guard let note = model.decribe, note != "" else {
            noteLabel.text = model.decribe
            return
        }
        
        noteLabel.emojiText = note
        
//        if let note = model.decribe {
//            numberDistingush(label: noteLabel, string: note)
//        }
//        
//        noteLabel.text = (model.decribe == "") ? "无" : model.decribe
//        
//        noteLabel.pressClosure =  { [weak self](gesture) in
//            
//            if let text = self?.noteLabel.text, text != "" {
//                
//                if gesture.state == .began{
//                    
//                    self?.noteLabel.pressAction(whichLabel: (self?.noteLabel)!)                }
//                
//            }
//        }
        
    }
}

extension RNDetailNoteCell: MLEmojiLabelDelegate {
    
    func mlEmojiLabel(_ emojiLabel: MLEmojiLabel!, didSelectLink link: String!, with type: MLEmojiLabelLinkType) {
        
        switch type {
        case MLEmojiLabelLinkType():
          //  print(link)
            
            if link.contains("http://") || link.contains("https://") {
                UIApplication.shared.openURL(URL(string: link)!)
            } else {
                let strUrl =  "http://" + link
                UIApplication.shared.openURL(URL(string: strUrl)!)
                
            }
            
        case MLEmojiLabelLinkType.phoneNumber:
            UIApplication.shared.openURL(URL(string: "tel://" + link)!)
        case MLEmojiLabelLinkType.email:
            UIApplication.shared.openURL(URL(string: "mailto://" + link)!)
            
        default:
            break
        }
        
    }
}



// 识别号码
extension RNDetailNoteCell {
    
    func numberDistingush(label: RNMultiFunctionLabel, string: String) {
        
        let regularStr = "\\d{3,4}[- ]?\\d{7,8}"
        let range = NSMakeRange(0, string.characters.count)
        
      //  let error: Error? = nil
        
        let str: NSMutableAttributedString = NSMutableAttributedString(string: string)
        
        
        let regularExpression = try! NSRegularExpression(pattern: regularStr, options: .init(rawValue: 0))
        
        regularExpression.enumerateMatches(in: string, options: .init(rawValue: 0), range: range) { (result, flags, stop) in
            let phoneRange = result?.range
            
            guard let pRange = phoneRange else{
                return
            }
            phoneNmuber = str.attributedSubstring(from: pRange)
            // 下划线; 号码显示颜色
            let attributeDic = [NSAttributedStringKey.underlineColor: NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), NSAttributedStringKey.foregroundColor: MAIN_THEME_COLOR]
            str.addAttributes(attributeDic, range: pRange)
            
            label.attributedText = str
            label.isUserInteractionEnabled = true
            label.isOpenTapGesture = true
            
            label.tapClosure = { [weak self](_) in
                
                let stringNum = self?.phoneNmuber?.string
                
                guard let num = stringNum else{
                    return
                }
                let telephoneNum = "telprompt://\(num)"
                guard let tel = URL(string: telephoneNum) else{
                    return
                }
                UIApplication.shared.openURL(tel)
                
            }
        }
    }
}
