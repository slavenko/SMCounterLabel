//
//  SMCounterLabel.swift
//  SMCounterLabel
//
//  Created by Slavenko on 1/26/19.
//  Copyright © 2019 Slavenko. All rights reserved.
//

import Foundation
import UIKit

public enum SMLabelFormatType {
    case decimal
    case integer
    case fancy
}

public class SMSingleCounterLabel : UILabel
{
    func incrementValue(endValue: Int, duration:CFTimeInterval)
    {
        let startVal = (Int(self.text!) ?? 0) + 1
        
        //we don't want to have increment for example from 3 to 4, because that's just one spin and it looks boring, so we'll add 10 just in case so we'll spin from 3 to 14
        var endVal = endValue + 10
        
        //in case we have for axample 9 and 12, it also looks boring, since it's only 3 spins so we make sure to add some more spins
        if (endVal - startVal) < 6
        {
            endVal += 10
        }
        
        //We calculate how long shuld each increment take, because we need to finish entire animation in a fixed amount of time
        let finalDuration : Double = duration / Double(endVal - startVal)
        for i in startVal...endVal
        {
            let index = i - startVal
            let character = "\(String(i).last!)"
            DispatchQueue.main.asyncAfter(deadline: .now() + (finalDuration * Double(index))){
                self.layer.animateUp(duration: finalDuration, delay: 0)
                self.text = "\(character)"
            }
        }
    }
    
    func decrementValue(endValue: Int, duration:CFTimeInterval)
    {
        var startValue = (Int(self.text!) ?? 0) - 1
        
        //we don't want to have decrement for example from 4 to 3, because that's just one spin and it looks boring, so we'll add 10 just in case so we'll spin from 14 to 3
        startValue = startValue + 10
        
        //in case we have for axample 12 and 9, it also looks boring, since it's only 3 spins so we make sure to add some more spins
        if (startValue - endValue) < 6
        {
            startValue += 10
        }
        
        //We calculate how long shuld each increment take, because we need to finish entire animation in a fixed amount of time
        let finalDuration : Double = duration / Double(startValue - endValue)
        
        var i = 0
        while startValue >= endValue {
            let character = "\(String(startValue).last!)"
            DispatchQueue.main.asyncAfter(deadline: .now() + (finalDuration * Double(i))){
                self.layer.animateDown(duration: finalDuration)
                self.text = "\(character)"
            }
            startValue = startValue - 1
            i = i + 1
        }
    }
}

public class SMCounterLabel : UILabel
{
    public var formatType : SMLabelFormatType = .decimal
    
    public var duration : Double = 0.6
    public var delay : Double = 0.2
    public var durationIncrement : Double = 0.0
    public var color : UIColor = .black
    
    lazy var container : UIView = {
        let c = UIView()
        c.backgroundColor = .clear
        c.clipsToBounds = true
        return c
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        self.textColor = .clear
        self.addContainer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.textColor = .clear
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
        
        //Other supported format types (decimal/fancy) support decimal places
        if formatType == .integer
        {
            formatter.numberStyle = .none
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: self.value))
    }
    
    //We'll try to parse whatever we send here
    public func setValue(_ value: Any?) {
        if let dVal = value as? Double
        {
            self.value = dVal
        }
        else if let dVal = value as? Int
        {
            self.value = Double(dVal)
        }
    }
    
    //Return string value back
    public func getValue() -> String
    {
        return self.text!
    }
    
    override public var text: String? {
        didSet {
            guard let text = text else { return }
            guard self.parseCurrencyString(text) != nil else {
                return
            }
            
            if oldValue != nil
            {
                let oldVal = oldValue!
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
                    let fontSize = formatType == .fancy ? self.font.pointSize / 2 : self.font.pointSize
                    attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(
                        name: self.font.fontName,
                        size: fontSize)!, range: attributedRange)
                }
                self.attributedText = attributedText
                let fullTextWidth : CGFloat = self.text?.width(withConstrainedHeight: 0, font: self.font) ?? 0
                var previousLetter : SMSingleCounterLabel? = nil
                var initialdelay : Double = 0.0
                var initialduration : Double = self.duration
                _ = self.container.subviews.map({$0.removeFromSuperview()})
                for (index, char) in text.enumerated()
                {
                    let newChar = Int(text[index])
                    
                    let lbl = SMSingleCounterLabel()
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
                    lbl.textColor = self.color
                    
                    self.container.addSubview(lbl)
                    lbl.translatesAutoresizingMaskIntoConstraints = false
                    
                    lbl.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
                    
                    var width = String(char).width(withConstrainedHeight: 0, font: fullFont!)
                    var offsetBottom : CGFloat = 0
                    var offsetLeft : CGFloat = 0
                    
                    if formatType == .fancy && startPos <= index
                    {
                        lbl.font = halfFont
                        width = String(char).width(withConstrainedHeight: 0, font: halfFont!) + 50
                        offsetBottom = (fullFont?.pointSize)! / 3 + 1
                        offsetLeft = -1
                    }
                    
                    if previousLetter == nil
                    {
                        if self.textAlignment == .left
                        {
                            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
                        }
                        else if self.textAlignment == .right
                        {
                            lbl.leadingAnchor.constraint(equalTo: container.trailingAnchor, constant: -fullTextWidth).isActive = true
                        }
                        else if self.textAlignment == .center
                        {
                            lbl.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: -fullTextWidth / 2).isActive = true
                        }
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
                    let oldNumber = self.parseCurrencyString(oldVal)
                    let newNumber = self.parseCurrencyString(text)
                    if newChar != nil && oldNumber != nil
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + initialdelay){
                            if newNumber! > oldNumber!
                            {
                                lbl.incrementValue(endValue: newChar!, duration: initialduration)
                            }
                            else
                            {
                                lbl.decrementValue(endValue: newChar!, duration: initialduration)
                            }
                            initialduration += self.durationIncrement
                            
                        }
                        initialdelay += self.delay
                    }
                }
            }
        }
    }
    
    public func parseCurrencyString(_ value: String) -> Double?
    {
        var decimalSep = NSLocale.current.decimalSeparator! as String
        var groupSep = NSLocale.current.groupingSeparator! as String
        
        //Ok since everyone has different regional settings on their phone and can always change number format
        //we're gonna do this the old school way.
        //check for the last occurence of dot and comma characters in the string and decide based on that
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
            //the typed in number has dot as a decimal separator.
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

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
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

extension CALayer {
    //Animate character sliding up
    func animateUp(duration:CFTimeInterval, delay: Double) {
        let animation = CATransition()
        animation.beginTime = CACurrentMediaTime() + delay
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    //Animate character sliding down, maybe we can use this if the new value is smaller than the last
    func animateDown(duration:CFTimeInterval) {
        let animation = CATransition()
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = duration
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        self.add(animation, forKey: CATransitionType.push.rawValue)
    }
}
