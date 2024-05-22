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

import Combine
import XCTest
@testable import Core
import UserNotifications

class NotificationManagerTests: CoreTestCase {

    func testRemoteNotifications() {
        notificationManager.registerForRemoteNotifications(application: .shared)

        let token = Data([1])
        api.mock(PostCommunicationChannelRequest(pushToken: token), value: .make())
        api.mock(GetNotificationDefaultsFlagRequest(), value: nil)
        api.mock(GetNotificationPreferencesRequest(channelID: "1"), value: .init(notification_preferences: [
            .make(notification: "ignored", category: "alert", frequency: .daily),
            .make(notification: "new", category: "assignment", frequency: .daily),
        ]))
        api.mock(PutNotificationDefaultsFlagRequest(), value: .init(data: "true"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, nil)

        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, nil)

        notificationManager.remoteToken = nil // reset
        api.mock(PutNotificationDefaultsFlagRequest(), error: NSError.instructureError("flag"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, "flag")

        notificationManager.remoteToken = nil // reset
        api.mock(PutNotificationPreferencesRequest(channelID: "1", notifications: ["new"], frequency: .immediately), error: NSError.instructureError("prefs"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, "prefs")

        notificationManager.remoteToken = nil // reset
        api.mock(GetNotificationPreferencesRequest(channelID: "1"), error: NSError.instructureError("getprefs"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, "getprefs")

        notificationManager.remoteToken = nil // reset
        logger.errors = []
        api.mock(GetNotificationDefaultsFlagRequest(), value: .init(data: "true"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())
        XCTAssertEqual(logger.errors.last, nil)

        notificationManager.remoteToken = nil // reset
        let lost = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)
        api.mock(PostCommunicationChannelRequest(pushToken: token), error: lost)
        environment.errorHandler = { e, _ in XCTAssertEqual(e as NSError, lost) }
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make())

        api.mock(DeletePushChannelRequest(pushToken: token), value: .init())
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make(userID: "2"))

        notificationManager.remoteSession = .make()
        api.mock(DeletePushChannelRequest(pushToken: token), error: NSError.instructureError("delete"))
        notificationManager.subscribeToPushChannel(deviceToken: token, session: .make(userID: "2"))
        XCTAssertEqual(logger.errors.last, "delete")
    }
}
