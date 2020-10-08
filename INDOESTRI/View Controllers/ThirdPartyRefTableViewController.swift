// Valeria Velika 29270162
//
//  ThirdPartyRefTableViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 28/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//


import UIKit

// This class is the Table View Controller class for Third Party Materials Screen
// This contains a list of Acknowledgment of third-party materials
class ThirdPartyRefTableViewController: UITableViewController {
    
    let CELL = "referenceCell"
    
    let reference = ["https://indoestri.com/en", "https://firebase.google.com/", "https://github.com/ashleymills/Reachability.swift", "https://www.youtube.com/watch?v=1HN7usMROt8", "https://www.youtube.com/watch?v=MubFu5yOAGc", "https://www.youtube.com/watch?v=JuqQUP0pnZY", "https://www.youtube.com/watch?v=xJU634A14u4", "https://stackoverflow.com/questions/20742745/navigation-controller-push-view-controller", "https://stackoverflow.com/questions/28760541/programmatically-go-back-to-previous-viewcontroller-in-swift", "https://stackoverflow.com/questions/38564119/how-to-set-orientation-in-portrait-only/38564537", "https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value", "https://stackoverflow.com/questions/25626525/setting-initial-state-of-uiswitch", "https://stackoverflow.com/questions/28555255/how-do-i-keep-uiswitch-state-when-changing-viewcontrollers", "https://stackoverflow.com/questions/51116381/convert-firebase-firestore-timestamp-to-date-swift", "https://stackoverflow.com/questions/50090171/how-to-re-authenticate-a-user-with-firebase", "https://stackoverflow.com/questions/51631530/format-uitextfield-mm-yy-as-expiration", "https://stackoverflow.com/questions/55324708/how-to-cancel-a-local-notification-trigger-in-swift", "https://stackoverflow.com/questions/19802336/changing-font-size-for-uitableview-section-headers", "https://firebase.google.com/docs/auth/ios/manage-users", "https://firebase.google.com/docs/firestore/manage-data/add-data", "https://firebase.google.com/docs/storage/ios/download-files", "https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/custom-cells/", "https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ImplementNavigation.html", "Monash FIT3178 Week 6 Lecture Slides", "Monash FIT3178 Week 10 Lecture Slides", "Monash FIT3178 Week 10 Lecture Slides"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    // Specify the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Specify the number of cells/rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reference.count
    }

    // Set up the cell in a particular row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = reference[indexPath.row]

        return cell
    }
}
