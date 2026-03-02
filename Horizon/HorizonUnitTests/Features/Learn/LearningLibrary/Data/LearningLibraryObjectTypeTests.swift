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
import XCTest

final class LearningLibraryObjectTypeTests: XCTestCase {

    func testAllCases() {
        let allCases = LearningLibraryObjectType.allCases
        XCTAssertEqual(allCases.count, 8)
        XCTAssertTrue(allCases.contains(.course))
        XCTAssertTrue(allCases.contains(.program))
        XCTAssertTrue(allCases.contains(.page))
        XCTAssertTrue(allCases.contains(.assignment))
        XCTAssertTrue(allCases.contains(.assessment))
        XCTAssertTrue(allCases.contains(.externalLink))
        XCTAssertTrue(allCases.contains(.externalTool))
        XCTAssertTrue(allCases.contains(.file))
    }

    func testRawValues() {
        XCTAssertEqual(LearningLibraryObjectType.course.rawValue, "COURSE")
        XCTAssertEqual(LearningLibraryObjectType.program.rawValue, "PROGRAM")
        XCTAssertEqual(LearningLibraryObjectType.page.rawValue, "PAGE")
        XCTAssertEqual(LearningLibraryObjectType.assignment.rawValue, "ASSIGNMENT")
        XCTAssertEqual(LearningLibraryObjectType.assessment.rawValue, "QUIZ")
        XCTAssertEqual(LearningLibraryObjectType.externalLink.rawValue, "EXTERNAL_URL")
        XCTAssertEqual(LearningLibraryObjectType.externalTool.rawValue, "EXTERNAL_TOOL")
        XCTAssertEqual(LearningLibraryObjectType.file.rawValue, "FILE")
    }

    func testNames() {
        XCTAssertEqual(LearningLibraryObjectType.course.name, "Course")
        XCTAssertEqual(LearningLibraryObjectType.program.name, "Program")
        XCTAssertEqual(LearningLibraryObjectType.page.name, "Page")
        XCTAssertEqual(LearningLibraryObjectType.assignment.name, "Assignment")
        XCTAssertEqual(LearningLibraryObjectType.assessment.name, "Assessment")
        XCTAssertEqual(LearningLibraryObjectType.externalLink.name, "External Link")
        XCTAssertEqual(LearningLibraryObjectType.externalTool.name, "External Tool")
        XCTAssertEqual(LearningLibraryObjectType.file.name, "File")
    }

    func testStylesAreNotNil() {
        XCTAssertNotNil(LearningLibraryObjectType.course.style)
        XCTAssertNotNil(LearningLibraryObjectType.program.style)
        XCTAssertNotNil(LearningLibraryObjectType.page.style)
        XCTAssertNotNil(LearningLibraryObjectType.assignment.style)
        XCTAssertNotNil(LearningLibraryObjectType.assessment.style)
        XCTAssertNotNil(LearningLibraryObjectType.externalLink.style)
        XCTAssertNotNil(LearningLibraryObjectType.externalTool.style)
        XCTAssertNotNil(LearningLibraryObjectType.file.style)
    }

    func testFirstOption() {
        let firstOption = LearningLibraryObjectType.firstOption
        XCTAssertEqual(firstOption.id, "-1")
        XCTAssertEqual(firstOption.name, "Any type")
    }

    func testOptionsIncludesAllTypesAndFirstOption() {
        let options = LearningLibraryObjectType.options

        XCTAssertEqual(options.count, 9)
        XCTAssertEqual(options.first?.id, "-1")
        XCTAssertEqual(options.first?.name, "Any type")

        let typeIds = options.dropFirst().map { $0.id }
        XCTAssertTrue(typeIds.contains("COURSE"))
        XCTAssertTrue(typeIds.contains("PROGRAM"))
        XCTAssertTrue(typeIds.contains("PAGE"))
        XCTAssertTrue(typeIds.contains("ASSIGNMENT"))
        XCTAssertTrue(typeIds.contains("QUIZ"))
        XCTAssertTrue(typeIds.contains("EXTERNAL_URL"))
        XCTAssertTrue(typeIds.contains("EXTERNAL_TOOL"))
        XCTAssertTrue(typeIds.contains("FILE"))
    }

    func testOptionsOrderStartsWithFirstOption() {
        let options = LearningLibraryObjectType.options
        XCTAssertEqual(options[0].id, "-1")
        XCTAssertEqual(options[0].name, "Any type")
    }

    func testInitFromRawValue() {
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "COURSE"), .course)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "PROGRAM"), .program)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "PAGE"), .page)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "ASSIGNMENT"), .assignment)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "QUIZ"), .assessment)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "EXTERNAL_URL"), .externalLink)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "EXTERNAL_TOOL"), .externalTool)
        XCTAssertEqual(LearningLibraryObjectType(rawValue: "FILE"), .file)
    }

    func testInitFromInvalidRawValue() {
        XCTAssertNil(LearningLibraryObjectType(rawValue: "INVALID"))
        XCTAssertNil(LearningLibraryObjectType(rawValue: ""))
    }
}
