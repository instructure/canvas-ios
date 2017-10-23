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
    
    

import UIKit
import CanvasCore

let RemindableIDKey = "RemindableID"
let RemindableActionURLKey = "RemindableActionURL"

// TODO: SoForgetful?
// UIApplication is not accessible from SoLazy because that framework has been marked as safe for extensions
// so maybe make a framework that is not safe for extensionts, a "SoForgetful" and throw this in there?

protocol Remindable {
    var id: String { get }
    var reminderBody: String { get }
    var defaultReminderDate: Date { get }

    func scheduleReminder(atTime date: Date, actionURL: URL)
    func scheduledReminder() -> UILocalNotification?
    func cancelReminder()
}

extension Remindable {
    func scheduleReminder(atTime date: Date, actionURL: URL) {
        if let _ = scheduledReminder() {
            cancelReminder()
        }

        let notification = UILocalNotification()
        notification.alertBody = reminderBody
        notification.alertAction = NSLocalizedString("View", comment: "Name of action when viewing a reminder")
        notification.fireDate = date
        notification.timeZone = TimeZone.autoupdatingCurrent
        notification.userInfo = [RemindableIDKey: id, RemindableActionURLKey: actionURL.absoluteString]
        UIApplication.shared.scheduleLocalNotification(notification)
    }

    func scheduledReminder() -> UILocalNotification? {
        let application = UIApplication.shared

        let notes = application.scheduledLocalNotifications?.filter {
            guard let id = $0.userInfo?[RemindableIDKey] as? String, id == self.id else { return false}
            return true
        }
        return notes?.first
    }

    func cancelReminder() {
        if let reminder = self.scheduledReminder() {
            UIApplication.shared.cancelLocalNotification(reminder)
        }
    }
}

import CanvasCore

extension Assignment: Remindable {
    fileprivate static var dueDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var reminderBody: String {
        if let dueDate = due {
            return String(format: NSLocalizedString("Assignment reminder: %@ is due at %@", comment: ""), name, Assignment.dueDateFormatter.string(from: dueDate))
        } else {
            return String(format: NSLocalizedString("Assignment reminder: %@", comment: ""), name)
        }
    }

    var defaultReminderDate: Date {
        if let dueDate = due {
            return dueDate - 1.daysComponents // 1 day before the assignment is due
        } else {
            return Date() + 1.daysComponents // if no due date, just put me 1 day into the future, I can change it if needed
        }
    }
}

import CanvasCore

extension CalendarEvent: Remindable {
    fileprivate static var startAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    var reminderBody: String {
        guard let title = title else {
            return ""
        }
        switch type {
        case .assignment where endAt != nil,
             .quiz where endAt != nil,
             .discussion where endAt != nil:
            return String(format: NSLocalizedString("Assignment reminder: %@ is due at %@", comment: ""), title, Assignment.dueDateFormatter.string(from: endAt!))
        case .calendarEvent where startAt != nil:
            return String(format: NSLocalizedString("Event reminder: %@ will begin at %@", comment: ""), title, CalendarEvent.startAtDateFormatter.string(from: startAt!))
        case .assignment, .quiz, .discussion, .calendarEvent: // "Case will never be executed" my BUTT! It has one less statement than the other two!
            return String(format: NSLocalizedString("Event reminder: %@", comment: ""), title)
        default:
            return "" // For our purposes, there should always be a time and title attached
        }
    }

    var defaultReminderDate: Date {
        guard let startAt = startAt else { return Date()+1.weeksComponents }
        switch type {
        case .assignment:
            return startAt - 1.daysComponents // If it's an assignment, remind me 1 day before it's due by default
        default:
            return startAt - 1.hoursComponents // If it's some sort of event, 1 hour prior to the event?
        }
    }
}

