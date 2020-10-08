// Valeria Velika 29270162
//
//  AppDelegate.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase
import Reachability
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var reachability = try! Reachability()
    let userDefaults = UserDefaults.standard
    var authController: Auth?
    var user: User?
    var userRef: CollectionReference!
    var cardRef: CollectionReference!
    var database: Firestore!

    var savedCards = [Card]()
    var userWorkshopID = [String]()
    var favouriteID = [String]()
    var cardID = [String]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase and get the reference to the Firestore database
        FirebaseApp.configure()
        database = Firestore.firestore()
        
        // Start a Reachibility notifier to inform the application if the phone is connecte to the internet
        do {
          try reachability.startNotifier()
        } catch {
          print("Could not start reachability notifier")
        }
        
        // Set all the switches value to ON by default
        if !userDefaults.bool(forKey: "newWorkshops") {
            userDefaults.set(true, forKey: "newWorkshops")
            userDefaults.set(true, forKey: "myWorkshops")
            userDefaults.set(true, forKey: "favourite")
            userDefaults.set(true, forKey: "discount")
        }
        
        // Get the Authentication Reference
        // If the user is logged in, their details will be obtained
        // Otherwise, they will be taken to the login view controller
        authController = Auth.auth()
        if authController?.currentUser != nil {
            getUserDetails()
        }

        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Stop the Reachibility notifier if application entered the background
        reachability.stopNotifier()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // This function will obtain user details from Firebase
    func getUserDetails() {
        // Get the user ID of the current user
        let userID = authController?.currentUser!.uid
        userRef = database.collection("users")

        userRef.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            querySnapshot.documentChanges.forEach({(change) in
                if (change.type == .added || change.type == .modified) {
                    let data = change.document.data()
                    let uid = data["uid"] as! String
                    
                    // Only accept data changes for current user
                    if uid == userID {
                        let dataID = change.document.documentID
                        let name = data["name"] as! String
                        let phone = data["phone"] as! String
                        let email = self.authController?.currentUser?.email
                        
                        self.user = User(uid: uid, name: name, email: email!, phone: phone, dataID: dataID)
                        
                        self.userWorkshopID = data["myWorkshop"] as! [String]
                        self.favouriteID = data["favourite"] as! [String]
                        self.cardID = data["card"] as! [String]
                        
                        // Get the cards (if any) saved in the user's account
                        self.getUserCard()
                    }
                }
            })
        }
    }
    
    
    // This function will retrieve the card (if any) saved in the user's account
    func getUserCard() {
        cardRef = database.collection("cards")
        cardRef.getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self.savedCards = []
            for id in self.cardID {
                for document in querySnapshot.documents {
                    // From a list of valid cards from the database, find the one that belongs to the current user
                    if document.documentID == id {
                        let data = document.data()
                        
                        // Parse the document obtained into a Card object
                        let id = document.documentID
                        let name = data["name"] as! String
                        let cardNumber = data["cardNumber"] as! String
                        let expMonth = data["expMonth"] as! String
                        let expYear = data["expYear"] as! String
                        let cvv = data["cvv"] as! String
                        let balance = data["balance"] as! String
                        
                        let card = Card(id: id, name: name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvv: cvv, balance: balance)
                        if !(self.savedCards.contains(card)) {
                            self.savedCards.append(card)
                        }
                        break
                    }
                }
            }
        }
    }
}


