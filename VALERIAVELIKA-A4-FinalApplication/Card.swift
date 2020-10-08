//
//  Card.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 27/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import Foundation
import UIKit

class Card: NSObject {
    var id: String
    var name: String
    var cardNumber: String
    var expMonth: String
    var expYear: String
    var cvv: String
    var balance: String
    
    init(id: String, name: String, cardNumber: String, expMonth: String, expYear: String, cvv: String, balance: String) {
        self.id = id
        self.name = name
        self.cardNumber = cardNumber
        self.expMonth = expMonth
        self.expYear = expYear
        self.cvv = cvv
        self.balance = balance
    }
}
