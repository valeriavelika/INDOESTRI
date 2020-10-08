// Valeria Velika 29270162
//
//  MyWorkshopsViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class is the View Controller class for the My Workshops Screen, which is the second tab bar
// This class contains the logic to display the workshops that the user registered for
class MyWorkshopsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let UPCOMING_SECTION = 0
    let PAST_SECTION = 1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var homeVC: HomeViewController!
    var navController: UINavigationController!
    
    let NO_UPCOMING_WORKSHOPS = "You do not have any upcoming workshops."
    let NO_PAST_WORKSHOPS = "You have not attended any workshops."
    let CELL_WORKSHOP = "workshopCell"
    
    let sectionInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    let itemsPerRow: CGFloat = 1
    
    var upcomingWorkshops = [WorkshopDetails]()
    var pastWorkshops = [WorkshopDetails]()
    var currentSection = 0
    var clickedWorkshop: WorkshopDetails?
    
    @IBOutlet weak var workshopControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noWorkshopMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController = tabBarController?.viewControllers![0] as? UINavigationController
        homeVC = navController?.topViewController as? HomeViewController
        
        currentSection = UPCOMING_SECTION
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        workshopControl.selectedSegmentIndex = UPCOMING_SECTION
        currentSection = UPCOMING_SECTION
        
        // Get the array from the Home View Controller
        upcomingWorkshops = homeVC.upcomingWorkshops
        pastWorkshops = homeVC.pastWorkshops
        
        // Sort the upcoming workshops in ascending order based on the date
        upcomingWorkshops.sort { (first, second) -> Bool in
            return first.date < second.date
        }
        
        // Sort the past workshops in descending order based on the date
        pastWorkshops.sort { (first, second) -> Bool in
            return first.date > second.date
        }
        
        checkWorkshopCount(section: currentSection)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.hidesBottomBarWhenPushed = false
    }
    
    // This function is called whenever the user tapped on the segmented control (upcoming or past workshop)
    @IBAction func sectionChanged(_ sender: Any) {
        switch workshopControl.selectedSegmentIndex {
        case UPCOMING_SECTION:
            currentSection = UPCOMING_SECTION
            checkWorkshopCount(section: UPCOMING_SECTION)
        case PAST_SECTION:
            currentSection = PAST_SECTION
            checkWorkshopCount(section: PAST_SECTION)
        default:
            break
        }
    }
    
    // Check the number of workshop for the given section and show the message is needed
    func checkWorkshopCount(section: Int) {
        var array = [WorkshopDetails]()
        var message = String()
        
        if section == UPCOMING_SECTION {
            array = upcomingWorkshops
            message = NO_UPCOMING_WORKSHOPS
        } else {
            array = pastWorkshops
            message = NO_PAST_WORKSHOPS
        }
        
        if array.count == 0 {
            collectionView.isHidden = true
            noWorkshopMessageLabel.text = message
            noWorkshopMessageLabel.alpha = 1
        } else {
            collectionView.isHidden = false
            noWorkshopMessageLabel.alpha = 0
            collectionView.reloadData()
        }
    }
    
    // Specify the number of items in the sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentSection {
        case UPCOMING_SECTION:
            return upcomingWorkshops.count
        case PAST_SECTION:
            return pastWorkshops.count
        default:
            return 0
        }
    }
    
    // Set up the cell in a particular row and section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var workshops = [WorkshopDetails]()
        if currentSection == UPCOMING_SECTION {
            workshops = upcomingWorkshops
        } else {
            workshops = pastWorkshops
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_WORKSHOP, for: indexPath) as! WorkshopCollectionViewCell
        cell.dateLabel.text = "\(workshops[indexPath.row].workshopDate) (\(workshops[indexPath.row].workshopTime))"
        cell.workshopTitleLabel.text = workshops[indexPath.row].workshopTitle
        cell.instructorLabel.text = "with \(workshops[indexPath.row].workshopInstructor)"
        cell.workshopImage.image = workshops[indexPath.row].workshopImage
        
        cell.soldOutImage.alpha = 0
        cell.remainingSeatsLabel.alpha = 0
        // Check the remaining seats and see if there should be a reminder for it and or it solds out
        if currentSection == UPCOMING_SECTION {
            if workshops[indexPath.row].remainingSeats <= 5 {
                cell.remainingSeatsLabel.alpha = 1
                if workshops[indexPath.row].remainingSeats == 0 {
                    cell.soldOutImage.alpha = 1
                    cell.remainingSeatsLabel.text = ""
                } else {
                    cell.remainingSeatsLabel.text = "\(workshops[indexPath.row].remainingSeats) remaining seats"
                }
            }
        }
        
        // Remove the favourited button
        cell.favouritesButton.alpha = 0
        
        cell.contentView.layer.cornerRadius = 8.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
    
        return cell
    }
    
    // This function will be executed when a cell is clicked. It will open the Workshop Details Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var workshops = [WorkshopDetails]()
        if currentSection == UPCOMING_SECTION {
            workshops = upcomingWorkshops
        } else {
            workshops = pastWorkshops
        }
        
        // Get the workshop that is clicked to be passed on to the next view controller
        clickedWorkshop = workshops[indexPath.row]
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
            if currentSection == PAST_SECTION {
                destination.pastWorkshop = "YES"
            }
        }
    }
}
