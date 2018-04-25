//
//  NetworkConnector.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/14/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

class NetworkConnector {
    
    // Performs all network requests
    func networkRequest(request: URLRequest, completionHandler: @escaping (_ data: AnyObject?, _ error: String?) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            completionHandler(nil, "There is no internet connection")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(nil, "There was an error in the request")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, "Your request returned a status code other than 2xx!")
                return
            }
            guard let data = data else {
                completionHandler(nil, "No data was returned by the request!")
                return
            }
            var parsedData: AnyObject! = nil
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                do {
                    let udacityData = data.subdata(in: Range(5..<data.count))
                    parsedData = try JSONSerialization.jsonObject(with: udacityData, options: .allowFragments) as AnyObject
                } catch {
                    completionHandler(nil, "Unable to parse data")
                }
            }
                completionHandler(parsedData, nil)
        }
        task.resume()
    }
    
    func buildURL(urlString: String, method: String, headers: [String: String]) -> URLRequest {
        var request = URLRequest(url: URL(string: urlString)!)
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        request.httpMethod = method
        return request
    }
    
    func buildURL(urlString: String, method: String, headers: [String: String], body: String) -> URLRequest {
        var request = buildURL(urlString: urlString, method: method, headers: headers)
        request.httpBody = body.data(using: .utf8)
        return request
    }
    
    // Creates the JSON for submitting the student's information to the server.
    func convertStudentToJson(student: Student) -> String {
        let studentData = "{\"\(ParseReturnConstants.uniqueKey)\": \"\(student.uniqueKey)\", \"\(ParseReturnConstants.firstName)\": \"\(student.firstName)\", \"\(ParseReturnConstants.lastName)\": \"\(student.lastName)\", \"\(ParseReturnConstants.mapString)\": \"\(student.mapString)\", \"\(ParseReturnConstants.mediaURL)\": \"\(student.mediaURL)\", \"\(ParseReturnConstants.latitude)\": \(student.latitude), \"\(ParseReturnConstants.logitude)\": \(student.logitude)}"
        return studentData
    }
}
