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
                completionHandler(nil, nil)
                return
            }
            //print((response as? HTTPURLResponse)?.statusCode)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandler(nil, nil)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, nil)
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
                    completionHandler(nil, nil)
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
    func convertStudentToJson(student: Student) -> String {
        let studentData = "{\"\(ParseReturnConstants.uniqueKey)\": \"\(student.uniqueKey)\", \"\(ParseReturnConstants.firstName)\": \"\(student.firstName)\", \"\(ParseReturnConstants.lastName)\": \"\(student.lastName)\", \"\(ParseReturnConstants.mapString)\": \"\(student.mapString)\", \"\(ParseReturnConstants.mediaURL)\": \"\(student.mediaURL)\", \"\(ParseReturnConstants.latitude)\": \(student.latitude), \"\(ParseReturnConstants.logitude)\": \(student.logitude)}"
        print(studentData)
        return studentData
    }
}
