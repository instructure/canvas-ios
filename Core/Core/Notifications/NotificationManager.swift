//
// Copyright (C) 2018-present Instructure, Inc.
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

    public func notify(title: String, body: String, route: Route?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let route = route {
            content.userInfo[NotificationManager.RouteURLKey] = route.url.url?.absoluteString
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "com.instructure.core.NotificationManager.notify",
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
