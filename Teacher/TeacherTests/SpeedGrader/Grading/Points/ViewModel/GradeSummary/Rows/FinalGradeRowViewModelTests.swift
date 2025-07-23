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
            currentGradeText: "A",
            suffixType: .none
        )

        XCTAssertEqual(viewModel.currentGradeText, "A")
        XCTAssertEqual(viewModel.suffixText, "")
    }

    func test_init_withMaxGradeWithUnitSuffixType() {
        let viewModel = FinalGradeRowViewModel(
            currentGradeText: "85",
            suffixType: .maxGradeWithUnit("100 pts")
        )

        XCTAssertEqual(viewModel.currentGradeText, "85")
        XCTAssertEqual(viewModel.suffixText, "   / 100 pts")
    }

    func test_init_withPercentageSuffixType() {
        let viewModel = FinalGradeRowViewModel(
            currentGradeText: "92",
            suffixType: .percentage
        )

        XCTAssertEqual(viewModel.currentGradeText, "92")
        XCTAssertEqual(viewModel.suffixText, "   %")
    }

    func test_init_withNilCurrentGradeText() {
        let viewModel = FinalGradeRowViewModel(
            currentGradeText: nil,
            suffixType: .none
        )

        XCTAssertEqual(viewModel.currentGradeText, GradeFormatter.BlankPlaceholder.oneDash.stringValue)
        XCTAssertEqual(viewModel.suffixText, "")
    }
}
