//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkClient {
  
    static var students: [Student] = [Student]()
    func getStudents() {
        let networkConnector = NetworkConnector()
        let request = networkConnector.buildURL(urlString: "https://parse.udacity.com/parse/classes/StudentLocation", method: "GET")
        networkConnector.networkRequest(request: request) { (data, error) in
            
            let studentsDictionary = data![ParseReturnConstants.results] as! [[String: AnyObject]]
            var student: Student
            for studentDictionary in studentsDictionary {
                student = NetworkConnector().convertJsonToStudent(studentData: studentDictionary)
                NetworkClient.students.append(student)
            }
            //print(studentsDictionary)
            print(NetworkClient.students.count)
            
        }
    }
}
