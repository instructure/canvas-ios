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
import TestsFoundation
@testable import Core
@testable import CoreUITests

class NotificationsListTests: CoreUITestCase {
    override var user: UITestUser? { return nil }

    func testNotificationItemsDisplayed() {
        mockBaseRequests()
        mockEncodableRequest("users/self/activity_stream?per_page=99", value: [
            APIActivity.make(),
            APIActivity.make(id: "2", title: "Another Notification"),
        ])

        logIn(domain: "canvas.instructure.com", token: "t")
        TabBar.notificationsTab.tap()

        app.find(labelContaining: "Assignment Created").waitToExist()
        app.find(labelContaining: "Another Notification").waitToExist()
    }
}
