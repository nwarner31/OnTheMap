//
//  InsertPinViewController.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/19/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InsertPinViewController: UIViewController {
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var studentLocationMapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    var locationString = ""
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var pinObjectId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        guard let location = locationSearchTextField.text else { return }
        let geo = CLGeocoder()
        geo.geocodeAddressString(location) { (placemarks, error) in
            guard error == nil else {
                //print(error)
                self.submitButton.isEnabled = false
                return
            }
            guard let placemarks = placemarks else { return }
            let city = placemarks[0]
            let studentPin = MKPlacemark(placemark: city)
            self.latitude = Float(studentPin.coordinate.latitude)
            self.longitude = Float(studentPin.coordinate.longitude)
            self.locationString = studentPin.title!
            self.studentLocationMapView.addAnnotation(studentPin)
            self.studentLocationMapView.setRegion(MKCoordinateRegionMakeWithDistance(studentPin.coordinate, 1000, 1000), animated: true)
            self.submitButton.isEnabled = true
        }
    }
    @IBAction func submitPin(_ sender: Any) {
        var mediaUrl = ""
        if let _ = URL(string: mediaURLTextField.text!) {
            mediaUrl = mediaURLTextField.text!
            if !mediaUrl.hasPrefix("http") {
                mediaUrl = "https://\(mediaUrl)"
            } else {
                mediaUrl = "https://www.udacity.com"
            }
        }
        let student = Student(objectId: pinObjectId, uniqueKey: NetworkClient.studentId, firstName: NetworkClient.myFirstName, lastName: NetworkClient.myLastName, mediaURL: mediaUrl, mapString: locationString, latitude: latitude, logitude: longitude, createdAt: "", updatedAt: "")
       
        NetworkClient().insertStudent(student: student)
       
    }
    
    @IBAction func cancelPin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
