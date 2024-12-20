//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import XCTest

class FileVisibilityTests: XCTestCase {

    func testAPIRawValues() {
        XCTAssertEqual(FileVisibility.inheritCourse.rawValue, "inherit")
        XCTAssertEqual(FileVisibility.courseMembers.rawValue, "context")
        XCTAssertEqual(FileVisibility.institutionMembers.rawValue, "institution")
        XCTAssertEqual(FileVisibility.publiclyAvailable.rawValue, "public")
    }

    func testLabels() {
        XCTAssertEqual(FileVisibility.inheritCourse.label, "Inherit From Course")
        XCTAssertEqual(FileVisibility.courseMembers.label, "Course Members")
        XCTAssertEqual(FileVisibility.institutionMembers.label, "Institution Members")
        XCTAssertEqual(FileVisibility.publiclyAvailable.label, "Public")
    }

    func testLastCase() {
        XCTAssertFalse(FileVisibility.inheritCourse.isLastCase)
        XCTAssertFalse(FileVisibility.courseMembers.isLastCase)
        XCTAssertFalse(FileVisibility.institutionMembers.isLastCase)
        XCTAssertTrue(FileVisibility.publiclyAvailable.isLastCase)
    }
}
