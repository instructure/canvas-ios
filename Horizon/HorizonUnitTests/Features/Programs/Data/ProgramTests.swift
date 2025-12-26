//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
@testable import Horizon

final class ProgramTests: XCTestCase {
    func testAccessibilityHeader() {
        let program = Program(
            id: "1",
            name: "Test Program",
            variant: "linear",
            description: nil,
            date: nil,
            courseCompletionCount: nil,
            courses: []
        )
        let expected = "Program name is Test Program. "
        XCTAssertEqual(program.accessibilityHeader, expected)
    }

    func testAccessibilityDescription_notStarted() {
        let programCourse = ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: true,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0,
            moduleItemsestimatedTime: []
        )
        let program = Program(
            id: "1",
            name: "Test Program",
            variant: "NON_LINEAR",
            description: nil,
            date: nil,
            courseCompletionCount: 1,
            courses: [programCourse]
        )
        XCTAssertEqual(
            program.accessibilityDescription,
            "The program hasn’t started yet. Complete 1 of 1 courses. Non Linear and Required Program."
        )
    }

    func testAccessibilityDescription_inProgress_linear() {
        let programCourse = ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: true,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0.5,
            moduleItemsestimatedTime: ["PT4M", "PT32M", "PT10M"]
        )
        let program = Program(
            id: "1",
            name: "Test Program",
            variant: "LINEAR",
            description: "A test description",
            date: "Jan 1 - Dec 31",
            courseCompletionCount: 1,
            courses: [programCourse]
        )
        let expectedProgress = "Progress: 50 percent complete. "
        let expectedDescription = "Description A test description. "
        let expectedDate = "Date Jan 1 - Dec 31. "
        let expectedTypeAndStatus = "Linear and Required Program."
        let estimatedTime = "Estimated time 46 mins. "
        let expected = expectedProgress + expectedDescription + expectedDate + estimatedTime + expectedTypeAndStatus
        XCTAssertEqual(program.accessibilityDescription, expected)
    }

    func testAccessibilityDescription_optional() {
        let programCourse = ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: false,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0.0,
            moduleItemsestimatedTime: []
        )
        let program = Program(
            id: "1",
            name: "Test Program",
            variant: "non_linear",
            description: nil,
            date: nil,
            courseCompletionCount: nil,
            courses: [programCourse]
        )
        XCTAssertEqual(program.accessibilityDescription, "Non Linear and Optional Program.")
    }

    func testAccessibilityLabelText_linearRequired() {
        let programCourse = ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: true,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0.0,
            moduleItemsestimatedTime: [],
            index: 1
        )
        let status = ProgramCardStatus.notEnrolled
        let isLinear = true
        let expected = String(format: "%@ Course %@. ", programCourse.index.ordinalString, programCourse.name)
        + String(format: "Status %@. ", status.name)
        + "Required course"
        XCTAssertEqual(programCourse.accessibilityLabelText(status: status, isLinear: isLinear), expected)
    }

    func testAccessibilityLabelText_nonLinearOptional_inProgress() {
        let programCourse = ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: false,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0.75,
            moduleItemsestimatedTime: ["PT3H"]
        )
        let status = ProgramCardStatus.inProgress
        let isLinear = false
        let expectedCourseName = String(format: "Course name is %@. ", programCourse.name)
        let expectedStatus = String(format: "Status %@. ", status.name)
        let expectedProgress = String(format: "Progress: %d percent complete. ", 75)
        let expectedEstimatedTime = String(format: "Estimated time %@. ", programCourse.estimatedTime ?? "")
        let expectedOptional = "Optional course"
        let expected = expectedCourseName + expectedStatus + expectedProgress + expectedEstimatedTime + expectedOptional
        XCTAssertEqual(programCourse.accessibilityLabelText(status: status, isLinear: isLinear), expected)
    }

    func testAccessibilityHint_notEnrolled() {
        let testee = createProgramCourse()
        let result = testee.accessibilityHintString(status: .notEnrolled)
        XCTAssertEqual(
            result,
            "",
            "Expected correct hint for notEnrolled"
        )
    }

    func testAccessibilityHint_locked() {
        let testee = createProgramCourse()
        let result = testee.accessibilityHintString(status: .locked)
        XCTAssertEqual(
            result,
            "This course is dimmed",
            "Expected correct hint for locked"
        )
    }

    func testAccessibilityHint_default() {
        let testee = createProgramCourse()
        let result = testee.accessibilityHintString(status: .completed)
        XCTAssertEqual(
            result,
            "Double tap to open course",
            "Expected correct hint for default"
        )
    }

    private func createProgramCourse() -> ProgramCourse {
        ProgramCourse(
            id: "course1",
            name: "Course 1",
            isSelfEnrolled: false,
            isRequired: false,
            status: "ENROLLED",
            progressID: "progress1",
            completionPercent: 0.75,
            moduleItemsestimatedTime: ["PT3H"]
        )
    }
}
