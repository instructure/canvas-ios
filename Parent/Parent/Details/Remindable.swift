//
//  Remindable.swift
//  Parent
//
//  Created by Ben Kraus on 3/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import SoLazy

let RemindableIDKey = "RemindableID"
let RemindableActionURLKey = "RemindableActionURL"

// TODO: SoForgetful?
// UIApplication is not accessible from SoLazy because that framework has been marked as safe for extensions
// so maybe make a framework that is not safe for extensionts, a "SoForgetful" and throw this in there?

protocol Remindable {
    var id: String { get }
    var reminderBody: String { get }
    var defaultReminderDate: NSDate { get }

    func scheduleReminder(atTime date: NSDate, actionURL: NSURL)
    func scheduledReminder() -> UILocalNotification?
    func cancelReminder()
}

extension Remindable {
    func scheduleReminder(atTime date: NSDate, actionURL: NSURL) {
        if let _ = scheduledReminder() {
            cancelReminder()
        }

        let notification = UILocalNotification()
        notification.alertBody = reminderBody
        notification.alertAction = NSLocalizedString("View", comment: "Name of action when viewing a reminder")
        notification.fireDate = date
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.userInfo = [RemindableIDKey: id, RemindableActionURLKey: actionURL.absoluteString!]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func scheduledReminder() -> UILocalNotification? {
        let application = UIApplication.sharedApplication()

        let notes = application.scheduledLocalNotifications?.filter {
            guard let id = $0.userInfo?[RemindableIDKey] as? String where id == self.id else { return false}
            return true
        }
        return notes?.first
    }

    func cancelReminder() {
        if let reminder = self.scheduledReminder() {
            UIApplication.sharedApplication().cancelLocalNotification(reminder)
        }
    }
}

import AssignmentKit

extension Assignment: Remindable {
    private static var dueDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    var reminderBody: String {
        if let dueDate = due {
            return String(format: NSLocalizedString("Assignment reminder: %@ is due at %@", comment: ""), name, Assignment.dueDateFormatter.stringFromDate(dueDate))
        } else {
            return String(format: NSLocalizedString("Assignment reminder: %@", comment: ""), name)
        }
    }

    var defaultReminderDate: NSDate {
        if let dueDate = due {
            return dueDate - 1.daysComponents // 1 day before the assignment is due
        } else {
            return NSDate() + 1.daysComponents // if no due date, just put me 1 day into the future, I can change it if needed
        }
    }
}

import CalendarKit

extension CalendarEvent: Remindable {
    private static var startAtDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    var reminderBody: String {
        guard let title = title else {
            return ""
        }
        switch type {
        case .Assignment, .Quiz, .Discussion where endAt != nil:
            return String(format: NSLocalizedString("Assignment reminder: %@ is due at %@", comment: ""), title, Assignment.dueDateFormatter.stringFromDate(endAt!))
        case .CalendarEvent where startAt != nil:
            return String(format: NSLocalizedString("Event reminder: %@ will begin at %@", comment: ""), title, CalendarEvent.startAtDateFormatter.stringFromDate(startAt!))
        case .Assignment, .Quiz, .Discussion, .CalendarEvent: // "Case will never be executed" my BUTT! It has one less statement than the other two!
            return String(format: NSLocalizedString("Event reminder: %@", comment: ""), title)
        default:
            return "" // For our purposes, there should always be a time and title attached
        }
    }

    var defaultReminderDate: NSDate {
        guard let startAt = startAt else { return NSDate()+1.weeksComponents }
        switch type {
        case .Assignment:
            return startAt - 1.daysComponents // If it's an assignment, remind me 1 day before it's due by default
        default:
            return startAt - 1.hoursComponents // If it's some sort of event, 1 hour prior to the event?
        }
    }
}

