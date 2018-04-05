//
// Copyright (C) 2018-present Instructure, Inc.
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
    
    init(eventName: String, attributes: PageViewEventDictionary? = nil, userID: String, timestamp: String = PageViewEvent.UTCTimeStamp(), eventDuration: TimeInterval = 0) {
        self.eventName = eventName
        self.eventDuration = eventDuration
        self.timestamp = timestamp
        self.userID = userID

        if let attributes = attributes, attributes.count > 0 {
            self.attributes = attributes
        }
    }
    
    static let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "yyyy:MM:dd HH:mm:ss.SSSZZZZZ"
        return df
    }()
    
    private static func UTCTimeStamp(_ date: Date = Date()) -> String {
        return dateFormatter.string(from: date)
    }
}
