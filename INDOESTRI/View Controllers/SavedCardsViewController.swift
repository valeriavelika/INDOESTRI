// Valeria Velika 29270162
//
//  SavedCardsViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 27/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import Firebase

// This class is the View Controller class for the Saved Cards Screen
class SavedCardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let CELL_CARD = "cardCell"
    var savedCards: [Card] = []

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noSavedCardLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 20.0, right: 10.0)
    let itemsPerRow: CGFloat = 1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let database = Firestore.firestore()
    var user: User?
    
    @IBOutlet weak var addCardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Styles.styleButton(addCardButton)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedCards = appDelegate.savedCards
        user = appDelegate.user
        errorMessageLabel.alpha = 0

        if savedCards.count == 0 {
            collectionView.isHidden = true
            noSavedCardLabel.alpha = 1
        } else {
            collectionView.isHidden = false
            noSavedCardLabel.alpha = 0
            collectionView.reloadData()
        }
    }
    
    // This function is called when the user tap the add card button
    @IBAction func addCardTapped(_ sender: Any) {
        if savedCards.count == 3 {
            // A user can only save a maximum of 3 cards
            errorMessageLabel.alpha = 1
            errorMessageLabel.text = "You can only have 3 saved cards."
        } else {
            performSegue(withIdentifier: "addCardSegue", sender: nil)
        }
    }
    
    // This function is called when the user tapped on the Remove Card button in the cell
    @IBAction func removeCardTapped(_ sender: UIButton) {
        let card = savedCards[sender.tag]
        let userRef = database.collection("users").document(self.user!.dataID)
        
        // Remove it from the user account
        userRef.updateData([
            "card": FieldValue.arrayRemove([card.id])
        ])
        savedCards.remove(at: findCardIndex(card: card))
        appDelegate.savedCards = savedCards
        
        collectionView.reloadData()
    }
    
    // This function is used to find the index of the card in the saved cards array
    func findCardIndex(card: Card) -> Int {
        for (index, myCard) in savedCards.enumerated() {
            if myCard == card {
                return index
            }
        }
        return 0
    }
    
    // Specify the number of items in the sections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if savedCards.count == 0 {
            collectionView.isHidden = true
            noSavedCardLabel.alpha = 1
        }
        return savedCards.count
    }
    
    // Set up the cell in a particular row and section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_CARD, for: indexPath) as! CardsCollectionViewCell
        cell.nameLabel.text = savedCards[indexPath.row].name
        cell.cardNumberLabel.text = "**** **** **** \(savedCards[indexPath.row].cardNumber.suffix(4))"
        cell.expDateLabel.text = "EXP \(savedCards[indexPath.row].expMonth)/\(savedCards[indexPath.row].expYear)"
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(removeCardTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // The following 3 function are delegate to manipulate the cell size
    // This function specifies the size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth/itemsPerRow
        let height = widthPerItem/3.5
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
}
