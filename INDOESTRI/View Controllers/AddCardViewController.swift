// Valeria Velika 29270162
//
//  AddCardViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 27/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Reachability
import Firebase

// This class is the View Controller class for the Add Card Screen
class AddCardViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameOnCardTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var saveCardButton: UIButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    let database = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Styles.styleButton(saveCardButton)
        
        nameOnCardTextField.delegate = self
        cardNumberTextField.delegate = self
        cvvTextField.delegate = self
        expDateTextField.delegate = self
        
        user = appDelegate.user
        reachability = appDelegate.reachability
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
    
    // This function is used so that the keyboard collapses when the user taps Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // This function handles the changes in the Reachability object whenever the internet connection changes
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
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
            Styles.styleUnavailableButton(saveCardButton)
            internetConnection = 0
        } else {
            Styles.styleButton(saveCardButton)
            internetConnection = 1
            errorMessageLabel.alpha = 0
        }
    }
    
    // This function checks the input of the user as they typed in each character
    // True is returned if the newly added character is acceptable or valid
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only numberical values
        if textField == expDateTextField || textField == cvvTextField || textField == cardNumberTextField {
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
        
        // Get the text in the textfield before adding the newly added character
        let currentText = textField.text
        // Get the text after adding the newly added character
        let newText = currentText!.replacingCharacters(in: Range(range, in: currentText!)!, with: string)
        
        if textField == expDateTextField {
            // EXP Date should not be more than 5 characters, including the "/"
            if newText.count == 6 {
                return false
            }
            
            if newText.count == 1 {
                // The first digit of month should be 0 or 1
                if Int(string)! > 1 {
                    return false
                }
            } else if newText.count == 2 {
                // If the first month digit is 1, the second month digit should be 1 or 2
                if Int(newText.prefix(1)) == 1 {
                    let valid = [1, 2]
                    if !(valid.contains(Int(string)!)) {
                        return false
                    }
                }
            } else if newText.count == 4 {
                // The first digit of year should be 2 or 3 (2020-2039)
                if (Int(string)! == 2) || (Int(string)! == 3) {
                    return true
                } else {
                    return false
                }
            }
            
            textField.text = newText
            if newText.count == 2 {
                textField.text?.append("/")
            }
            
            return false
        }
        
        if textField == cvvTextField {
            // CVV should not be more than 3 digits
            if newText.count == 4 {
                return false
            }
        }
        
        if textField == cardNumberTextField {
            // Card number should not be more than 16 digits
            if newText.count == 17 {
                return false
            }
        }
        
        return true
    }

    // This function validates the input in the 4 TextFields
    // An error message will be returned if the user does not pass the validation
    // Otherwise nil will be returned
    func validateInput() -> String? {
        // Check that all fields are filled in.
        if nameOnCardTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        cardNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        expDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        cvvTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        if cardNumberTextField.text!.count < 16 {
            return "Please enter a valid card number"
        }
        
        if expDateTextField.text!.count < 5 {
            return "Please enter a valid expiration date"
        }
        
        if cvvTextField.text!.count < 3 {
            return "Please enter a valid security code"
        }
        
        return nil
    }
    
    // This function is called when the user tapped the Saved Card button
    @IBAction func saveCardTapped(_ sender: Any) {
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
                // If the input is valid, we will assume that the card added is a valid card number
                // Add the card details to the database inside a list of "valid" cards
                let name = nameOnCardTextField.text!
                let balance = "5000000"
                let cardNumber = cardNumberTextField.text!
                let cvv = cvvTextField.text!
                let expMonth = expDateTextField.text!.prefix(2)
                let expYear = expDateTextField.text!.suffix(2)
                
                let cardsRef = database.collection("cards")
                let newCardRef = cardsRef.addDocument(data: [
                    "name": name,
                    "balance": balance,
                    "cardNumber": cardNumber,
                    "cvv": cvv,
                    "expMonth": expMonth,
                    "expYear": expYear
                ])
                
                // Store the card in the user account
                let userRef = database.collection("users").document(self.user!.dataID)
                userRef.updateData([
                    "card": FieldValue.arrayUnion([newCardRef.documentID])
                ])
                
                let card = Card(id: newCardRef.documentID, name: name, cardNumber: cardNumber, expMonth: String(expMonth), expYear: String(expYear), cvv: cvv, balance: balance)
                appDelegate.savedCards.append(card)
                navigationController?.popViewController(animated: true)
            }
        }
        return
    }
}
