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
@testable import Parent
import XCTest
@testable import Core

class RoutesTests: XCTestCase {
    var experimentalFeaturesEnabled: Bool!
    var currentStudentID: String?

    override func setUp() {
        super.setUp()
        experimentalFeaturesEnabled = ExperimentalFeature.allEnabled
        self.currentStudentID = Parent.currentStudentID
        Parent.currentStudentID = "1"
    }

    override func tearDown() {
        ExperimentalFeature.allEnabled = experimentalFeaturesEnabled
        Parent.currentStudentID = self.currentStudentID
        super.tearDown()
    }

    func testCourseGrades() {
        ExperimentalFeature.allEnabled = false
        XCTAssert(router.match(.parse("/courses/1/grades")) is CalendarEventWeekPageViewController)
    }

    func testCourseGradesParent3() {
        ExperimentalFeature.allEnabled = true
        XCTAssert(router.match(.parse("/courses/1/grades")) is GradesViewController)
    }
}
