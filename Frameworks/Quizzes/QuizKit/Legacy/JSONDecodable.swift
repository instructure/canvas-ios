
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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