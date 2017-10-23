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

open class NotificationPreference: CustomStringConvertible {
    public enum Frequency: String, CustomStringConvertible {
        case Immediately = "immediately"
        case Daily = "daily"
        case Weekly = "weekly"
        case Never = "never"
        
        var opposite: Frequency {
            switch self {
            case .Immediately:
                return .Never
            default:
                return .Immediately
            }
        }
        
        // on corresponds to .Immediately
        // off corresponds to .Never
        init(on: Bool) {
            switch on {
            case true:
                self = .Immediately
            default:
                self = .Never
            }
        }
        
        var immediately: Bool {
            switch self {
            case .Immediately:
                return true
            default:
                return false
            }
        }
        
        public var description: String {
            return self.rawValue
        }
    }
    
    var category: String
    open var frequency: Frequency
    var notification: String
    
    open var description: String {
        return "Category: \(category) Frequency: \(frequency) Notification: \(notification)"
    }
    
    open static func create(_ dictionary: Dictionary<String, Any>) -> NotificationPreference? {
        if  let category        = dictionary["category"] as? String,
            let frequency       = dictionary["frequency"] as? String,
            let notification    = dictionary["notification"] as? String {
                return NotificationPreference(category: category, frequency: frequency, notification: notification)
        } else {
            return nil
        }
    }
    
    fileprivate init(category: String, frequency: String, notification: String) {
        self.category = category
        if let frequencyToSet = Frequency(rawValue: frequency) {
            self.frequency = frequencyToSet
        } else {
            self.frequency = Frequency(on: false)
        }
        self.notification = notification
    }
}
