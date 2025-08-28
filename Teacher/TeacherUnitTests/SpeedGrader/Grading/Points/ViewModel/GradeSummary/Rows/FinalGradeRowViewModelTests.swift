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
@testable import Core
import TestsFoundation
@testable import Teacher

class FinalGradeRowViewModelTests: TeacherTestCase {

    func test_init_withNoneSuffixType() {
        let viewModel = FinalGradeRowViewModel(
            gradeText: "A",
            a11yGradeText: "a11y",
            suffixType: .none,
            isGradedButNotPosted: false
        )

        XCTAssertEqual(viewModel.gradeText, "A")
        XCTAssertEqual(viewModel.a11yGradeText, "a11y")
        XCTAssertEqual(viewModel.suffixText, "")
    }

    func test_init_withMaxGradeWithUnitSuffixType() {
        let viewModel = FinalGradeRowViewModel(
            gradeText: "85",
            a11yGradeText: "a11y",
            suffixType: .maxGradeWithUnit("100 pts", ""),
            isGradedButNotPosted: false
        )

        XCTAssertEqual(viewModel.gradeText, "85")
        XCTAssertEqual(viewModel.a11yGradeText, "a11y")
        XCTAssertEqual(viewModel.suffixText, "   / 100 pts")
    }

    func test_init_withPercentageSuffixType() {
        let viewModel = FinalGradeRowViewModel(
            gradeText: "92",
            a11yGradeText: "a11y",
            suffixType: .percentage,
            isGradedButNotPosted: false
        )

        XCTAssertEqual(viewModel.gradeText, "92")
        XCTAssertEqual(viewModel.a11yGradeText, "a11y")
        XCTAssertEqual(viewModel.suffixText, "   %")
    }

    func test_init_withNilGradeText() {
        let viewModel = FinalGradeRowViewModel(
            gradeText: nil,
            a11yGradeText: nil,
            suffixType: .none,
            isGradedButNotPosted: false
        )

        XCTAssertEqual(viewModel.gradeText, GradeFormatter.BlankPlaceholder.oneDash.stringValue)
        XCTAssertEqual(viewModel.a11yGradeText, "None")
        XCTAssertEqual(viewModel.suffixText, "")
    }

    func test_init_whenIsGradedButNotPostedIsTrue() {
        let viewModel = FinalGradeRowViewModel(
            gradeText: "85",
            a11yGradeText: "a11y",
            suffixType: .maxGradeWithUnit("100 pts", ""),
            isGradedButNotPosted: true
        )

        XCTAssertEqual(viewModel.gradeText, "85")
        XCTAssertEqual(viewModel.a11yGradeText, "a11y")
        XCTAssertEqual(viewModel.suffixText, "   / 100 pts")
        XCTAssertEqual(viewModel.shouldShowNotPostedIcon, true)
    }
}
