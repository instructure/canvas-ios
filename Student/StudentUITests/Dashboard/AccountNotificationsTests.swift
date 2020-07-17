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
    let announcement1 = APIAccountNotification.make(id: "1")
    let announcement2 = APIAccountNotification.make(id: "2")

    func testRefresh() {
        mockBaseRequests()
        logIn()

        mockData(GetAccountNotificationsRequest(), value: [ announcement1 ])
        pullToRefresh()
        AccountNotifications.toggleButton(id: announcement1.id.value).waitToExist()
    }

    func testDismiss() {
        mockBaseRequests()
        mockData(GetAccountNotificationsRequest(), value: [announcement1, announcement2])
        mockData(DeleteAccountNotificationRequest(id: "1"), value: APINoContent())

        logIn()

        AccountNotifications.toggleButton(id: announcement1.id.value).tap()
        AccountNotifications.dismissButton(id: announcement1.id.value).tap().waitToVanish()
        XCTAssert(AccountNotifications.toggleButton(id: announcement2.id.value).isVisible)
    }
}
