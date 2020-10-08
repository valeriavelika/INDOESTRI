// Valeria Velika 29270162
//
//  SignUpViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 11/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import Reachability

// This class is the View Controller class for the Sign Up screen
// This class contains the logic to create an account for a user
class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var emailNotifications: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let authController = Auth.auth()
    let database = Firestore.firestore()
    var usersRef: CollectionReference!
    var allowEmail = 1
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the Reachability refernece from App Delegate
        reachability = appDelegate.reachability
        
        errorMessage.alpha = 0
        Styles.styleButton(signUpButton)
        
        // Assign the delegate for the Text Fields
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        phoneTextField.delegate = self
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
    
    // This function is called when the user clicked the sign in button
    @IBAction func signInButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
            Styles.styleUnavailableButton(signUpButton)
            internetConnection = 0
        } else {
            Styles.styleButton(signUpButton)
            internetConnection = 1
            errorMessage.alpha = 0
        }
    }
    
    // This function is called whenever the tick button for the email notifications is clicked
    // The image view is changed accordingly
    @IBAction func emailButtonTapped(_ sender: Any) {
        if allowEmail == 0 {
            allowEmail = 1
            emailNotifications.setImage(UIImage(named: "Checkbox"), for: .normal)
        } else {
            allowEmail = 0
            emailNotifications.setImage(UIImage(named: "Square"), for: .normal)
        }
    }
    
    // This function validates the input in the 4 TextFields
    // An error message will be returned if the user does not pass the validation
    // Otherwise nil will be returned
    func validateInput() -> String? {
        // Check that all fields are filled in.
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        
        // Check password length
        if passwordTextField.text!.count < 6 {
            return "Password must be at least 6 characters."
        }
        
        // Check phone number length
        if phoneTextField.text!.count < 10 {
            return "Phone number must have at least 10 digits."
        }
        
        return nil
    }
    
    // This function is called when the user clicked the sign up button
    @IBAction func signUpTapped(_ sender: Any) {
        // Check for internet connection
        if internetConnection == 0 {
            errorMessage.alpha = 1
            errorMessage.text = "No internet connection"
            return
        }
        
        // Check for internet connection
        if internetConnection == 0 {
            errorMessage.alpha = 1
            return
        }
        
        // Validate user input
        let error = validateInput()
        
        if error != nil {
            // there is an error in the input so show error message
            errorMessage.text = error!
            errorMessage.alpha = 1
        } else {
            // Get the user input
            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            authController.createUser(withEmail: email, password: password) { (authResult, error) in
                if error != nil {
                    // There was an error
                    self.errorMessage.text = error?.localizedDescription
                    self.errorMessage.alpha = 1
                } else {
                    // User was created successfully. Store user details in the database
                    self.usersRef = self.database.collection("users")
                    self.usersRef.addDocument(data: [
                        "name": name,
                        "phone": phone,
                        "allowEmails": self.allowEmail,
                        "uid": authResult!.user.uid,
                        "favourite": [],
                        "myWorkshop": [],
                        "card": []
                    ]) { (error) in
                        if error != nil {
                            // There was an error
                            self.errorMessage.text = "Error saving user data"
                            self.errorMessage.alpha = 1
                        }
                    }
                    
                    self.appDelegate.getUserDetails()
                    
                    // Request to allow notifications
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
                        print("User notification granted: \(granted)")
                    }
                    
                    // Transition to Home Screen
                    self.transitionToHome()
                }
            }
        }
    }
    
    // This function is used to navigate to the Home View Controller after the user has successfully sign up
    func transitionToHome() {
        let tabBar = self.storyboard?.instantiateViewController(withIdentifier: "homeTabBar") as! UITabBarController
        self.view.window?.rootViewController = tabBar
        self.view.window?.makeKeyAndVisible()
    }
}
