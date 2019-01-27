//
//  ViewController.swift
//  SMCounterLabel
//
//  Created by Slavenko on 1/26/19.
//  Copyright © 2019 Slavenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBAction func updateLabel(_ sender: Any) {
        label.setValue(Double.random(min: 100, max: 2000))
        //label.setValue(8234.56)
    }
    @IBOutlet weak var label: SMCounterLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        label.setValue(9876.56)
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

