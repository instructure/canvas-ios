//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core
import UserNotifications

class NotificationManagerTests: CoreTestCase {
    func testNotify() {
        notificationManager.notify(identifier: "one", title: "Title", body: "Body", route: Route.courses)
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
