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

import Foundation
@testable import Core
import XCTest

class SessionDefaultsTests: XCTestCase {
    var defaults = SessionDefaults(sessionID: LoginSession.make().uniqueID)

    override func tearDown() {
        defaults.reset()
        super.tearDown()
    }

    func testSubmitAssignmentDefaults() {
        XCTAssertNil(defaults.submitAssignmentID)
        XCTAssertNil(defaults.submitAssignmentCourseID)
        defaults.submitAssignmentCourseID = "1"
        defaults.submitAssignmentID = "2"
        XCTAssertEqual(defaults.submitAssignmentCourseID, "1")
        XCTAssertEqual(defaults.submitAssignmentID, "2")
    }

    func testHasSetPSPDFKitLastUsedValues() {
        defaults.hasSetPSPDFKitLastUsedValues = true
        XCTAssertTrue(defaults.hasSetPSPDFKitLastUsedValues)
    }

    func testElementaryViewEnabledDefaultValue() {
        defaults.reset()
        XCTAssertTrue(defaults.isElementaryViewEnabled)
    }

    func testDashboardLayoutDefaultValue() {
        defaults.reset()
        XCTAssertFalse(defaults.isDashboardLayoutGrid)
    }

    func testCourseSyncItemPersistency() {
        let item1 = "courses/1/tabs/1"
        let item2 = "courses/2"
        let item3 = "courses/1/files/1"
        defaults.offlineSyncSelections = [item1, item2, item3]

        let testee = defaults.offlineSyncSelections

        XCTAssertEqual(testee, [item1, item2, item3])
    }
}
