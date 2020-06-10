//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import CanvasCore
import UserNotifications

let RemindableIDKey = "RemindableID"
let RemindableStudentIDKey = "RemindableStudentID"
let RemindableActionURLKey = "RemindableActionURL"

// TODO: SoForgetful?
// UIApplication is not accessible from SoLazy because that framework has been marked as safe for extensions
// so maybe make a framework that is not safe for extensionts, a "SoForgetful" and throw this in there?

protocol Remindable {
    var id: String { get }
    var reminderBody: String { get }
    var reminderTitle: String { get }
    var defaultReminderDate: Date { get }

    func scheduleReminder(atTime date: Date, studentID: String, actionURL: URL, completionHandler: @escaping (Error?) -> Void)
    func getScheduledReminder(completionHandler: @escaping (UNNotificationRequest?) -> Void)
    func cancelReminder()
}

extension Remindable {
    func scheduleReminder(atTime date: Date, studentID: String, actionURL: URL, completionHandler: @escaping (Error?) -> Void) {
        getScheduledReminder { pending in
            if pending != nil {
                self.cancelReminder()
            }
            self.scheduleNotificationRequest(forDate: date, studentID: studentID, actionURL: actionURL, completionHandler: completionHandler)
        }
    }

    private func scheduleNotificationRequest(forDate date: Date, studentID: String, actionURL: URL, completionHandler: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = reminderTitle
        content.body = reminderBody
        content.userInfo = [RemindableIDKey: id, RemindableStudentIDKey: studentID, RemindableActionURLKey: actionURL.absoluteString]
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completionHandler)
    }

    func getScheduledReminder(completionHandler: @escaping (UNNotificationRequest?) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            let request = requests.first { $0.identifier == self.id }
            completionHandler(request)
        }
    }

    func cancelReminder() {
        getScheduledReminder { request in
            if let request = request {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
    }
}

struct Reminder: Remindable {
    let id: String
    let title: String
    let body: String
    let date: Date

    // Remindable
    var reminderTitle: String {
        return title
    }

    var reminderBody: String {
        return body
    }

    var defaultReminderDate: Date {
        return date
    }
}

extension Assignment: Remindable {
    fileprivate static var dueDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    @objc var reminderTitle: String {
        return NSLocalizedString("Assignment reminder", comment: "")
    }

    @objc var reminderBody: String {
        if let dueDate = due {
            return String(format: NSLocalizedString("%@ is due at %@", comment: ""), name, Assignment.dueDateFormatter.string(from: dueDate))
        } else {
            return name
        }
    }

    @objc var defaultReminderDate: Date {
        if let dueDate = due {
            return dueDate - 1.daysComponents // 1 day before the assignment is due
        } else {
            return Date() + 1.daysComponents // if no due date, just put me 1 day into the future, I can change it if needed
        }
    }
}

extension CalendarEvent: Remindable {
    fileprivate static var startAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    @objc var reminderTitle: String {
        switch type {
        case .assignment where endAt != nil,
             .quiz where endAt != nil,
             .discussion where endAt != nil:
            return NSLocalizedString("Assignment reminder", comment: "")
        default:
            return NSLocalizedString("Event reminder", comment: "")
        }
    }

    @objc var reminderBody: String {
        guard let title = title else {
            return ""
        }
        switch type {
        case .assignment where endAt != nil,
             .quiz where endAt != nil,
             .discussion where endAt != nil:
            return String(format: NSLocalizedString("%@ is due at %@", comment: ""), title, Assignment.dueDateFormatter.string(from: endAt!))
        case .calendarEvent where startAt != nil:
            return String(format: NSLocalizedString("%@ will begin at %@", comment: ""), title, CalendarEvent.startAtDateFormatter.string(from: startAt!))
        case .assignment, .quiz, .discussion, .calendarEvent:
            return title
        default:
            return "" // For our purposes, there should always be a time and title attached
        }
    }

    @objc var defaultReminderDate: Date {
        guard let startAt = startAt else { return Date()+1.weeksComponents }
        switch type {
        case .assignment:
            return startAt - 1.daysComponents // If it's an assignment, remind me 1 day before it's due by default
        default:
            return startAt - 1.hoursComponents // If it's some sort of event, 1 hour prior to the event?
        }
    }
}
