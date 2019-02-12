//
//  UILabel+NameBox.swift
//  Kuso
//
//  Created by blurryssky on 2018/8/2.
//  Copyright © 2018年 momo. All rights reserved.
//

import UIKit

extension Up2Player where T: UILabel {
    
    func setFormattedPointTimeText(_ time: TimeInterval) {
        
        let seconds = floor(time)
        let milliseconds = Int(time.truncatingRemainder(dividingBy: 1) * 10)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "0"
        let secondsString = numberFormatter.string(from: NSNumber(value: seconds)) ?? "0"
        let millisecondsString = numberFormatter.string(from: NSNumber(value: milliseconds)) ?? "0"
        
        base.text = "\(secondsString).\(millisecondsString)"
    }
    
    func setFormattedColonTimeText(_ time: TimeInterval) {
        
        let seconds = Int(floor(time).truncatingRemainder(dividingBy: 60))
        let minutes = Int(floor(time)/60)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "00"
        let secondsString = numberFormatter.string(from: NSNumber(value: seconds)) ?? "00"
        let minutesString = numberFormatter.string(from: NSNumber(value: minutes)) ?? "00"
        
        base.text = "\(minutesString):\(secondsString)"
    }
    
    func setTagAttributedString(text: String) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: "PingFangSC-Medium", size: 19.0)!,
            .foregroundColor: UIColor(white: 1.0, alpha: 1.0)
            ])
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 19.0, weight: .black),
            .foregroundColor: #colorLiteral(red: 1, green: 0.06274509804, blue: 0.8470588235, alpha: 1)
            ], range: NSRange(location: 0, length: 1))
        base.attributedText = attributedString
    }
    
    func setSuperTagAttributedString(text: String) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: "PingFangSC-Medium", size: 15.0)!,
            .foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            ])
        base.attributedText = attributedString
    }
}
