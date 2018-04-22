//
//  Student.swift
//  OnTheMap
//
//  Created by Nathaniel Warner on 4/15/18.
//  Copyright © 2018 Nathaniel Warner. All rights reserved.
//

import Foundation

struct Student {
    var objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mediaURL: String
    let mapString: String
    let latitude: Float
    let logitude: Float
    var createdAt: String
    var updatedAt: String
    
    init(objectId: String, uniqueKey: String, firstName: String, lastName: String, mediaURL: String, mapString: String, latitude: Float, logitude: Float, createdAt: String, updatedAt: String) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.latitude = latitude
        self.logitude = logitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    // Used to create a student from JSON
    init(dictionary: [String: AnyObject]) {
        objectId = dictionary[ParseReturnConstants.objectId] as? String ?? ""
        uniqueKey = dictionary[ParseReturnConstants.uniqueKey] as? String ?? ""
        firstName = dictionary[ParseReturnConstants.firstName] as? String ?? "(No First Name Given)"
        lastName = dictionary[ParseReturnConstants.lastName] as? String ?? "(No Last Name Given)"
        mediaURL = dictionary[ParseReturnConstants.mediaURL] as? String ?? ""
        mapString = dictionary[ParseReturnConstants.mapString] as? String ?? ""
        latitude = (dictionary[ParseReturnConstants.latitude] as? NSNumber)?.floatValue ?? 0.0
        logitude = (dictionary[ParseReturnConstants.logitude] as? NSNumber)?.floatValue ?? 0.0
        createdAt = dictionary[ParseReturnConstants.createdAt] as? String ?? ""
        updatedAt = dictionary[ParseReturnConstants.updatedAt] as? String ?? ""
    }
    mutating func inserted(objectId: String, createdAt: String) {
        self.objectId = objectId
        self.createdAt = createdAt
    }
}
