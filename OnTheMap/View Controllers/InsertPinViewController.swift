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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.gray
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        guard let location = locationSearchTextField.text else { return }
        let geo = CLGeocoder()
        geo.geocodeAddressString(location) { (placemarks, error) in
            guard error == nil else {
                return
            }
            guard let placemarks = placemarks else { return }
            let city = placemarks[0]
            let studentPin = MKPlacemark(placemark: city)
            self.latitude = Float(studentPin.coordinate.latitude)
            self.longitude = Float(studentPin.coordinate.longitude)
            self.locationString = studentPin.title!
            self.studentLocationMapView.addAnnotation(studentPin)
            self.studentLocationMapView.setRegion(MKCoordinateRegionMakeWithDistance(studentPin.coordinate, 10000, 10000), animated: true)
            self.submitButton.isEnabled = true
            self.submitButton.backgroundColor = UIColor.blue
        }
    }
    @IBAction func submitPin(_ sender: Any) {
        let mediaUrl = NetworkClient().validateUrl(stringToCheck: mediaURLTextField.text!)
        
        let student = Student(objectId: "", uniqueKey: NetworkClient.studentId, firstName: NetworkClient.myFirstName, lastName: NetworkClient.myLastName, mediaURL: mediaUrl, mapString: locationString, latitude: latitude, logitude: longitude, createdAt: "", updatedAt: "")
        NetworkClient().insertStudent(student: student) { (wasSuccessful, insertedStudent) in
            if wasSuccessful {
                DispatchQueue.main.async {
                    NetworkClient.students.insert(insertedStudent!, at: 0)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Unable to submit pin. Do you want to try to submit it again?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                        self.resubmitPin(student: student)
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                        self.cancelPin(sender)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @IBAction func cancelPin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func resubmitPin(student: Student) {
        NetworkClient().insertStudent(student: student) { (wasSuccessful, insertedStudent) in
            if wasSuccessful {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Still unable to submit pin. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                        self.cancelPin(student as Any)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
