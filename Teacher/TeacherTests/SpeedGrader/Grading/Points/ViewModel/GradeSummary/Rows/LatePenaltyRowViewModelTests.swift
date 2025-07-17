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
    }
}
