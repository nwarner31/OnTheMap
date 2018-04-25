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

class InsertPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var studentLocationMapView: MKMapView!
    @IBOutlet weak var geocodingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    var locationString = ""
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.gray
        mediaURLTextField.delegate = self
        locationSearchTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        guard let location = locationSearchTextField.text else { return }
        geocodingActivityIndicator.startAnimating()
        let geo = CLGeocoder()
        geo.geocodeAddressString(location) { (placemarks, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "Unable to find location. Please try another location name.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    self.geocodingActivityIndicator.stopAnimating()
                }))
                self.present(alert, animated: true)
                return
            }
            guard let placemarks = placemarks else {
                self.geocodingActivityIndicator.stopAnimating()
                return
            }
            let city = placemarks[0]
            let studentPin = MKPlacemark(placemark: city)
            self.latitude = Float(studentPin.coordinate.latitude)
            self.longitude = Float(studentPin.coordinate.longitude)
            self.locationString = studentPin.title!
            self.studentLocationMapView.addAnnotation(studentPin)
            self.studentLocationMapView.setRegion(MKCoordinateRegionMakeWithDistance(studentPin.coordinate, 10000, 10000), animated: true)
            self.submitButton.isEnabled = true
            self.submitButton.backgroundColor = UIColor.blue
            if self.locationSearchTextField.isEditing {
                self.locationSearchTextField.resignFirstResponder()
            }
            self.geocodingActivityIndicator.stopAnimating()
        }
    }
    
    @IBAction func submitPin(_ sender: Any) {
        let mediaUrl = NetworkClient().validateUrl(stringToCheck: mediaURLTextField.text!)
        
        let student = Student(objectId: "", uniqueKey: NetworkClient.studentId, firstName: NetworkClient.myFirstName, lastName: NetworkClient.myLastName, mediaURL: mediaUrl, mapString: locationString, latitude: latitude, logitude: longitude, createdAt: "", updatedAt: "")
        NetworkClient().insertStudent(student: student) { (wasSuccessful, insertedStudent) in
            if wasSuccessful {
                DispatchQueue.main.async {
                    StudentsDataSource.students.insert(insertedStudent!, at: 0)
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
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if mediaURLTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
