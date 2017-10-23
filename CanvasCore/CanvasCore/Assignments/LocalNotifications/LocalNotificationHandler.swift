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

public struct NotifiableObject {
    var due: Date
    var name: String
    var url: URL
    var id: String
    
    public init(due: Date, name: String, url: URL, id: String) {
        self.due = due
        self.name = name
        self.url = url
        self.id = id
    }
}

struct LocalNotificationConstants {
    static let LocalNotificationNumberSecondsInMinute : Int = 60
    static let LocalNotificationNumberMinutesInHour : Int = 60
    static let LocalNotificationNumberMinutesInDay : Int =  LocalNotificationNumberMinutesInHour * 24
    static let LocalNotificationAssignmentIDKey = "assignmentID"
    static let LocalNotificationAssignmentURLKey = "assignmentURL"
    static let LocalNotificationOperatingSystemMax = 64
}

open class LocalNotificationHandler {
    //# MARK: - init / singleton
    
    //The one-liner singleton http://krakendev.io/blog/the-right-way-to-write-a-singleton
    open static let sharedInstance = LocalNotificationHandler()
    
    //'private' prevents others from using the default '()' initializer for this class.
    fileprivate init() {}
    
    open var notificationApplication : UIApplication? = nil
    
    //# MARK: - register
    
    open func canScheduleLocalNotifications() -> Bool {
        guard let application = notificationApplication else {
            print("ERROR: Can not check notification preferences without a valid instance of UIApplication")
            return false
        }
        
        if let localNotifications = application.scheduledLocalNotifications {
            if localNotifications.count >= LocalNotificationConstants.LocalNotificationOperatingSystemMax {
                return false
            }
        }
        
        if let permissions = application.currentUserNotificationSettings {
            if permissions.types.contains([.alert, .badge]) {
                return true
            } else if permissions.types.contains([.alert]) {
                return true
            }
            
            return false
        }
        
        return false
    }
    
    open func scheduleLocaNotification(_ notifiableObject: NotifiableObject, offsetInMinutes: Int) {
        let reminderDate = Date(timeInterval: Double(-LocalNotificationConstants.LocalNotificationNumberSecondsInMinute * offsetInMinutes), since: notifiableObject.due)
        let body = "\(notifiableObject.name) is due in \(dueDateFromMinuteOffset(offsetInMinutes))"
        scheduleLocalNotification(body, fireDate: reminderDate, userInfo: userInfoDictionary(notifiableObject))
    }
    
    open func scheduleLocalNotification(_ body: String, fireDate: Date, userInfo: [String : String]?) {
        guard let application = notificationApplication else {
            print("ERROR: Can not schedule notification without a valid instance of UIApplication")
            return
        }
        
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.alertAction = "View" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = fireDate
        notification.userInfo = userInfo
        
        if ((application.currentUserNotificationSettings?.types.contains([.badge])) != nil) {
            notification.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        }
        
        notification.timeZone = TimeZone.autoupdatingCurrent
        
        application.scheduleLocalNotification(notification)
    }

    //# MARK: - unregister

    open func removeLocalNotification(_ assignmentID : String) {
        guard let application = notificationApplication else {
            print("ERROR: Can not remove notifications without a valid instance of UIApplication")
            return
        }
        
        if let notification = localNotification(assignmentID) {
            //Cancelling local notification
            application.cancelLocalNotification(notification)
        }
    }
    
    //# MARK: - helper
    
    func userInfoDictionary(_ assignment : NotifiableObject) -> [String : String] {
        return [
            LocalNotificationConstants.LocalNotificationAssignmentIDKey : assignment.id,
            LocalNotificationConstants.LocalNotificationAssignmentURLKey : assignment.url.description ?? ""
        ]
    }
 
    func dueDateFromMinuteOffset(_ minutes : Int) -> String {
        switch minutes {
        case _ where minutes <= 1:
            return "\(minutes) minute"
        case _ where minutes < LocalNotificationConstants.LocalNotificationNumberMinutesInHour:
            return "\(minutes) minutes"
        default: break
        }
        
        let hours = minutes / LocalNotificationConstants.LocalNotificationNumberMinutesInHour
        switch hours {
        case _ where hours <= 1:
            return "\(hours) hour"
        case _ where hours < LocalNotificationConstants.LocalNotificationNumberMinutesInDay / LocalNotificationConstants.LocalNotificationNumberMinutesInHour:
            return "\(hours) hours"
        default: break
        }
        
        let days = minutes / LocalNotificationConstants.LocalNotificationNumberMinutesInDay
        switch days {
        case _ where days <= 1:
            return "\(days) day"
        default:
            return "\(days) days"
        }
    }
    
    func localNotification(_ assignmentID : String) -> UILocalNotification? {
        guard let application = notificationApplication else {
            print("ERROR: Can not access notifications without a valid instance of UIApplication")
            return nil
        }
        
        if let localNotifications = application.scheduledLocalNotifications {
            for notification in localNotifications {
                if (notification.userInfo![LocalNotificationConstants.LocalNotificationAssignmentIDKey] as! String == assignmentID) {
                    return notification
                }
            }
        }
        
        return nil
    }
    
    open func localNotificationExists(_ assignmentID : String) -> Bool {
        if let _ = localNotification(assignmentID) {
            return true
        }
        
        return false
    }
    
}

