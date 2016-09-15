//
//  Session+RejectNilParameters.swift
//  TooLegit
//
//  Created by Brandon Pluim on 2/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

public extension Session {
    public static func rejectNilParameters(source: [String:AnyObject?]) -> [String:AnyObject] {
        var destination : [String:AnyObject] = [:]
        for (key, nillableValue) in source {
            if let value: AnyObject = nillableValue {
                destination[key] = value
            }
        }

        return destination
    }
}