//
//  NetworkConnector.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/14/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkConnector {
    
    func networkRequest(request: URLRequest, completionHandler: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        //let request = buildURL(urlString: urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            var parsedData: AnyObject! = nil
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
            
            }
                completionHandler(parsedData, nil)
            
        }
        task.resume()
    }
    func buildURL(urlString: String, method: String) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        if ["POST", "PUT"].contains(method) {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = method
        return request
    }
    func buildURL(urlString: String, method: String, body: String) -> URLRequest {
        var request = buildURL(urlString: urlString, method: method)
        request.httpBody = body.data(using: .utf8)
        return request
    }
    func convertJsonToStudent (studentData: [String: AnyObject]) -> Student {
        let objectId = studentData[ParseReturnConstants.objectId] as? String ?? ""
        let uniqueKey = studentData[ParseReturnConstants.uniqueKey] as? String ?? ""
        let firstName = studentData[ParseReturnConstants.firstName] as? String ?? "(No First Name Given)"
        let lastName = studentData[ParseReturnConstants.lastName] as? String ?? "(No Last Name Given)"
        let mediaURL = studentData[ParseReturnConstants.mediaURL] as? String ?? ""
        let mapString = studentData[ParseReturnConstants.mapString] as? String ?? ""
        let latitude = (studentData[ParseReturnConstants.latitude] as? NSNumber)?.floatValue ?? 0.0
        let logitude = (studentData[ParseReturnConstants.logitude] as? NSNumber)?.floatValue ?? 0.0
        let createdAt = studentData[ParseReturnConstants.createdAt] as? String ?? ""
        let updatedAt = studentData[ParseReturnConstants.updatedAt] as? String ?? ""
        let student = Student(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL, mapString: mapString, latitude: latitude, logitude: logitude, createdAt: createdAt, updatedAt: updatedAt)
        return student
        
    }
    func convertStudentToJson(student: Student) -> String {
        let studentData = "{\"\(ParseReturnConstants.uniqueKey)\": \"\(student.uniqueKey)\", \"\(ParseReturnConstants.firstName)\": \"\(student.firstName)\", \"\(ParseReturnConstants.lastName)\": \"\(student.lastName)\", \"\(ParseReturnConstants.mapString)\": \"\(student.mapString)\", \"\(ParseReturnConstants.mediaURL)\": \"\(student.mediaURL)\", \"\(ParseReturnConstants.latitude)\": \(student.latitude), \"\(ParseReturnConstants.logitude)\": \(student.logitude)}"
        print(studentData)
        return studentData
    }
}
