//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkClient {
  
    func udacityLogin(userName: String, password: String) {
        let networkConnector = NetworkConnector()
        let body = "{\"udacity\": { \"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        let request = networkConnector.buildURL(urlString: Constants.udacitySessionURL, method: "POST", body: body)
    }
    
    static var students: [Student] = [Student]()
    func getStudents(completionHandler: @escaping () -> Void) {
        let networkConnector = NetworkConnector()
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "GET")
        networkConnector.networkRequest(request: request) { (data, error) in
            
            let studentsDictionary = data![ParseReturnConstants.results] as! [[String: AnyObject]]
            var student: Student
            for studentDictionary in studentsDictionary {
                student = NetworkConnector().convertJsonToStudent(studentData: studentDictionary)
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
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "POST", body: studentData)
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
        let request = networkConnector.buildURL(urlString: "\(Constants.studentLocationURL)/\(student.objectId)", method: "PUT", body: studentData)
        networkConnector.networkRequest(request: request) { (data, error) in
            if let data = data {
                let updatedAt = data[ParseReturnConstants.updatedAt] as! String
                student.updated(newUpdateTime: updatedAt)
            }
        }
    }
    
}
