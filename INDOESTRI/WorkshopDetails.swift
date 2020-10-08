//
//  File.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 19/5/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import Foundation
import UIKit

// This class defines a WorkshopDetails object, containing the information of a workshop
class WorkshopDetails: NSObject {
    var id: String
    var workshopImage: UIImage?
    var workshopTitle: String
    var workshopDate: String
    var workshopInstructor: String
    var remainingSeats: Int
    var workshopDescription: String
    var workshopDuration: String
    var workshopTime: String
    var workshopFee: Int
    var date: Date
    
    init(id: String, workshopImage: UIImage, workshopTitle: String, workshopDate: String, workshopInstructor: String, remainingSeats: Int, workshopDescription: String, workshopDuration: String, workshopTime: String, workshopFee: Int, date: Date) {
        self.id = id
        self.workshopImage = workshopImage
        self.workshopTitle = workshopTitle
        self.workshopDate = workshopDate
        self.workshopInstructor = workshopInstructor
        self.remainingSeats = remainingSeats
        self.workshopDescription = workshopDescription
        self.workshopDuration = workshopDuration
        self.workshopTime = workshopTime
        self.workshopFee = workshopFee
        self.date = date
    }
}
