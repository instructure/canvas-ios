//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Horizon
@testable import Core
import XCTest

final class CollectionItemFilterTypeTests: HorizonTestCase {

    func testRawValues() {
        XCTAssertEqual(CollectionItemFilterType.all.rawValue, "all")
        XCTAssertEqual(CollectionItemFilterType.assignment.rawValue, "ASSIGNMENT")
        XCTAssertEqual(CollectionItemFilterType.course.rawValue, "COURSE")
        XCTAssertEqual(CollectionItemFilterType.externalLink.rawValue, "EXTERNAL_URL")
        XCTAssertEqual(CollectionItemFilterType.externalTool.rawValue, "EXTERNAL_TOOL")
        XCTAssertEqual(CollectionItemFilterType.file.rawValue, "FILE")
        XCTAssertEqual(CollectionItemFilterType.page.rawValue, "PAGE")
        XCTAssertEqual(CollectionItemFilterType.assessment.rawValue, "QUIZ")
    }

    func testNames() {
        XCTAssertEqual(CollectionItemFilterType.all.name, "All")
        XCTAssertEqual(CollectionItemFilterType.assignment.name, "Assignments")
        XCTAssertEqual(CollectionItemFilterType.course.name, "Courses")
        XCTAssertEqual(CollectionItemFilterType.externalLink.name, "External Links")
        XCTAssertEqual(CollectionItemFilterType.externalTool.name, "External Tools")
        XCTAssertEqual(CollectionItemFilterType.file.name, "Files")
        XCTAssertEqual(CollectionItemFilterType.page.name, "Pages")
        XCTAssertEqual(CollectionItemFilterType.assessment.name, "Assessments")
    }

    func testAllCases() {
        let allCases = CollectionItemFilterType.allCases

        XCTAssertEqual(allCases.count, 8)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.assignment))
        XCTAssertTrue(allCases.contains(.course))
        XCTAssertTrue(allCases.contains(.externalLink))
        XCTAssertTrue(allCases.contains(.externalTool))
        XCTAssertTrue(allCases.contains(.file))
        XCTAssertTrue(allCases.contains(.page))
        XCTAssertTrue(allCases.contains(.assessment))
    }
}
