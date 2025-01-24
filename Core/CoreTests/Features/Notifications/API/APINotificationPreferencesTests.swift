//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
@testable import Core

class APINotificationPreferencesTests: CoreTestCase {
    func testNotificationFrequencyName() {
        XCTAssertEqual(NotificationFrequency.immediately.name, "Immediately")
        XCTAssertEqual(NotificationFrequency.daily.name, "Daily")
        XCTAssertEqual(NotificationFrequency.weekly.name, "Weekly")
        XCTAssertEqual(NotificationFrequency.never.name, "Never")
    }

    func testNotificationFrequencyLabel() {
        XCTAssertEqual(NotificationFrequency.immediately.label, "Notify me right away")
        XCTAssertEqual(NotificationFrequency.daily.label, "Send daily summary")
        XCTAssertEqual(NotificationFrequency.weekly.label, "Send weekly summary")
        XCTAssertEqual(NotificationFrequency.never.label, "Do not send me anything")
    }

    func testGetNotificationPreferencesRequest() {
        XCTAssertEqual(GetNotificationPreferencesRequest(channelID: "2").path, "users/self/communication_channels/2/notification_preferences")
    }

    func testPutNotificationPreferencesRequest() {
        let request = PutNotificationPreferencesRequest(channelID: "4", notifications: ["one", "two"], frequency: .daily)
        XCTAssertEqual(request.path, "users/self/communication_channels/4/notification_preferences")
        XCTAssertEqual(request.body, .init(notification_preferences: [
            "one": [ "frequency": .daily ],
            "two": [ "frequency": .daily ]
        ]))
    }
}
