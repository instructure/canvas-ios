//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ScheduleSubjectViewModelTests: CoreTestCase {

    func testInvokesTapAction() {
        router.routeExpectation = expectation(description: "Route happened")
        let testee = K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "", color: .red, image: nil, route: URL(string: "/a")!, shouldHideQuantitativeData: false), entries: [])

        testee.viewTapped(router: router, viewController: WeakViewController(UIViewController()))

        wait(for: [router.routeExpectation], timeout: 0.1)
    }

    func testHasTapActionProperty() {
        XCTAssertTrue(K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "", color: .red, image: nil, route: URL(string: "/a")!, shouldHideQuantitativeData: false), entries: []).isTappable)
        XCTAssertFalse(K5ScheduleSubjectViewModel(subject: K5ScheduleSubject(name: "", color: .red, image: nil, route: nil, shouldHideQuantitativeData: false), entries: []).isTappable)
    }
}
