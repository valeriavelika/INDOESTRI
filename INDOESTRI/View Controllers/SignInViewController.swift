// Valeria Velika 29270162
//
//  SignInViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 11/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Reachability


// This class is the View Controller class for the Sign In screen
// This class contains the logic to sign in a user
class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let authController = Auth.auth()
    let database = Firestore.firestore()
    var usersRef: CollectionReference!
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the Reachability refernece from App Delegate
        reachability = appDelegate.reachability
        
        errorMessage.alpha = 0
        Styles.styleButton(signInButton)
        
        // Assign the delegate for the Text Fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Check if the current user is logged in
        authController.addStateDidChangeListener { (auth, user) in
            if user == nil {
                // New user or user is logged out of Firebase
                print("It's a new user or user is logged out from Firebase")
            } else {
                // Logged in already so go to Home View Controller
                print("User has logged in")
                self.transitionToHome()
            }
        }
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
    
    // This function is called when the user clicked the sign up button
    @IBAction func signUpTapped(_ sender: Any) {
        // Move to the Sign Up View Controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(viewController, animated: true)
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
            Styles.styleUnavailableButton(signInButton)
            internetConnection = 0
        } else {
            Styles.styleButton(signInButton)
            internetConnection = 1
            errorMessage.alpha = 0
        }
    }
    
    // This function validates the input in the 2 TextFields
    // An error message will be returned if the user does not pass the validation
    // Otherwise nil will be returned
    func validateInput() -> String? {
        // Check that all fields are filled in.
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    // This function is called when the user clicked the sign in button
    @IBAction func signInTapped(_ sender: Any) {
        // Check for internet connection
        if internetConnection == 0 {
            errorMessage.alpha = 1
            errorMessage.text = "No internet connection"
            return
        }
        
        // Valildate Input
        let error = validateInput()
        
        if error != nil {
            // there is an error in the input so show error message
            errorMessage.text = error!
            errorMessage.alpha = 1
        } else {
            // Get the user input
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the user
            authController.signIn(withEmail: email, password: password) { (authResult, error) in
                if error != nil {
                    // User failed to sign in
                    self.errorMessage.text = error?.localizedDescription
                    self.errorMessage.alpha = 1
                } else {
                    // User signed in successfully
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
    
    // This function is used to navigate to the Home View Controller after the user has successfully logged in or if the user is logged in already
    func transitionToHome() {
        let tabBar = self.storyboard?.instantiateViewController(withIdentifier: "homeTabBar") as! UITabBarController
        self.view.window?.rootViewController = tabBar
        self.view.window?.makeKeyAndVisible()
    }
}
