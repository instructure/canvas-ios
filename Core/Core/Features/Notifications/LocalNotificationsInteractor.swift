//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import UserNotifications

public class LocalNotificationsInteractor {
    public let notificationCenter: UserNotificationCenterProtocol

    public init(
        notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()
    ) {
        self.notificationCenter = notificationCenter
    }

    func sendFailedNotification(courseID: String, assignmentID: String) {
        let identifier = "failed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)
        return notify(identifier: identifier, title: title, body: body, route: route)
    }

    func sendCompletedNotification(courseID: String, assignmentID: String) {
        let identifier = "completed-submission-\(courseID)-\(assignmentID)"
        let route = "/courses/\(courseID)/assignments/\(assignmentID)"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submitted!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Your files were uploaded and the assignment was submitted successfully.", arguments: nil)
        return notify(identifier: identifier, title: title, body: body, route: route)
    }

    func sendFailedNotification() {
        let title = NSString.localizedUserNotificationString(forKey: "Failed to send files!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with uploading files.", arguments: nil)
        return notify(identifier: "upload-manager", title: title, body: body, route: nil)
    }

    func sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: Int) -> Future<Void, Error> {
        let title = String(localized: "Offline Content Sync Success", bundle: .core)
        let bodyFormat = String(localized: "offline_sync_finished", bundle: .core)
        let body = String.localizedStringWithFormat(bodyFormat, syncedItemsCount, syncedItemsCount)

        return notify(identifier: "OfflineSyncCompletedSuccessfully", title: title, body: body, route: nil)
    }

    /**
     - returns: True is the notification was scheduled successfully.
     */
    @discardableResult
    func sendOfflineSyncFailedNotificationAndWait() -> Bool {
        let title = String(localized: "Offline Content Sync Failed", bundle: .core)
        let body = String(localized: "One or more items failed to sync. Please check your internet connection and retry syncing.", bundle: .core)
        let semaphore = DispatchSemaphore(value: 0)
        var isScheduled = false
        notify(identifier: "OfflineSyncFailed", title: title, body: body, route: nil) { error in
            semaphore.signal()
            isScheduled = (error == nil)
        }
        semaphore.wait()
        return isScheduled
    }

    func sendOfflineSyncFailedNotification() -> Future<Void, Error> {
        Future<Void, Error> { [self] promise in
            let isScheduled = sendOfflineSyncFailedNotificationAndWait()
            promise(isScheduled ? .success(()) : .failure(NSError.internalError()))
        }
    }

    // MARK: - Private Helpers

    private func notify(
        identifier: String,
        title: String,
        body: String,
        route: String?,
        completion: ((Error?) -> Void)? = nil
    ) {
        let request = UNNotificationRequest(
            identifier: identifier,
            title: title,
            body: body,
            route: route
        )
        notificationCenter.add(request) { error in
            if let error = error {
                RemoteLogger.shared.logError(name: "Failed to schedule local notification",
                                          reason: error.localizedDescription)
            }
            completion?(error)
        }
    }

    private func notify(
        identifier: String,
        title: String,
        body: String,
        route: String?
    ) -> Future<Void, Error> {
        Future<Void, Error> { [self] promise in
            notify(identifier: identifier, title: title, body: body, route: route) { error in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
    }
}

public extension UNNotificationRequest {

    convenience init(
        identifier: String,
        title: String,
        body: String,
        route: String?
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let route {
            content.userInfo[UNNotificationContent.RouteURLKey] = route
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        self.init(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }
}
