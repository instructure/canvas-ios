//
//  LocalNotificationHandler.swift
//  SoLazy
//
//  Created by Nathan Lambson on 1/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

public struct NotifiableObject {
    var due: NSDate
    var name: String
    var url: NSURL
    var id: String
    
    public init(due: NSDate, name: String, url: NSURL, id: String) {
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

public class LocalNotificationHandler {
    //# MARK: - init / singleton
    
    //The one-liner singleton http://krakendev.io/blog/the-right-way-to-write-a-singleton
    public static let sharedInstance = LocalNotificationHandler()
    
    //'private' prevents others from using the default '()' initializer for this class.
    private init() {}
    
    public var notificationApplication : UIApplication? = nil
    
    //# MARK: - register
    
    public func canScheduleLocalNotifications() -> Bool {
        guard let application = notificationApplication else {
            print("ERROR: Can not check notification preferences without a valid instance of UIApplication")
            return false
        }
        
        if let localNotifications = application.scheduledLocalNotifications {
            if localNotifications.count >= LocalNotificationConstants.LocalNotificationOperatingSystemMax {
                return false
            }
        }
        
        if let permissions = application.currentUserNotificationSettings() {
            if permissions.types.contains([.Alert, .Badge]) {
                return true
            } else if permissions.types.contains([.Alert]) {
                return true
            }
            
            return false
        }
        
        return false
    }
    
    public func scheduleLocaNotification(notifiableObject: NotifiableObject, offsetInMinutes: Int) {
        let reminderDate = NSDate(timeInterval: Double(-LocalNotificationConstants.LocalNotificationNumberSecondsInMinute * offsetInMinutes), sinceDate: notifiableObject.due)
        let body = "\(notifiableObject.name) is due in \(dueDateFromMinuteOffset(offsetInMinutes))"
        scheduleLocalNotification(body, fireDate: reminderDate, userInfo: userInfoDictionary(notifiableObject))
    }
    
    public func scheduleLocalNotification(body: String, fireDate: NSDate, userInfo: [String : String]?) {
        guard let application = notificationApplication else {
            print("ERROR: Can not schedule notification without a valid instance of UIApplication")
            return
        }
        
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.alertAction = "View" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = fireDate
        notification.userInfo = userInfo
        
        if ((application.currentUserNotificationSettings()?.types.contains([.Badge])) != nil) {
            notification.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        }
        
        notification.timeZone = NSTimeZone.localTimeZone()
        
        application.scheduleLocalNotification(notification)
    }

    //# MARK: - unregister

    public func removeLocalNotification(assignmentID : String) {
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
    
    func userInfoDictionary(assignment : NotifiableObject) -> [String : String] {
        return [
            LocalNotificationConstants.LocalNotificationAssignmentIDKey : assignment.id,
            LocalNotificationConstants.LocalNotificationAssignmentURLKey : assignment.url.description ?? ""
        ]
    }
 
    func dueDateFromMinuteOffset(minutes : Int) -> String {
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
    
    func localNotification(assignmentID : String) -> UILocalNotification? {
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
    
    public func localNotificationExists(assignmentID : String) -> Bool {
        if let _ = localNotification(assignmentID) {
            return true
        }
        
        return false
    }
    
}

