//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class AppStoreReviewTests: CoreTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: AppStoreReview.lastRequestDateKey)
        UserDefaults.standard.removeObject(forKey: AppStoreReview.viewAssignmentDateKey)
        UserDefaults.standard.removeObject(forKey: AppStoreReview.viewAssignmentCountKey)
        UserDefaults.standard.removeObject(forKey: AppStoreReview.launchCountKey)
        UserDefaults.standard.set(true, forKey: AppStoreReview.fakeRequestKey)
    }

    var viewAssignmentDate: Date? {
        UserDefaults.standard.value(forKey: AppStoreReview.viewAssignmentDateKey) as? Date
    }

    func testLaunch() {
        for _ in 0..<9 { AppStoreReview.handleLaunch() }
        XCTAssert(router.calls.isEmpty)
        AppStoreReview.handleLaunch()
        XCTAssert(router.presented is UIAlertController)
        router.calls = []
        AppStoreReview.handleLaunch()
        XCTAssert(router.calls.isEmpty)
    }

    func testSubmit() {
        AppStoreReview.handleSuccessfulSubmit()
        XCTAssert(router.presented is UIAlertController)

        UserDefaults.standard.removeObject(forKey: AppStoreReview.lastRequestDateKey)
        UserDefaults.standard.removeObject(forKey: AppStoreReview.fakeRequestKey)
        XCTAssertNoThrow(AppStoreReview.handleSuccessfulSubmit())
    }

    func testViewAssignment() {
        AppStoreReview.handleNavigateToAssignment()
        XCTAssert(Calendar.current.isDateInToday(viewAssignmentDate!))
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStoreReview.viewAssignmentCountKey), 1)

        AppStoreReview.handleNavigateFromAssignment()
        XCTAssert(router.calls.isEmpty)

        AppStoreReview.handleNavigateToAssignment()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStoreReview.viewAssignmentCountKey), 1)

        UserDefaults.standard.set(Date().addDays(-1), forKey: AppStoreReview.viewAssignmentDateKey)
        AppStoreReview.handleNavigateToAssignment()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStoreReview.viewAssignmentCountKey), 2)

        UserDefaults.standard.set(Date().addDays(-1), forKey: AppStoreReview.viewAssignmentDateKey)
        AppStoreReview.handleNavigateToAssignment()
        XCTAssertEqual(UserDefaults.standard.integer(forKey: AppStoreReview.viewAssignmentCountKey), 3)

        UserDefaults.standard.set(Date().addDays(-1), forKey: AppStoreReview.viewAssignmentDateKey)
        AppStoreReview.handleNavigateFromAssignment()
        XCTAssert(router.calls.isEmpty)

        UserDefaults.standard.set(Date(), forKey: AppStoreReview.viewAssignmentDateKey)
        AppStoreReview.handleNavigateFromAssignment()
        XCTAssert(router.presented is UIAlertController)
    }

    func testState() {
        XCTAssertEqual(AppStoreReview.getState(), [
            "lastRequestDate": 0,
            "viewAssignmentDate": 0,
            "viewAssignmentCount": 0,
            "launchCount": 0,
            "fakeRequest": 1
        ])
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        AppStoreReview.setState("lastRequestDate", withValue: now)
        AppStoreReview.setState("viewAssignmentDate", withValue: now)
        AppStoreReview.setState("viewAssignmentCount", withValue: 2)
        AppStoreReview.setState("launchCount", withValue: 9)
        AppStoreReview.setState("fakeRequest", withValue: 0)
        AppStoreReview.setState("bogus", withValue: 99)
        XCTAssertEqual(AppStoreReview.getState(), [
            "lastRequestDate": Int(now),
            "viewAssignmentDate": Int(now),
            "viewAssignmentCount": 2,
            "launchCount": 9,
            "fakeRequest": 0
        ])
    }
}
