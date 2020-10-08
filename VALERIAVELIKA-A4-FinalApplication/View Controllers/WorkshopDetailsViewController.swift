// Valeria Velika 29270162
//
//  WorkshopDetailsViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 19/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import SystemConfiguration
import Reachability

// This class is the View Controller class for the Workshop Details Screen
// It will display all the information associated with the workshop
class WorkshopDetailsViewController: UIViewController {
    var workshop: WorkshopDetails?
    var pastWorkshop = "NO"
    
    @IBOutlet weak var workshopImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var registerNowButton: UIButton!
    @IBOutlet var noInternetLabel: UILabel!
    
    // 0 means no internet connection. 1 means that there is an internet connection
    var internetConnection = 0;
    weak var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        reachability = appDelegate.reachability
        
        navigationController?.isNavigationBarHidden = false
        
        // Populate the UIElement with the workshop information
        workshopImage.image = workshop?.workshopImage
        titleLabel.text = workshop?.workshopTitle
        instructorLabel.text = "with \(workshop!.workshopInstructor)"
        dateLabel.text = workshop?.workshopDate
        durationLabel.text = "Duration: \(workshop!.workshopDuration) (\(workshop!.workshopTime))"
        Styles.styleAmountFeeLabel(feeLabel, string: "Course Fee: IDR ", amount: workshop!.workshopFee)
        var desc = workshop?.workshopDescription
        desc = desc?.replacingOccurrences(of: "\\n", with: "\n")
        descriptionLabel.text = desc
        noInternetLabel.alpha = 0
        
        if pastWorkshop == "YES" {
            registerNowButton.alpha = 0
        }
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
            Styles.styleUnavailableButton(registerNowButton)
            internetConnection = 0
        } else {
            Styles.styleButton(registerNowButton)
            internetConnection = 1
            noInternetLabel.alpha = 0
        }
    }
    
    // This function is called when the register button is tapped
    @IBAction func registerButtonTapped(_ sender: Any) {
        if internetConnection == 0 {
            // Segue is not triggered if there is no internet connection
            noInternetLabel.alpha = 1
        } else {
            // Move to the registration segue
            performSegue(withIdentifier: "registrationSegue", sender: nil)
        }
        return
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationSegue" {
            let destination = segue.destination as! RegistrationViewController
            destination.workshop = workshop
        }
    }
    

}
