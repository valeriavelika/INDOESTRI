// Valeria Velika 29270162
//
//  SuccessfulTransactionViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 22/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase

// This class is the View Controller class for the Successful Transaction Screen
class SuccessfulTransactionViewController: UIViewController {
    var workshop: WorkshopDetails?
    var ticketNumber: Int = 0
    
    let database = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user: User?
    
    var navController: UINavigationController!

    @IBOutlet weak var workshopImage: UIImageView!
    @IBOutlet weak var workshopTitleLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var numberOfTicketsLabel: UILabel!
    let image = [UIImage(named: "ukulele"), UIImage(named: "pottery"), UIImage(named: "apron_making")]
    
    @IBOutlet weak var gotItButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = appDelegate.user
        
        Styles.styleButton(gotItButton)
        
        // Fill in the workshop details
        workshopTitleLabel.text = workshop?.workshopTitle
        instructorLabel.text = workshop?.workshopInstructor
        dateLabel.text = "Date: \(workshop?.workshopDate ?? "") (\(workshop?.workshopTime ?? ""))"
        durationLabel.text = "Duration: \(workshop?.workshopDuration ?? "")"
        numberOfTicketsLabel.text = "\(ticketNumber)X"
        workshopImage.image = workshop?.workshopImage
        
        addWorkshopToUser()
        decreaseRemainingSeats()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    // Tapping the Got It button will take the user to the second tab bar (index 1) which shows a list of current workshops
    @IBAction func gotItButton(_ sender: Any) {
        tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }
    
    // This function will add the workshop to the list of workshops the current user registered in
    func addWorkshopToUser() {
        let userRef = database.collection("users").document(self.user!.dataID)
        
        userRef.updateData([
            "myWorkshop": FieldValue.arrayUnion([workshop!.id])
        ])
        
        let userDefaults = UserDefaults.standard
        
        // Check the notification setting
        if userDefaults.bool(forKey: "myWorkshops") {
            // Set a notification reminder for your upcoming workshop
            let content = UNMutableNotificationContent()
            content.title = "Workshop Reminder"
            content.body = "You've got a \(workshop!.workshopTitle) workshop tomorrow!"

            let date = workshop!.date.addingTimeInterval(-86400)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: "workshopReminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    // This function will decrease the remaining seats according to the number of tickets the user bought
    func decreaseRemainingSeats() {
        let workshopRef = database.collection("workshops").document(workshop!.id)
        let remainingSeats = workshop!.remainingSeats - ticketNumber
        workshopRef.updateData([
            "remainingSeats": String(remainingSeats)
        ])
    }
    
    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "successfulTransactionTicketSegue" {
            let _ = segue.destination as! MyWorkshopsViewController
        }
    }*/
    

}
