// Valeria Velika 29270162
//
//  FavouritesViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase

// This class is the View Controller class for the Favourites Screen, which is the third tab bar
// This class contains the logic to display the workshops that the user has favourited
class FavouritesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noFavouritedMessageLabel: UILabel!
    
    var clickedWorkshop: WorkshopDetails?
    
    let NO_FAVOURITE_WORKSHOPS = "You do not have any favourited workshops."
    let CELL_WORKSHOP = "workshopCell"
    
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    let itemsPerRow: CGFloat = 1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var navController: UINavigationController!
    var homeVC: HomeViewController!
    var user: User?
    var myFavourites = [WorkshopDetails]()
    
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController = tabBarController!.viewControllers![0] as? UINavigationController
        homeVC = navController?.topViewController as? HomeViewController
        
        user = appDelegate.user
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        myFavourites = homeVC.myFavourites
        
        // Sort the workshops in ascending order based on the date
        myFavourites.sort { (first, second) -> Bool in
            return first.date < second.date
        }
        
        // Show the message if there is no favourited workshop
        if myFavourites.count == 0 {
            collectionView.isHidden = true
            noFavouritedMessageLabel.text = NO_FAVOURITE_WORKSHOPS
        } else {
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    // This function handles the code whenever the heart button on the top right corner is clicked
    // This function will remove the workshop from the favourites list
    @IBAction func favouriteButtonClicked(_ sender: UIButton) {
        let workshop = myFavourites[sender.tag]
        let userRef = database.collection("users").document(self.user!.dataID)
    
        userRef.updateData([
            "favourite": FieldValue.arrayRemove([workshop.id])
        ])
        myFavourites.remove(at: findWorkshopIndex(workshop: workshop))
        homeVC.myFavourites = myFavourites
        
        collectionView.reloadData()
    }
    
    // This function is used to find the index of the given workshop in an array
    func findWorkshopIndex(workshop: WorkshopDetails) -> Int {
        for (index, favWorkshop) in myFavourites.enumerated() {
            if favWorkshop == workshop {
                return index
            }
        }
        
        return 0
    }
    
    // Specify the number of items in the sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if myFavourites.count == 0 {
            noFavouritedMessageLabel.alpha = 1
        } else {
            noFavouritedMessageLabel.alpha = 0
        }
        return myFavourites.count
    }
    
    // Set up the cell in a particular row and section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_WORKSHOP, for: indexPath) as! WorkshopCollectionViewCell
        cell.dateLabel.text = "\(myFavourites[indexPath.row].workshopDate) (\(myFavourites[indexPath.row].workshopTime))"
        cell.workshopTitleLabel.text = myFavourites[indexPath.row].workshopTitle
        cell.instructorLabel.text = "with \(myFavourites[indexPath.row].workshopInstructor)"
        cell.workshopImage.image = myFavourites[indexPath.row].workshopImage
        
        // Check the remaining seats and see if there should be a reminder for it and or it solds out
        cell.soldOutImage.alpha = 0
        if myFavourites[indexPath.row].remainingSeats <= 5 {
            if myFavourites[indexPath.row].remainingSeats == 0 {
                cell.soldOutImage.alpha = 1
                cell.remainingSeatsLabel.text = ""
            } else {
                cell.remainingSeatsLabel.text = "\(myFavourites[indexPath.row].remainingSeats) remaining seats"
            }
        } else {
            cell.remainingSeatsLabel.text = ""
        }
        
        // All the workshop in this list are favourited so the heart is filled
        // Set the tag and handler when the heart button is tapped
        cell.favouritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
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
        clickedWorkshop = myFavourites[indexPath.row]
        
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
    

}
