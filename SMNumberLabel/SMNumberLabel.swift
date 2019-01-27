//
//  SMNumberLabel.swift
//  SMNumberLabel
//
//  Created by Slavenko on 1/26/19.
//  Copyright © 2019 Slavenko. All rights reserved.
//

import Foundation
import UIKit

class SMNumberLabel : UILabel
{
    lazy var container : UIView = {
        let c = UIView()
        c.backgroundColor = .clear
        c.clipsToBounds = true
        return c
    }()
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.clipsToBounds = true
        self.backgroundColor = .clear
        self.textColor = .red
        self.addContainer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.clipsToBounds = true
        self.backgroundColor = .clear
        self.textColor = .red
        self.addContainer()
    }
    
    func addContainer(){
        self.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: container.superview!.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: container.superview!.bottomAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: container.superview!.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: container.superview!.trailingAnchor).isActive = true
    }
    
    var value : Double = 0 {
        didSet {
            self.text = self.formatString(value)
        }
    }
    
    func formatString(_ val: Double) -> String?
    {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self.value))
    }
    
    func setValue(_ value: Any?) {
        if let dVal = value as? Double
        {
            self.value = dVal
        }
        else if let dVal = value as? Int
        {
            self.value = Double(dVal)
        }
    }
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            guard self.parseCurrencyString(text) != nil else {
                self.pushTransition(startValue: 0, endValue: 0, duration: 0.0, delay: 0)
                return
            }
            var oldVal = oldValue!
            var newVal = text
            if newVal.count < oldVal.count
            {
                newVal = String(oldVal.dropLast(oldVal.count - newVal.count))
            }
            let attributedText = NSMutableAttributedString(string: text)
            let decimalSeparator = NSLocale.current.decimalSeparator! as String
            let fullFont = self.font
            let halfFont = UIFont(name: self.font.fontName, size: self.font.pointSize / 2)
            var startPos = 0
            if let range = text.range(of: decimalSeparator)
            {
                startPos = text.distance(from: text.startIndex, to: range.lowerBound)
                let attributedRange = NSMakeRange(startPos, text.count - startPos)
                let fontSize = self.font.pointSize / 2
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(
                    name: self.font.fontName,
                    size: fontSize)!, range: attributedRange)
            }
            self.attributedText = attributedText
            var previousLetter : UILabel? = nil
            var delay : Double = 0.0
            self.container.subviews.map({$0.removeFromSuperview()})
            for (index, char) in text.enumerated()
            {
                let oldChar = Int(oldVal[index]) ?? 0
                let newChar = Int(text[index])
                
                let lbl = UILabel()
                if newChar == nil
                {
                    lbl.text = text[index]
                }
                else if Int(oldVal[index]) != nil
                {
                    lbl.text = oldVal[index]
                }
                else
                {
                    lbl.text = text[index]
                }
                
                lbl.font = self.font
                self.container.addSubview(lbl)
                lbl.translatesAutoresizingMaskIntoConstraints = false
                
                lbl.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
                
                var width = String(char).width(withConstrainedHeight: 0, font: fullFont!)
                var offsetBottom : CGFloat = 0
                var offsetLeft : CGFloat = 0
                if startPos <= index
                {
                    lbl.font = halfFont
                    width = String(char).width(withConstrainedHeight: 0, font: halfFont!) + 50
                    offsetBottom = (fullFont?.pointSize)! / 3 + 1
                    offsetLeft = -1
                }
                
                if previousLetter == nil
                {
                    lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
                }
                else
                {
                    lbl.leadingAnchor.constraint(equalTo: (previousLetter?.trailingAnchor)!, constant: offsetLeft).isActive = true
                }
                lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: offsetBottom).isActive = true
                lbl.widthAnchor.constraint(equalToConstant: width)
                //lbl.clipsToBounds = true
                
                previousLetter = lbl
                
                if index == (self.text?.count)! - 1
                {
                    lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
                }
                
                if newChar != nil && self.parseCurrencyString(oldVal) != nil
                {
                    lbl.pushTransition(startValue: oldChar, endValue: newChar!, duration: 0.2, delay: delay)
                    delay += 1
                }
            }

        }
    }
    
    public func parseCurrencyString(_ value: String) -> Double?
    {
        var decimalSep = NSLocale.current.decimalSeparator! as String
        var groupSep = NSLocale.current.groupingSeparator! as String
        
        //Ok since everyone has different regional settings on their phone and bank can always decide to change the formatting
        //we're gonna do this the old school way.
        //check for the last occurence of dot and ocmma characters in the string and decide based on that
        //what kind of string is the user trying to type in/paste
        //bring it on
        
        let dotRange = value.range(of: ".")?.upperBound
        let commaRange = value.range(of: ",")?.upperBound
        var dotPosition: Int = 0
        var dotEndPosition: Int = 0
        var commaPosition: Int = 0
        var commaEndPosition: Int = 0
        
        if dotRange != nil
        {
            dotPosition = value.distance(from: value.startIndex, to: dotRange!)
            dotEndPosition = value.distance(from: value.endIndex, to: dotRange!)
        }
        
        if commaRange != nil
        {
            commaPosition = value.distance(from: value.startIndex, to: commaRange!)
            commaEndPosition = value.distance(from: value.endIndex, to: commaRange!)
        }
        var formattedString: String = "0"
        
        if dotPosition > 0 && dotPosition > commaPosition
        {
            //the typoed in number has dot as a decimal separator.
            //we assume that the comma is group separator
            decimalSep = "."
            groupSep = ","
            if dotEndPosition < -2
            {
                //this is a number formatted osmething like this
                // 123.456 and in this case dot is a group separator
                decimalSep = ","
                groupSep = "."
            }
        }
        else {
            //comma is a decimal separator, and dot is a group separator
            decimalSep = ","
            groupSep = "."
            
            if commaEndPosition < -2
            {
                //this is a number formatted osmething like this
                // 123,456 and in this case comma is a group separator
                decimalSep = "."
                groupSep = ","
            }
        }
        
        formattedString = value.replacingOccurrences(of: groupSep, with: "")
        formattedString = formattedString.replacingOccurrences(of: decimalSep, with: ".")
        return Double(formattedString)
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

// Usage: insert view.pushTransition right before changing content
extension UILabel {
    func pushTransition(startValue: Int, endValue: Int, duration:CFTimeInterval, delay: Double) {
        print("start value: \(startValue)")
        print("end value: \(endValue)")

        //return
        if Double(self.text!) != nil
        {
            
            var startDelay : Double = 0
            let startVal = startValue
            var endVal = endValue
            if startVal > endValue
            {
                endVal = endValue + 10
            }
            
            let finalDuration : Double = duration / Double(endVal - startVal)
            
            for i in startVal...endVal
            {
                print("start:\(startVal ) end:\(startVal ) index: \(i) last: \(String(i).last!)")
                // Always update your GUI on the main thread
                DispatchQueue.main.asyncAfter(deadline: .now() + (startDelay + (finalDuration * Double(i)))) {
                    let animation:CATransition = CATransition()
                    animation.beginTime = CACurrentMediaTime()
                    animation.timingFunction = CAMediaTimingFunction(name:
                        CAMediaTimingFunctionName.easeOut)
                    
                    animation.type = CATransitionType.push
                    animation.subtype = CATransitionSubtype.fromTop
                    animation.duration = finalDuration
                    self.layer.add(animation, forKey: CATransitionType.push.rawValue)
                    startDelay += finalDuration
                    
                    print("TEXT: \(String(i).last!)")
                    self.text = "\(String(i).last!)"
                }
            }
        }
    }
}

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}
