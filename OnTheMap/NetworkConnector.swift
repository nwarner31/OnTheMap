//
//  NetworkConnector.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/14/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkConnector {
    private func buildURL(urlString: String) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    func getRequest(urlString: String, completionHandler: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let request = buildURL(urlString: urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else { // Handle error...
                return
            }
            var parsedData: AnyObject! = nil
            do {
                parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            } catch {
            
            }
            //let dataString = String(data: data!, encoding: .utf8)!
                completionHandler(parsedData, nil)
            
        }
        task.resume()
    }
    func convertJsonToStudent (studentData: [String: AnyObject]) -> Student {
        let objectId = studentData[ParseReturnConstants.objectId] as? String ?? ""
        let uniqueKey = studentData[ParseReturnConstants.uniqueKey] as? String ?? ""
        let firstName = studentData[ParseReturnConstants.firstName] as? String ?? "(No First Name Given)"
        let lastName = studentData[ParseReturnConstants.lastName] as? String ?? "(No Last Name Given)"
        let mediaURL = studentData[ParseReturnConstants.mediaURL] as? String ?? ""
        let mapString = studentData[ParseReturnConstants.mapString] as? String ?? ""
        let latitude = studentData[ParseReturnConstants.latitude] as? Float ?? 0.0
        let logitude = studentData[ParseReturnConstants.logitude] as? Float ?? 0.0
        let createdAt = studentData[ParseReturnConstants.createdAt] as? String ?? ""
        let updatedAt = studentData[ParseReturnConstants.updatedAt] as? String ?? ""
        let student = Student(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL, mapString: mapString, latitude: latitude, logitude: logitude, createdAt: createdAt, updatedAt: updatedAt)
        return student
        
    }
}
