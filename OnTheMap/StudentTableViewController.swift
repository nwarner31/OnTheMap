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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NetworkClient.students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = NetworkClient.students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentTableCell") as! StudentTableViewCell
        cell.studentNameLabel.text = "\(student.lastName), \(student.firstName)"
        cell.studentLocationLabel.text = student.mapString
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = NetworkClient.students[indexPath.row]
        NetworkConnector().convertStudentToJson(student: student)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65.0)
    }
    
    
}
