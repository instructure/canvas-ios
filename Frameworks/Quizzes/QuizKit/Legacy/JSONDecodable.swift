//
//  JSONDecodable.swift
//  SoLazy
//
//  Created by Ben Kraus on 4/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    typealias DecodedType = Self
    static func fromJSON(json: AnyObject?) -> DecodedType?
}

func idString(json: AnyObject?) -> String? {
    return (json as? String) ?? (json as? NSNumber).map { String($0.integerValue) }
}

func decodeArray<A where A: JSONDecodable, A == A.DecodedType>(jsonObjects: [AnyObject]) -> [A] {
    return jsonObjects.reduce([]) { soFar, any in
        if let t = A.fromJSON(any) {
            return soFar + [t]
        }
        return soFar
    }
}

extension NSDate: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> NSDate? {
        if let dateString = json as? String {
            // TODO: We should probably be using a real ISO 8601 date formatter
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            return formatter.dateFromString(dateString)
        }
        
        return nil
    }
}

extension NSURL: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> NSURL? {
        if let urlString = json as? String {
            return NSURL(string: urlString)
        }
        
        return nil
    }
}

extension String: JSONDecodable {
    static func fromJSON(json: AnyObject?) -> String? {
        if let string = json as? String {
            return string
        }
        
        return nil
    }
}