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

class AccountNotificationsTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return AccountNotificationsTests.self }
    override var user: UITestUser? { return nil }

    func testRefresh() {
        mockBaseRequests()
        logIn(domain: "canvas.instructure.com", token: "t")

        Dashboard.coursesLabel.waitToExist()
        mockData(GetAccountNotificationsRequest(), value: [ .make() ])
        pullToRefresh()
        AccountNotifications.toggleButton(id: "1").waitToExist()
    }
}
