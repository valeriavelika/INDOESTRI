// Valeria Velika 29270162
//
//  CheckoutViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 22/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Reachability

// This class is the View Controller class for the Checkout Screen
class CheckoutViewController: UIViewController {
    var workshop: WorkshopDetails?
    var savedCards = [Card]()
    var ticketNumber: Int = 0
    
    var totalFee: Int = 0
    var selected: Int = 0
    
    let DEBIT_CREDIT = 0
    let APPLE_PAY = 1
    let SAVED_CARD = 2
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var debitCreditButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var savedCardButton1: UIButton!
    @IBOutlet weak var savedCardButton2: UIButton!
    @IBOutlet weak var savedCardButton3: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var noInternetLabel: UILabel!
    @IBOutlet weak var savedCardLabel: UILabel!
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachability = appDelegate.reachability
        
        Styles.styleButton(nextButton)
        Styles.styleAmountFeeLabel(totalLabel, string: "IDR ", amount: totalFee)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the observer for the reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        savedCards = appDelegate.savedCards
        setSavedCardView()
        
        // Display the button according to the internet connectivity
        switch reachability!.connection {
            case .unavailable:
                changeButton(connection: 0)
            default:
                changeButton(connection: 1)
        }
    }
    
    // This function will populate the buttons with the saved card number (if any)
    func setSavedCardView() {
        savedCardButton1.alpha = 0
        savedCardButton2.alpha = 0
        savedCardButton3.alpha = 0
        savedCardLabel.alpha = 0
        
        if savedCards.count == 0 {
            return
        }
        
        savedCardLabel.alpha = 1
        if savedCards.count >= 1 {
            savedCardButton1.alpha = 1
            savedCardButton1.setTitle("**** \(savedCards[0].cardNumber.suffix(4))", for: .normal)
        }
        
        if savedCards.count >= 2 {
            savedCardButton2.alpha = 1
            savedCardButton2.setTitle("**** \(savedCards[1].cardNumber.suffix(4))", for: .normal)
        }
        
        if savedCards.count >= 3 {
            savedCardButton3.alpha = 1
            savedCardButton3.setTitle("**** \(savedCards[2].cardNumber.suffix(4))", for: .normal)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove the observer for the reachability
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    // This function handles the changes in the Reachability object whenever the internet connection changes
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        // Check the internet connection and style the button accordingly
        switch reachability.connection {
            case .unavailable:
                changeButton(connection: 0)
            default:
                changeButton(connection: 1)
        }
    }
    
    // This function changes the style of the button according to the internet connection
    func changeButton(connection: Int) {
        if connection == 0 {
            Styles.styleUnavailableButton(nextButton)
            internetConnection = 0
        } else {
            Styles.styleButton(nextButton)
            internetConnection = 1
            noInternetLabel.alpha = 0
        }
    }
    
    // This function will change the circle image if the debit credit option is clicked
    @IBAction func debitCreditOption(_ sender: Any) {
        debitCreditButton.setImage(UIImage(named: "circle.filled"), for: .normal)
        applePayButton.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton1.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton2.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton3.setImage(UIImage(named: "circle"), for: .normal)
        selected = DEBIT_CREDIT
    }
    
    // This function will change the circle image if the apple pay option is clicked
    @IBAction func applePayOption(_ sender: Any) {
        debitCreditButton.setImage(UIImage(named: "circle"), for: .normal)
        applePayButton.setImage(UIImage(named: "circle.filled"), for: .normal)
        savedCardButton1.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton2.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton3.setImage(UIImage(named: "circle"), for: .normal)
        selected = APPLE_PAY
    }
    
    // This function will change the circle image if the first saved card option is clicked
    @IBAction func savedCardOption(_ sender: Any) {
        debitCreditButton.setImage(UIImage(named: "circle"), for: .normal)
        applePayButton.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton1.setImage(UIImage(named: "circle.filled"), for: .normal)
        savedCardButton2.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton3.setImage(UIImage(named: "circle"), for: .normal)
        selected = SAVED_CARD
    }
    
    // This function will change the circle image if the second saved card option is clicked
    @IBAction func savedCard2Option(_ sender: Any) {
        debitCreditButton.setImage(UIImage(named: "circle"), for: .normal)
        applePayButton.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton1.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton2.setImage(UIImage(named: "circle.filled"), for: .normal)
        savedCardButton3.setImage(UIImage(named: "circle"), for: .normal)
        selected = SAVED_CARD
    }
    
    // This function will change the circle image if the third saved card option is clicked
    @IBAction func savedCard3Option(_ sender: Any) {
        debitCreditButton.setImage(UIImage(named: "circle"), for: .normal)
        applePayButton.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton1.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton2.setImage(UIImage(named: "circle"), for: .normal)
        savedCardButton3.setImage(UIImage(named: "circle.filled"), for: .normal)
        selected = SAVED_CARD
    }
    
    // This function is called when the user clicks on the next button
    @IBAction func nextButton(_ sender: Any) {
        if internetConnection == 0 {
            noInternetLabel.alpha = 1
        } else {
            if selected == SAVED_CARD || selected == APPLE_PAY {
                // Move to the Successful Transaction screen
                performSegue(withIdentifier: "successfulTransactionSegue", sender: nil)
            } else {
                // As the credit debit option is choosen, move to the Card Detail screen
                performSegue(withIdentifier: "cardDetailSegue", sender: nil)
            }
        }
        return
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successfulTransactionSegue" {
            let destination = segue.destination as! SuccessfulTransactionViewController
            destination.workshop = workshop
            destination.ticketNumber = ticketNumber
        }
            
        else if segue.identifier == "cardDetailSegue" {
            let destination = segue.destination as! CardDetailsViewController
            destination.workshop = workshop
            destination.ticketNumber = ticketNumber
            destination.totalFee = totalFee
        }
        
    }
    

}
