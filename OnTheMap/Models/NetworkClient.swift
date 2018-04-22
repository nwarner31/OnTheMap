//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkClient {
    static var students = [Student]()
    static var sessionId = 0
    static var studentId = "0"
    static var myFirstName = "0"
    static var myLastName = "0"
    
    func udacityLogin(userName: String, password: String, completionHandler: @escaping (_ : String) -> Void) {
        let networkConnector = NetworkConnector()
        let headers = Headers.accept.merging(Headers.contentType) { (current, _) in current }
        let body = "{\"udacity\": { \"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        var request = networkConnector.buildURL(urlString: Constants.udacitySessionURL, method: "POST", headers: headers, body: body)
        networkConnector.networkRequest(request: request) { (data, error) in
            guard error == nil else {
                var errorMessage = ""
                if error == "Your request returned a status code other than 2xx!" {
                    errorMessage = "Incorrect username or password. Please check to make sure that they are entered correctly"
                } else {
                    errorMessage = error!
                }
                completionHandler(errorMessage)
                return
            }
            if let data = data, let studentId = (data["account"] as! [String: AnyObject])["key"] as? String {
                NetworkClient.studentId = studentId
                let urlString = "\(Constants.udacityUserURL)\(studentId)"
                request = networkConnector.buildURL(urlString: urlString, method: "GET", headers: [String: String]())
                networkConnector.networkRequest(request: request) { (data, error) in
                    if let student = data?["user"] as? [String: AnyObject], let firstName = student["first_name"] as? String, let lastName = student["last_name"] as? String {
                        NetworkClient.myFirstName = firstName
                        NetworkClient.myLastName = lastName
                        completionHandler("successful")
                    }
                }
            } else {
                completionHandler("Unknown failure")
            }
        }
    }
    func logout(completionHandler: @escaping () -> Void) {
        let networkConnector = NetworkConnector()
        var request = networkConnector.buildURL(urlString: Constants.udacitySessionURL, method: "DELETE", headers: [String: String]())
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            networkConnector.networkRequest(request: request) { (data, error) in
                completionHandler()
            }
        }
    }
    func getStudents(completionHandler: @escaping (_ wasSuccessful: Bool) -> Void) {
        let networkConnector = NetworkConnector()
        let headers = Headers.parseHeaders
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "GET", headers: headers)
        networkConnector.networkRequest(request: request) { (data, error) in
            guard error == nil else {
                completionHandler(false)
                return
            }
            let studentsDictionary = data![ParseReturnConstants.results] as! [[String: AnyObject]]
            var student: Student
            for studentDictionary in studentsDictionary {
                student = Student(dictionary: studentDictionary)
                NetworkClient.students.append(student)
            }
            completionHandler(true)
        }
    }
    func insertStudent(student: Student, completionHandler: @escaping (_ wasSuccessful: Bool, _ student: Student?) -> Void) {
        let networkConnector = NetworkConnector()
        var student = student
        let studentData = networkConnector.convertStudentToJson(student: student)
        let headers = Headers.parseHeaders.merging(Headers.contentType) { (current, _) in current }
        let request = networkConnector.buildURL(urlString: Constants.studentLocationURL, method: "POST", headers: headers, body: studentData)
        networkConnector.networkRequest(request: request) { (data, error) in
            guard error == nil else {
                completionHandler(false, nil)
                return
            }
            if let data = data {
                let objectId = data[ParseReturnConstants.objectId] as! String
                let createdAt = data[ParseReturnConstants.createdAt] as! String
                student.inserted(objectId: objectId, createdAt: createdAt)
                completionHandler(true, student)
            }
        }
    }
    // Ensures the URL submitted to the server is valid and the one in the map and table view
    func validateUrl(stringToCheck: String) -> String {
        var url: String
        if let _ = URL(string: stringToCheck) {
            url = stringToCheck
            if !url.hasPrefix("http") {
                url = "https://\(url)"
            }
        } else {
            url = "https://www.udacity.com"
        }
        return url
    }
}
