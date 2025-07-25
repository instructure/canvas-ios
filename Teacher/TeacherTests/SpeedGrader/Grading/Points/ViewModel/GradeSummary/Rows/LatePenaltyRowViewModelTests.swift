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

<<<<<<<< HEAD:Core/CoreTests/Features/Courses/SmartSearch/Model/CourseSmartSearchViewAttributesTests.swift
@testable import Core
import XCTest

class CourseSmartSearchViewAttributesTests: CoreTestCase {

    func test_default_properties() {
        let testee = CourseSmartSearchViewAttributes.default

        XCTAssertEqual(testee.context, .currentUser)
        XCTAssertNil(testee.accentColor)
    }

    func test_custom_properties() {
        let testee = CourseSmartSearchViewAttributes(
            context: .course("1"),
            color: .red
        )

        XCTAssertEqual(testee.context, .course("1"))
        XCTAssertEqual(testee.accentColor, .red)
        XCTAssertEqual(testee.searchPrompt, String(localized: "Search in this course", bundle: .core))
========
import XCTest
@testable import Core
import TestsFoundation
@testable import Teacher

class LatePenaltyRowViewModelTests: TeacherTestCase {

    func test_init_withValidPenaltyText() {
        let viewModel = LatePenaltyRowViewModel(penaltyText: "-5 pts")

        XCTAssertEqual(viewModel.penaltyText, "-5 pts")
    }

    func test_init_withNilPenaltyText() {
        let viewModel = LatePenaltyRowViewModel(penaltyText: nil)

        XCTAssertEqual(viewModel.penaltyText, GradeFormatter.BlankPlaceholder.oneDash.stringValue)
    }

    func test_init_withEmptyPenaltyText() {
        let viewModel = LatePenaltyRowViewModel(penaltyText: "")

        XCTAssertEqual(viewModel.penaltyText, "")
>>>>>>>> origin/master:Teacher/TeacherTests/SpeedGrader/Grading/Points/ViewModel/GradeSummary/Rows/LatePenaltyRowViewModelTests.swift
    }
}
