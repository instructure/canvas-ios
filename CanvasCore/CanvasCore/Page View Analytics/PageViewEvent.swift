//
// Copyright (C) 2018-present Instructure, Inc.
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

typealias PageViewEventDictionary = [String: CodableValue]
extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func convertToPageViewEventDictionary() -> PageViewEventDictionary {
        var obj = PageViewEventDictionary()
        for (k, v) in self {
            if let codableValue = try? CodableValue(v), let key = k as? String {
                obj[key] = codableValue
            }
        }
        return obj
    }
}

public struct PageViewEvent: Codable {
    let eventName: String
    let eventDuration: TimeInterval
    var attributes = PageViewEventDictionary()
    let timestamp: String
    let userID: String
    
    init(eventName: String, attributes: PageViewEventDictionary? = nil, userID: String, timestamp: String = PageViewEvent.ISOTimeStamp(), eventDuration: TimeInterval = 0) {
        self.eventName = eventName
        self.eventDuration = eventDuration
        self.timestamp = timestamp
        self.userID = userID

        if let attributes = attributes, attributes.count > 0 {
            self.attributes = attributes
        }
    }
    
    static let dateFormatter: ISO8601DateFormatter = {
        var df = ISO8601DateFormatter()
        return df
    }()
    
    private static func ISOTimeStamp(_ date: Date = Date()) -> String {
        return dateFormatter.string(from: date)
    }
}
