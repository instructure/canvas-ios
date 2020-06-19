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
import XCTest
@testable import Core
import UserNotifications

class NotificationManagerTests: CoreTestCase {
    func testNotify() {
        notificationManager.notify(identifier: "one", title: "Title", body: "Body", route: "/courses")
        let request = notificationCenter.requests.last
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.content.title, "Title")
        XCTAssertEqual(request?.content.body, "Body")
        XCTAssertEqual(request?.identifier, "one")
        XCTAssert(request?.trigger is UNTimeIntervalNotificationTrigger)
        XCTAssertEqual((request?.trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval, 1)
        XCTAssertEqual((request?.trigger as? UNTimeIntervalNotificationTrigger)?.repeats, false)
        XCTAssertEqual(request?.content.userInfo[NotificationManager.RouteURLKey] as? String, "/courses")
    }

    func testNotifyLogsError() {
        notificationCenter.error = NSError.instructureError("error")
        notificationManager.notify(identifier: "one", title: "Title", body: "Body", route: nil)
        let log = logger.errors.last
        XCTAssertNotNil(log)
        XCTAssertEqual(log, "error")
    }
}
