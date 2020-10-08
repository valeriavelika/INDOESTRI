// Valeria Velika 29270162
//
//  HomeViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

// This class is the View Controller class for the Home Screen, which is the first tab bar
// This class contains the logic to display the workshops and do most of the work for the changes in Firebase
class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!

    let CELL_WORKSHOP = "workshopCell"
    
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    let itemsPerRow: CGFloat = 1
    
    var workshops = [WorkshopDetails]()
    var myFavourites = [WorkshopDetails]()
    var clickedWorkshop: WorkshopDetails?
    
    var workshopsRef: CollectionReference!
    var storageRef: StorageReference!
    let authController = Auth.auth()
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    var upcomingWorkshops = [WorkshopDetails]()
    var pastWorkshops = [WorkshopDetails]()
    var savedCards = [Card]()
    var userWorkshopID = [String]()
    var favouriteID = [String]()
    var cardID = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        
        workshopsRef = database.collection("workshops")
        
        // Get the user details from the AppDelegate
        user = appDelegate.user
        favouriteID = appDelegate.favouriteID
        userWorkshopID = appDelegate.userWorkshopID
        
        // Load the workshops data
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkUpcomingWorkshop()
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    // This function handles the code whenever the heart button on the top right corner is clicked
    // The favourite list will be updated according to the action
    @IBAction func favouriteButtonClicked(_ sender: UIButton) {
        let workshop = workshops[sender.tag]
        user = appDelegate.user
        
        let userRef = database.collection("users").document(self.user!.dataID)
        
        if myFavourites.contains(workshop) {
            // Remove the favourited workshop from the database
            userRef.updateData([
                "favourite": FieldValue.arrayRemove([workshop.id])
            ])
            myFavourites.remove(at: findWorkshopIndex(workshop: workshop))
        } else {
            // Store the favourited workshop in the database
            userRef.updateData([
                "favourite": FieldValue.arrayUnion([workshop.id])
            ])
            myFavourites.append(workshop)
        }
        
        collectionView.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
    }
    
    // This function is used to find the index of the given workshop in the favourites array
    func findWorkshopIndex(workshop: WorkshopDetails) -> Int {
        for (index, favWorkshop) in myFavourites.enumerated() {
            if favWorkshop == workshop {
                return index
            }
        }
        
        return 0
    }
    
    // This function will check if there is any new changes to the workshop that the user has registered to
    func checkUpcomingWorkshop() {
        for workshop in workshops {
            var index: Int!
            
            // Only check for upcoming workshop
            // Ignore past workshop
            let upcoming = workshop.date > Date()
            if !upcoming {
                index = workshops.firstIndex(of: workshop)
                workshops.remove(at: index!)
                
                if myFavourites.contains(workshop) {
                    index = myFavourites.firstIndex(of: workshop)
                    myFavourites.remove(at: index!)
                }
                
                if upcomingWorkshops.contains(workshop) {
                    index = upcomingWorkshops.firstIndex(of: workshop)
                    upcomingWorkshops.remove(at: index!)
                    pastWorkshops.append(workshop)
                }
                
                collectionView.reloadData()
            }
        }
    }
    
    // Specify the number of items in the sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workshops.count
    }
    
    // Set up the cell in a particular row and section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_WORKSHOP, for: indexPath) as! WorkshopCollectionViewCell
        cell.dateLabel.text = "\(workshops[indexPath.row].workshopDate) (\(workshops[indexPath.row].workshopTime))"
        cell.workshopTitleLabel.text = workshops[indexPath.row].workshopTitle
        cell.instructorLabel.text = "with \(workshops[indexPath.row].workshopInstructor)"
        cell.workshopImage.image = workshops[indexPath.row].workshopImage

        cell.soldOutImage.alpha = 0
        
        // Check the remaining seats and see if there should be a reminder for it and or it solds out
        if workshops[indexPath.row].remainingSeats <= 5 {
            if workshops[indexPath.row].remainingSeats == 0 {
                cell.soldOutImage.alpha = 1
                cell.remainingSeatsLabel.text = ""
            } else {
                cell.remainingSeatsLabel.text = "\(workshops[indexPath.row].remainingSeats) remaining seats"
            }
        } else {
            cell.remainingSeatsLabel.text = ""
        }
        
        // Check the favourited workshop and assign the heart image accordingly
        if myFavourites.contains(workshops[indexPath.row]) {
            cell.favouritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            cell.favouritesButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        // Set the tag and handler when the heart button is tapped
        cell.favouritesButton.tag = indexPath.row
        cell.favouritesButton.addTarget(self, action: #selector(favouriteButtonClicked(_:)), for: .touchUpInside)
        
        cell.contentView.layer.cornerRadius = 8.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
    
        return cell
    }
    
    // This function will be executed when a cell is clicked. It will open the Workshop Details Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the workshop that is clicked to be passed on to the next view controller
        clickedWorkshop = workshops[indexPath.row]
        
        // Workshop that solds out will not trigger the segue
        if clickedWorkshop?.remainingSeats == 0 {
            return
        }
        
        performSegue(withIdentifier: "workshopDetailsSegue", sender: nil)
        return
    }
    
    // The following 3 function are delegate to manipulate the cell size
    // This function specifies the size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth/itemsPerRow
        let height = widthPerItem/1.6
        return CGSize(width: widthPerItem, height: height)
    }
    
    // Returns the hardcoded inset defines at the top
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // Returns the left part of section inset
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "workshopDetailsSegue" {
            let destination = segue.destination as! WorkshopDetailsViewController
            destination.workshop = clickedWorkshop
        }
    }
    
    // This function will get the workshop data from Firebase and populate the Collection View
    func loadData() {
        workshops = []
        
        // Create a Snapshot listener
        workshopsRef.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            querySnapshot.documentChanges.forEach({(change) in
                // Get documents which are newly added or are modified
                if (change.type == .added || change.type == .modified) {
                    let data = change.document.data()
                    
                    // Parse the data
                    let id = change.document.documentID
                    print(id)
                    let workshopTitle = data["workshopTitle"] as! String
                    let workshopDate = data["workshopDate"] as! String
                    let workshopInstructor = data["workshopInstructor"] as! String
                    let remainingSeats = Int(data["remainingSeats"] as! String) ?? 0
                    let workshopDescription = data["workshopDescription"] as! String
                    let imageURL = data["imageURL"] as! String
                    let workshopDuration = data["workshopDuration"] as! String
                    let workshopTime = data["workshopTime"] as! String
                    let workshopFeeString = data["workshopFee"] as! String
                    let workshopFee = Int(workshopFeeString) ?? 0
                    let dateTimestamp = data["date"] as! Timestamp
                    let date = Date(timeIntervalSince1970: TimeInterval(dateTimestamp.seconds))
                    
                    if change.type == .added {
                        var image: UIImage?
                        // Download the image of the workshop from the storage
                        self.storage.reference(forURL: imageURL).getData(maxSize: 5 * 1024 * 1024) { (data, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                image = UIImage(data: data!)
                                
                                // Create the WorkshopDetails object when the image is successfully downloaded
                                let workshop = WorkshopDetails(id: id, workshopImage: image!, workshopTitle: workshopTitle, workshopDate: workshopDate, workshopInstructor: workshopInstructor, remainingSeats: remainingSeats, workshopDescription: workshopDescription, workshopDuration: workshopDuration, workshopTime: workshopTime, workshopFee: workshopFee, date: date)
                                
                                // Check the date of the workshop and appends it to the corrent array (current, upcoming and/or past)
                                let upcoming = workshop.date > Date()
                                if upcoming {
                                    self.workshops.append(workshop)
                                }
                                
                                // Sort the workshops in ascending order based on the date
                                self.workshops.sort { (first, second) -> Bool in
                                    return first.date < second.date
                                }
                                
                                // Check if the workshop is favourited by the user
                                self.favouriteID = self.appDelegate.favouriteID
                                if self.favouriteID.contains(workshop.id) && upcoming {
                                    self.myFavourites.append(workshop)
                                }
                                
                                // Check if it is a workshop that the user is/was registered for
                                self.userWorkshopID = self.appDelegate.userWorkshopID
                                if self.userWorkshopID.contains(workshop.id) {
                                    if upcoming {
                                        if !(self.upcomingWorkshops.contains(workshop)) {
                                            self.upcomingWorkshops.append(workshop)
                                        }
                                    } else {
                                        if !(self.pastWorkshops.contains(workshop)) {
                                            self.pastWorkshops.append(workshop)
                                        }
                                    }
                                }
                                
                                self.collectionView.reloadData()
                            }
                        }
                    } else if change.type == .modified {
                        // Update the modified workshop details
                        let workshop = WorkshopDetails(id: id, workshopImage: UIImage(named: "cajon")!, workshopTitle: workshopTitle, workshopDate: workshopDate, workshopInstructor: workshopInstructor, remainingSeats: remainingSeats, workshopDescription: workshopDescription, workshopDuration: workshopDuration, workshopTime: workshopTime, workshopFee: workshopFee, date: date)
                        
                        for (index, oldWorkshop) in self.workshops.enumerated() {
                            if oldWorkshop.id == workshop.id {
                                workshop.workshopImage = oldWorkshop.workshopImage
                                self.workshops[index] = workshop
                                
                                break
                            }
                        }
                        
                        self.userWorkshopID = self.appDelegate.userWorkshopID
                        if self.userWorkshopID.contains(workshop.id) && workshop.date > Date() {
                            if !(self.upcomingWorkshops.contains(workshop)) {
                                self.upcomingWorkshops.append(workshop)
                                print(self.upcomingWorkshops.count)
                            }
                        }
                    }
                }
            })
        }
    }
}
