//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import UserNotifications

protocol UserNotificationCenterProtocol {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}

public class NotificationManager {
    public static let RouteURLKey = "com.instructure.core.router.notification-url"

    let notificationCenter: UserNotificationCenterProtocol
    let logger: LoggerProtocol

    public static var shared: NotificationManager = {
        return NotificationManager(
            notificationCenter: UNUserNotificationCenter.current(),
            logger: AppEnvironment.shared.logger
        )
    }()

    init(notificationCenter: UserNotificationCenterProtocol, logger: LoggerProtocol) {
        self.notificationCenter = notificationCenter
        self.logger = logger
    }

    public func notify(identifier: String, title: String, body: String, route: String?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let route = route {
            content.userInfo[NotificationManager.RouteURLKey] = route
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        notificationCenter.add(request) { [weak self] error in
            if let error = error {
                self?.logger.error(error.localizedDescription)
            }
        }
    }
}

extension UNNotificationRequest {
    public var route: String? {
        content.userInfo[NotificationManager.RouteURLKey] as? String
    }
}

extension UNNotification {
    public var route: String? {
        return request.route
    }
}
