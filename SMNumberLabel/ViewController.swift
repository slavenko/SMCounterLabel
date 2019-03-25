//
//  ViewController.swift
//  SMCounterLabel
//
//  Created by Slavenko on 1/26/19.
//  Copyright © 2019 Slavenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: SMCounterLabel!
    @IBOutlet weak var dummyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.formatType = .decimal
        
        label.setValue(1234.67)
        dummyLabel.text = "\(label.getValue())"
    }
    
    @IBAction func updateLabel(_ sender: Any) {
        let randomNumber = Double.random(min: 1, max: 2000)
        label.setValue(randomNumber)
        dummyLabel.text = "\(label.getValue())"
    }
}

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

