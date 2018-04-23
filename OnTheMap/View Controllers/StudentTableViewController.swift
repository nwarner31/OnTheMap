//
//  StudentTableViewDelegate.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation
import UIKit

class StudentTableViewController: UITableViewController {
    @IBOutlet var studentsTableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        studentsTableView.reloadData()
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Student.students.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = Student.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentTableCell") as! StudentTableViewCell
        cell.studentNameLabel.text = "\(student.lastName), \(student.firstName)"
        cell.studentLocationLabel.text = student.mapString
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = Student.students[indexPath.row]
        let app = UIApplication.shared
        let url = NetworkClient().validateUrl(stringToCheck: student.mediaURL)
        app.open(URL(string: url)!)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65.0)
    }
    
    
}
