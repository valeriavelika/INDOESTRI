//
//  User.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 21/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import Foundation
import UIKit

// This class defines a User object, containing the information of the current user
class User: NSObject {
    var uid: String
    var name: String
    var email: String
    var phone: String
    var dataID: String
    
    init(uid: String, name: String, email: String, phone: String, dataID: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.phone = phone
        self.dataID = dataID
    }
}
