//
//  FAQTableViewCell.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 28/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit

// This class repesent a singular table view cell that displays a question and its answer
// Used in FAQTableViewController
class FAQTableViewCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
