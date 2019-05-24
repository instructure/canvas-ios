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

class AssignmentDatesTests: XCTestCase {

    var df = ISO8601DateFormatter()
    var a: Assignment!
    override func setUp() {
        df = ISO8601DateFormatter()
        a = Assignment.make(from: .make(unlock_at: nil, lock_at: nil))

        let now    = df.date(from: "2018-10-01T06:00:00Z")!
        Clock.mockNow(now)
    }

    func testAssignmentOpenForSubmissionsWithLockDate() {
        //  given
        a.lockAt = df.date(from: "2018-10-01T06:00:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)

        a.lockAt = df.date(from: "2018-10-01T05:59:59Z")

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithUnlockDate() {
        //  given
        a.unlockAt = df.date(from: "2018-10-01T06:00:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)

        a.unlockAt = df.date(from: "2018-10-01T06:00:01Z")

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithAvailabilityDates() {
        //  given
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        var result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)

        Clock.mockNow(df.date(from: "2018-10-01T06:02:00Z")!)

        //  when
        result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithGoodAvailabilityDatesLockedForUser() {
        //  given
        a.lockedForUser = true
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        let result = a.isOpenForSubmissions()

        //  then
        XCTAssertFalse(result)
    }

    func testAssignmentOpenForSubmissionsWithGoodAvailabilityDatesNotLockedForUser() {
        //  given
        a.lockedForUser = false
        a.unlockAt = df.date(from: "2018-10-01T05:00:00Z")
        a.lockAt   = df.date(from: "2018-10-01T06:01:00Z")

        //  when
        let result = a.isOpenForSubmissions()

        //  then
        XCTAssertTrue(result)
    }
}
