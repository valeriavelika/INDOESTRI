// Valeria Velika 29270162
//
//  ProfileViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 21/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase
import Reachability

// This class is the View Controller class for Profile Screen
class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let authController = Auth.auth()
    var user: User?
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = appDelegate.user
        reachability = appDelegate.reachability
        
        errorMessage.alpha = 0
        Styles.styleButton(updateButton)
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        newPasswordTextField.delegate = self
        
        nameTextField.text = user?.name
        emailTextField.text = user?.email
        phoneTextField.text = user?.phone
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the observer for the reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        // Check the internet connection and style the button accordingly
        switch reachability!.connection {
            case .unavailable:
                changeButton(connection: 0)
            default:
                changeButton(connection: 1)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            Styles.styleUnavailableButton(updateButton)
            internetConnection = 0
        } else {
            Styles.styleButton(updateButton)
            internetConnection = 1
            errorMessage.alpha = 0
        }
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
    
    // This function is called when the user tapped the update button
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check for internet connection
        if internetConnection == 0 {
            errorMessage.alpha = 1
            errorMessage.text = "No internet connection"
            return
        }
        
        let error = validateInput()
        
        if error != nil {
            // there is an error in the input so show error message
            errorMessage.text = error!
            errorMessage.alpha = 1
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: user!.email, password: passwordTextField.text!)
        authController.currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                print("User re-authenticated")
                // Update the user details in Firebase
                let userDataRef = Firestore.firestore().collection("users").document(self.user!.dataID)
                userDataRef.updateData([
                    "name": self.nameTextField.text!,
                    "phone": self.phoneTextField.text!,
                ]) { (error) in
                    if let error = error {
                        print("Error updating document: \(error)")
                        self.errorMessage.text = error.localizedDescription
                        self.errorMessage.alpha = 1
                        return
                    } else {
                        print("Document successfully updated")
                        
                        // Update the email if there is a change
                        if self.user?.email != self.emailTextField.text {
                            self.authController.currentUser?.updateEmail(to: self.emailTextField.text!, completion: { (error) in
                                if let error = error {
                                    print("Error updating email: \(error)")
                                    self.errorMessage.text = error.localizedDescription
                                    self.errorMessage.alpha = 1
                                    return
                                } else {
                                    print("Email successfully updated")
                                    self.appDelegate.user?.email = self.emailTextField.text!
                                }
                            })
                        }
                        
                        // Update the password if the new password is specified
                        if !(self.newPasswordTextField.text!.isEmpty) {
                            self.authController.currentUser?.updatePassword(to: self.newPasswordTextField.text!, completion: { (error) in
                                if let error = error {
                                    print("Error updating password: \(error)")
                                    self.errorMessage.text = error.localizedDescription
                                    self.errorMessage.alpha = 1
                                    return
                                } else {
                                    print("Password successfully updated")
                                }
                            })
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        })
    }
    
    // This function validates the input in the 3 TextFields
    // An error message will be returned if the user does not pass the validation
    // Otherwise nil will be returned
    func validateInput() -> String? {
        // Check that all fields are filled in.
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all required fields."
        }
        
        if passwordTextField.text!.isEmpty {
            return "Please fill in (old) password to update user details"
        }
        
        // Check password length if password is filled
        if !(newPasswordTextField.text!.isEmpty) {
            if newPasswordTextField.text!.count < 6 {
                return "New password must be at least 6 characters."
            }
        }
        
        return nil
    }
}
