//
//  ViewController.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/14/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var studentMapView: MKMapView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if StudentsDataSource.students.isEmpty {
            attemptToGetStudents(true)
        } else {
            setUpMapPins()
        }
        studentMapView.delegate = self
    }
    
    func attemptToGetStudents(_ isFirstAttempt: Bool) {
        NetworkClient().getStudents() { (wasSuccessful) in
            if wasSuccessful {
                self.setUpMapPins()
            } else {
                DispatchQueue.main.async {
                    var message = ""
                    var response = ""
                    if isFirstAttempt {
                        message = "Do you want to try to again?"
                        response = "No"
                    } else {
                        message = "Please try again later."
                        response = "OK"
                    }
                    let alert = UIAlertController(title: "Error", message: "Unable to retrieve students. \(message)", preferredStyle: .alert)
                    if isFirstAttempt {
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                            self.attemptToGetStudents(false)
                        }))
                    }
                    alert.addAction(UIAlertAction(title: response, style: .cancel, handler: { action in
                        self.logout(true as Any)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func setUpMapPins() {
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        for student in StudentsDataSource.students {
            let annotation = self.createAnnotation(student: student)
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        // When the array is complete, we add the annotations to the map.
        DispatchQueue.main.async {
            // If there are already pins in the map remove them
            if self.studentMapView.annotations.count > 0 {
                for pin in self.studentMapView.annotations {
                    self.studentMapView.removeAnnotation(pin)
                }
            }
            self.studentMapView.addAnnotations(annotations)
        }
    }
    
    func createAnnotation(student: Student) -> MKPointAnnotation {
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        let lat = CLLocationDegrees(student.latitude)
        let long = CLLocationDegrees(student.logitude)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let first = student.firstName
        let last = student.lastName
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        let url = NetworkClient().validateUrl(stringToCheck: student.mediaURL)
        annotation.subtitle = url
        return annotation
    }
    
    @IBAction func logout(_ sender: Any) {
        NetworkClient().logout() { () in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func createPin(_ sender: Any) {
        let insertPinViewController = self.storyboard?.instantiateViewController(withIdentifier: "insertPin")
        present(insertPinViewController!, animated: true, completion: nil)
    }
}

extension StudentMapViewController {
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)! )
            }
        }
    }
}

