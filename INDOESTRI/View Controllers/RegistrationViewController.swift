// Valeria Velika 29270162
//
//  RegistrationViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 22/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Reachability

// This class is the View Controller class for the Registration Screen
class RegistrationViewController: UIViewController, UITextFieldDelegate {
    var workshop: WorkshopDetails?
    
    @IBOutlet weak var workshopTitleLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var courseFeeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var ticketFeeLabel: UILabel!
    @IBOutlet weak var totalFeeLabel: UILabel!
    @IBOutlet weak var remainingSeatsLabel: UILabel!
    
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var amount: Int = 1
    var courseFee: Int = 0
    var remainingSeats: Int = 0
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = appDelegate.user
        reachability = appDelegate.reachability
        
        Styles.styleButton(checkoutButton)
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        // Auto fill the textfield for faster data entry
        nameTextField.text = user?.name
        emailTextField.text = user?.email
        phoneTextField.text = user?.phone
        
        // Fill in the workshop details
        workshopTitleLabel.text = workshop?.workshopTitle
        instructorLabel.text = workshop?.workshopInstructor
        dateLabel.text = "Date: \(workshop?.workshopDate ?? "") (\(workshop?.workshopTime ?? ""))"
        durationLabel.text = "Duration: \(workshop?.workshopDuration ?? "")"
        courseFee = workshop!.workshopFee
        ticketsLabel.text = String(amount)
        
        remainingSeats = Int(workshop!.remainingSeats)
        if remainingSeats <= 5{
            remainingSeatsLabel.text = "\(remainingSeats) remaining seats"
        } else {
            remainingSeatsLabel.isHidden = true
        }
        
        Styles.styleAmountFeeLabel(courseFeeLabel, string: "IDR ", amount: courseFee)
        Styles.styleAmountFeeLabel(ticketFeeLabel, string: "IDR ", amount: courseFee)
        Styles.styleAmountFeeLabel(totalFeeLabel, string: "IDR ", amount: (courseFee * amount))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the observer for the reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        // Display the button according to the internet connectivity
        switch reachability!.connection {
            case .unavailable:
                changeButton(connection: 0)
            default:
                changeButton(connection: 1)
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
            Styles.styleUnavailableButton(checkoutButton)
            internetConnection = 0
        } else {
            Styles.styleButton(checkoutButton)
            internetConnection = 1
            errorMessageLabel.alpha = 0
        }
    }
    
    // This function is used so that the keyboard collapses when the user taps Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // This function checks the input of the user as they typed in each character
    // True is returned if the newly added character is acceptable or valid
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Phone number should only have numerical values
        if textField == phoneTextField {
            // Check the newly added character
            if string == "" {
                return true
            }
            
            // Check if it is an integer
            if let _ = Int(string) {
                // Integer is entered
            } else {
                return false
            }
        }
        
        return true
    }
    
    // This function is called when the user increases the number of tickets
    // The maximum limit is 5 tickets
    @IBAction func plusButton(_ sender: Any) {
        amount = Int(ticketsLabel.text!)!
        if (amount + 1) <= 5 && !((amount + 1) > remainingSeats)  {
            ticketsLabel.text = String(amount + 1)
            amount += 1
            Styles.styleAmountFeeLabel(totalFeeLabel, string: "IDR ", amount: (courseFee * amount))
        }
    }
    
    // This function is called when the user decreases the number of tickets
    // The minimum is 1 ticket
    @IBAction func minusButton(_ sender: Any) {
        amount = Int(ticketsLabel.text!)!
        if amount > 1 {
            ticketsLabel.text = String(amount - 1)
            amount -= 1
            Styles.styleAmountFeeLabel(totalFeeLabel, string: "IDR ", amount: (courseFee * amount))
        }
    }
    
    // This function is called when the checkout button is tapped
    @IBAction func checkoutButton(_ sender: Any) {
        // Check the internet connection
        if internetConnection == 0 {
            errorMessageLabel.alpha = 1
            errorMessageLabel.text = "No internet connection"
        } else {
            // Validate user input
            let error = validateInput()
            
            if error != nil {
                // there is an error in the input so show error message
                errorMessageLabel.text = error!
                errorMessageLabel.alpha = 1
            } else {
                performSegue(withIdentifier: "checkoutSegue", sender: nil)
            }
        }
        return
    }
    
    // This function validates the input in the 3 TextFields
    // An error message will be returned if the user does not pass the validation
    // Otherwise nil will be returned
    func validateInput() -> String? {
        // Check that all fields are filled in.
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkoutSegue" {
            let destination = segue.destination as! CheckoutViewController
            destination.totalFee = courseFee * amount
            destination.workshop = workshop
            destination.ticketNumber = amount
        }
    }
    

}
