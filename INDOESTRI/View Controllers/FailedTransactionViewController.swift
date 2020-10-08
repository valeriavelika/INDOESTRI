// Valeria Velika 29270162
//
//  FailedTransactionViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 22/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class is the View Controller class for the Failed Transaction Screen
// However, this is not used as all the users card are assumed as all valid cards
class FailedTransactionViewController: UIViewController {

    @IBOutlet weak var okayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styles.styleButton(okayButton)
    }
    
    @IBAction func okayButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
