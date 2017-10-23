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
    associatedtype DecodedType = Self
    static func fromJSON(_ json: Any?) -> DecodedType?
}

func idString(_ json: Any?) -> String? {
    return (json as? String) ?? (json as? NSNumber).map { String($0.intValue) }
}

func decodeArray<A>(_ jsonObjects: [Any]) -> [A] where A: JSONDecodable, A == A.DecodedType {
    return jsonObjects.reduce([]) { soFar, any in
        if let t = A.fromJSON(any) {
            return soFar + [t]
        }
        return soFar
    }
}

extension Date: JSONDecodable {
    static func fromJSON(_ json: Any?) -> Date? {
        if let dateString = json as? String {
            // TODO: We should probably be using a real ISO 8601 date formatter
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            return formatter.date(from: dateString)
        }
        
        return nil
    }
}

extension URL: JSONDecodable {
    static func fromJSON(_ json: Any?) -> URL? {
        if let urlString = json as? String {
            return URL(string: urlString)
        }
        
        return nil
    }
}

extension String: JSONDecodable {
    static func fromJSON(_ json: Any?) -> String? {
        if let string = json as? String {
            return string
        }
        
        return nil
    }
}
