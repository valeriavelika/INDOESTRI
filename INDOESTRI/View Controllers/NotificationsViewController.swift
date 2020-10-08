// Valeria Velika 29270162
//
//  NotificationsViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 16/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class is the View Controller class for the Notifications Screen
// In this app, only the workshop reminder (myWorkshops) notification will be implemented
class NotificationsViewController: UIViewController {

    @IBOutlet var newWorkshopsSwitch: UISwitch!
    @IBOutlet var myWorkshopsSwitch: UISwitch!
    @IBOutlet var favouriteSwitch: UISwitch!
    @IBOutlet var discountSwitch: UISwitch!
    
    let userDefaults = UserDefaults.standard
    
    var workshops: [WorkshopDetails]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Styles.styleSwitch(newWorkshopsSwitch)
        Styles.styleSwitch(myWorkshopsSwitch)
        Styles.styleSwitch(favouriteSwitch)
        Styles.styleSwitch(discountSwitch)
        
        // Get the stored switch setting from user defaults
        newWorkshopsSwitch.isOn = userDefaults.bool(forKey: "newWorkshops")
        myWorkshopsSwitch.isOn = userDefaults.bool(forKey: "myWorkshops")
        favouriteSwitch.isOn = userDefaults.bool(forKey: "favourite")
        discountSwitch.isOn = userDefaults.bool(forKey: "discount")
    }
    
    @IBAction func newWorkshopSwitchTapped(_ sender: UISwitch) {
        // Store the switch setting in user default
        userDefaults.set(sender.isOn, forKey: "newWorkshops")
    }
    
    @IBAction func myWorkshopsSwitchTapped(_ sender: UISwitch) {
        // Store the switch setting in user default
        userDefaults.set(sender.isOn, forKey: "myWorkshops")
        
        let notificationCenter = UNUserNotificationCenter.current()
        if sender.isOn {
            // Set the notification back on
            setNotifications()
        } else {
            // Remove the all the current notifications
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["workshopReminder"])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: ["workshopReminder"])
        }
    }
    
    @IBAction func favouriteSwitchTapped(_ sender: UISwitch) {
        // Store the switch setting in user default
        userDefaults.set(sender.isOn, forKey: "favourite")
    }
    
    @IBAction func discountSwitchTapped(_ sender: UISwitch) {
        // Store the switch setting in user default
        userDefaults.set(sender.isOn, forKey: "discount")
    }
    
    // This function is called to set the notifications for the current upcoming workshop back on
    func setNotifications() {
        // Set a notification reminder for upcoming workshop(s)
        for workshop in workshops! {
            let content = UNMutableNotificationContent()
            content.title = "Workshop Reminder"
            content.body = "You've got a \(workshop.workshopTitle) workshop tomorrow!"

            // Remind 24 hours before the start of the workshop
            let date = workshop.date.addingTimeInterval(-86400)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: "workshopReminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}
