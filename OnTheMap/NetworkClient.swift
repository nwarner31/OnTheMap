//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkClient {
  
    func udacityLogin(userName: String, password: String, completionHandler: @escaping (_ wasSuccessful: Bool) -> Void) {
        let networkConnector = NetworkConnector()
        let headers = Headers.accept.merging(Headers.contentType) { (current, _) in current }
        let body = "{\"udacity\": { \"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        var request = networkConnector.buildURL(urlString: Constants.udacitySessionURL, method: "POST", headers: headers, body: body)
        networkConnector.networkRequest(request: request) { (data, error) in
            if let data = data, let studentId = (data["account"] as! [String: AnyObject])["key"] as? String {
                print(data)
                print((data["account"] as! [String: AnyObject])["key"])
                print(studentId)
                NetworkClient.studentId = studentId
                let urlString = "\(Constants.udacityUserURL)\(studentId)"
                request = networkConnector.buildURL(urlString: urlString, method: "GET", headers: [String: String]())
                networkConnector.networkRequest(request: request) { (data, error) in
                    //print(data)
                    if let student = data?["user"] as? [String: AnyObject], let firstName = student["first_name"] as? String, let lastName = student["last_name"] as? String {
                        NetworkClient.myFirstName = firstName
                        NetworkClient.myLastName = lastName
                        print("\(firstName) \(lastName)")
                        completionHandler(true)
                    }
                    
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    static var students = [Student]()
    static var sessionId = 0
    static var studentId = "0"
    static var myFirstName = "0"
    static var myLastName = "0"
    func getStudents(completionHandler: @escaping () -> Void) {
        let networkConnector = NetworkConnector()
        let headers = Headers.parseHeaders
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "GET", headers: headers)
        networkConnector.networkRequest(request: request) { (data, error) in
            
            let studentsDictionary = data![ParseReturnConstants.results] as! [[String: AnyObject]]
            var student: Student
            for studentDictionary in studentsDictionary {
                student = Student(dictionary: studentDictionary)
                NetworkClient.students.append(student)
            }
            //print(studentsDictionary)
            print(NetworkClient.students.count)
            completionHandler()
        }
    }
    func insertStudent(student: Student) {
        let networkConnector = NetworkConnector()
        var student = student
        let studentData = networkConnector.convertStudentToJson(student: student)
        let headers = Headers.parseHeaders.merging(Headers.contentType) { (current, _) in current }
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "POST", headers: headers, body: studentData)
        networkConnector.networkRequest(request: request) { (data, error) in
            if let data = data {
                let objectId = data[ParseReturnConstants.objectId] as! String
                let createdAt = data[ParseReturnConstants.createdAt] as! String
                student.inserted(objectId: objectId, createdAt: createdAt)
            }
        }
    }
    func updateStudent(student: Student) {
        let networkConnector = NetworkConnector()
        var student = student
        let studentData = networkConnector.convertStudentToJson(student: student)
        let headers = Headers.parseHeaders.merging(Headers.contentType) { (current, _) in current }
        let request = networkConnector.buildURL(urlString: "\(Constants.studentLocationURL)/\(student.objectId)", method: "PUT", headers: headers, body: studentData)
        networkConnector.networkRequest(request: request) { (data, error) in
            if let data = data {
                let updatedAt = data[ParseReturnConstants.updatedAt] as! String
                student.updated(newUpdateTime: updatedAt)
            }
        }
    }
    
}
