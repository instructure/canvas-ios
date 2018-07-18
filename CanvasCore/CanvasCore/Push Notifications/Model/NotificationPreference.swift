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
