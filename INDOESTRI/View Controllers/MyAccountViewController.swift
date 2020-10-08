// Valeria Velika 29270162
//
//  MyAccountViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase

// This class is the View Controller class for the My Account Screen, which is the fourth tab bar
class MyAccountViewController: UIViewController {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var workshopsButton: UIButton!
    @IBOutlet weak var cardButton: UIButton!
    
    @IBOutlet weak var FAQButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var homeVC: HomeViewController!
    var navController: UINavigationController!
    
    let authController = Auth.auth()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navController = tabBarController?.viewControllers![0] as? UINavigationController
        homeVC = navController?.topViewController as? HomeViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the user object from the AppDelegate
        user = appDelegate.user
        tabBarController?.tabBar.isHidden = false
        
        // Set the greetings label using the user's name
        greetingsLabel.text = "Hi \(user?.name ?? "")!"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    // Go back to the My Workshop screen which is the second tab bar (index 1)
    @IBAction func workshopButtonTapped(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }
    
    // This function is called when the user taps on the sign out button
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try authController.signOut()
            
            // Go back to the Sign In screen
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.isHidden = true
            self.view.window?.rootViewController = navigationController
            self.view.window?.makeKeyAndVisible()
        } catch {
            print("Failed to sign out")
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationsSegue" {
            let destination = segue.destination as! NotificationsViewController
            destination.workshops = homeVC.upcomingWorkshops
        }
    }
    

}
