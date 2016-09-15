//
//  NotificationPreference.swift
//  NotificationKit
//
//  Created by Miles Wright on 6/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public class NotificationPreference: CustomStringConvertible {
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
    public var frequency: Frequency
    var notification: String
    
    public var description: String {
        return "Category: \(category) Frequency: \(frequency) Notification: \(notification)"
    }
    
    public static func create(dictionary: Dictionary<String, AnyObject>) -> NotificationPreference? {
        if  let category        = dictionary["category"] as? String,
            let frequency       = dictionary["frequency"] as? String,
            let notification    = dictionary["notification"] as? String {
                return NotificationPreference(category: category, frequency: frequency, notification: notification)
        } else {
            return nil
        }
    }
    
    private init(category: String, frequency: String, notification: String) {
        self.category = category
        if let frequencyToSet = Frequency(rawValue: frequency) {
            self.frequency = frequencyToSet
        } else {
            self.frequency = Frequency(on: false)
        }
        self.notification = notification
    }
}
