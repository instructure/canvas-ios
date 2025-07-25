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

class PointsRowViewModelTests: TeacherTestCase {

    func test_init_withValidPoints() {
        let viewModel = PointsRowViewModel(
            currentPoints: "85",
            maxPointsWithUnit: "100 pts"
        )

        XCTAssertEqual(viewModel.currentPoints, "85")
        XCTAssertEqual(viewModel.maxPointsWithUnit, "   / 100 pts")
    }

    func test_init_withNilCurrentPoints() {
        let viewModel = PointsRowViewModel(
            currentPoints: nil,
            maxPointsWithUnit: "100 pts"
        )

        XCTAssertEqual(viewModel.currentPoints, GradeFormatter.BlankPlaceholder.oneDash.stringValue)
        XCTAssertEqual(viewModel.maxPointsWithUnit, "   / 100 pts")
    }

    func test_init_withNilMaxPointsWithUnit() {
        let viewModel = PointsRowViewModel(
            currentPoints: "85",
            maxPointsWithUnit: nil
        )

        XCTAssertEqual(viewModel.currentPoints, "85")
        XCTAssertEqual(viewModel.maxPointsWithUnit, "")
    }

    func test_init_withBothNil() {
        let viewModel = PointsRowViewModel(
            currentPoints: nil,
            maxPointsWithUnit: nil
        )

        XCTAssertEqual(viewModel.currentPoints, GradeFormatter.BlankPlaceholder.oneDash.stringValue)
        XCTAssertEqual(viewModel.maxPointsWithUnit, "")
    }
}
