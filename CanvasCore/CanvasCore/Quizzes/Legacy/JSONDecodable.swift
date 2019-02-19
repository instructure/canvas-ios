//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
