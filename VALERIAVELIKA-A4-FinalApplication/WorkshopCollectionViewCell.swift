//
//  WorkshopCollectionViewCell.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 18/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class holds the references of a cell in Collection View which is used to display information of a workshop in a Collection View
class WorkshopCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var workshopImage: UIImageView!
    @IBOutlet weak var favouritesButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var workshopTitleLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var remainingSeatsLabel: UILabel!
    @IBOutlet weak var soldOutImage: UIImageView!
    
}
