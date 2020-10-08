//
//  Styles.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 11/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import Foundation
import UIKit

// This class gives the UIElements a consistent look by defining properties here
// These styles will be applied to the UIElement when the screen loads
class Styles {
    // Style for the Text Fields
    static func styleTextField(_ textField: UITextField) {
        let bottomLine = CALayer()
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
    
    // Style to format the amount seperated by thousands
    static func styleAmountFeeLabel(_ label: UILabel, string: String, amount: Int) {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = NumberFormatter.Style.decimal
        let formattedAmount = formatter.string(from: NSNumber(value: amount))
        label.text = string + formattedAmount!
    }
    
    // Style for the Red Button
    static func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor(named: "Red Logo")
    }
    
    // Style for Grey Button which means that there is no internet connection and it is not clickable
    static func styleUnavailableButton(_ button: UIButton) {
        button.layer.cornerRadius = 15
        button.backgroundColor = .lightGray
    }
    
    // Style for the switch
    static func styleSwitch (_ switchToggle: UISwitch) {
        switchToggle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
}
