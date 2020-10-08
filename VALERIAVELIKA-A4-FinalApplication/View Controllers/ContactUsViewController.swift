// Valeria Velika 29270162
//
//  ContactUsViewController.swift
//  VALERIAVELIKA-A4-FinalApplication
//
//  Created by Valeria Velika on 28/6/20.
//  Copyright © 2020 Valeria Velika. All rights reserved.
//

import UIKit
import MapKit

// This class is the View Controller class for the Contact Us Screen
class ContactUsViewController: UIViewController {
    let application = UIApplication.shared

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = CLLocationCoordinate2D(latitude: -6.182356, longitude: 106.729181)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Indoestri"
        mapView.addAnnotation(annotation)
    }
    
    // This function will trigger the deep linking to Instagram
    @IBAction func instagramTapped(_ sender: Any) {
        let appUrl = URL(string: "instagram://user?username=indoestri")!
        
        let websiteUrl = URL(string: "https://www.instagram.com/indoestri/")!
        
        if application.canOpenURL(appUrl) {
            // The Instagram app will be opened if the user has Instagram
            application.open(appUrl)
        } else {
            // Else the link will be opened in Safari
            application.open(websiteUrl)
        }
    }
    
    // This function will trigger the deep linking to Facebook
    @IBAction func facebookTapped(_ sender: Any) {
        let appUrl = URL(string: "fb://page/?id=1473794819617199")!
        
        let websiteUrl = URL(string: "https://www.facebook.com/indoestrimakerspace")!
        
        if application.canOpenURL(appUrl) {
            // The Facebook app will be opened if the user has Facebook
            application.open(appUrl)
        } else {
            // Else the link will be opened in Safari
            application.open(websiteUrl)
        }
    }
}
