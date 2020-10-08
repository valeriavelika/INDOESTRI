//
//  CardsCollectionViewCell.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 27/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class holds the references of a cell in Collection View which is used to display information of a card in a Collection View
class CardsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
}
