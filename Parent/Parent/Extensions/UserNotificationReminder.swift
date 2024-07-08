//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import UserNotifications
import Core

let RemindableStudentIDKey = "RemindableStudentID"
let RemindableActionURLKey = "RemindableActionURL"

extension LocalNotificationsInteractor {

    func setReminder(for event: CalendarEvent, at date: Date, studentID: String, callback: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Event reminder", bundle: .parent)
        content.body = String.localizedStringWithFormat(
            String(localized: "%@ will begin at %@", bundle: .parent),
            event.title,
            event.startAt!.dateTimeString
        )
        content.userInfo = [
            RemindableStudentIDKey: studentID,
            RemindableActionURLKey: event.htmlURL!.absoluteString
        ]
        setReminder(id: event.id, content: content, at: date, callback: callback)
    }

    func setReminder(for assignment: Assignment, at date: Date, studentID: String, callback: @escaping (Error?) -> Void) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Assignment reminder", bundle: .parent)
        content.body = assignment.dueAt.map { String.localizedStringWithFormat(
            String(localized: "%@ is due at %@", bundle: .parent),
            assignment.name,
            $0.dateTimeString
        ) } ?? assignment.name
        content.userInfo = [
            RemindableStudentIDKey: studentID,
            RemindableActionURLKey: assignment.htmlURL!.absoluteString
        ]
        setReminder(id: assignment.id, content: content, at: date, callback: callback)
    }

    func setReminder(id: String, content: UNMutableNotificationContent, at date: Date, callback: @escaping (Error?) -> Void) {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: callback)
    }

    func getReminder(_ id: String, callback: @escaping (UNNotificationRequest?) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            callback(requests.first { $0.identifier == id })
        }
    }

    func removeReminder(_ id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
