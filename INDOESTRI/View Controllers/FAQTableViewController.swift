// Valeria Velika 29270162
//
//  FAQTableViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 28/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class is the Table View Controller class for the FAQ Screen
class FAQTableViewController: UITableViewController {
    
    let WORKSHOP_SECTION = 0
    let LOCATION_SECTION = 1
    let CELL_FAQ = "faqCell"
    
    let workshopQuestion = ["Can anyone join the one-day workshops? What are the requirements?", "What kind of workshops can I Join at Indoestri Makerspace?", "I have zero experience when it comes to leather craft, can I join an Intermediate Leather Workshop without joining a beginners class first?", "How long are the workshops?", "What can I get out of from the workshop ?", "Where do I buy tools, supplies and materials if I want to practice at home ?"]
    let workshopAnswer = ["There are no requirements! All of our workshops are open for public. Just create an account through this website and complete the payments, and BAM! You are all set and good to go!", "It’s all up to you! You can join in a wide range of workshops, from Toolbox Making to Modern Calligraphy to Urban Farming. Click here to take a look at what workshops we have available for the next two months!", "Yes, beginners are welcome at our intermediate workshops (not just leatherwork). Intermediate workshops are only more difficult than the beginners workshop.", "Depends! Some ends at around 3 or 4 in the afternoon, more intermediate and heavy workshops can end at around 5 or 6 PM.", "New and useful skills, new friends who share the same passion as you, tools rental, syllabus, Dawn and Willow lunch voucher worth IDR 50.000, and Indoestri merchandise shopping voucher worth IDR 50.000", "You can purchase tools, supplies and materials from Indoestri Shop, located inside Indoestri Makerspace and also online. Currently we have available leather, textile, and screen printing supplies and tools."]
    
    let locationQuestion = ["How do I get there?", "Where do I park my car or motor?"]
    let locationAnswer = ["We are located at Rawa Buaya. Exit through Tol Luar Lingkar Barat at Rawa Buaya, make a U turn as soon as you take that exit, go straight ahead until you find another U turn on your right and make that U turn, if you see a Shell gas station, we are right beside it. You should already see us with our bright blue metal door. \n \nIf you have Google Maps or Waze on your mobile phone, even better! Search “Indoestri Makerspace” and it will lead you to our exact location.", "We do have spaces at our location for you to park your car and motorcycle."]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    // Specify the number of sections (Workshop and Location)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Specify the number of cells/rows in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == WORKSHOP_SECTION {
            return workshopAnswer.count
        } else {
            return locationAnswer.count
        }
    }
    
    // Set the title for the header section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == WORKSHOP_SECTION {
            return "WORKSHOP"
        } else {
            return "LOCATION"
        }
    }

    // Set up the cell in a particular row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_FAQ, for: indexPath) as! FAQTableViewCell
        cell.isUserInteractionEnabled = false
        
        if indexPath.section == WORKSHOP_SECTION {
            cell.questionLabel.text = workshopQuestion[indexPath.row]
            cell.answerLabel.text = workshopAnswer[indexPath.row]
        } else {
            cell.questionLabel.text = locationQuestion[indexPath.row]
            cell.answerLabel.text = locationAnswer[indexPath.row]
        }

        return cell
    }
    
    // This function changes the font and appearance of the header section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 8, width: 320, height: 25)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "Red Logo")
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")
        view.addSubview(label)

        return view
    }
}
