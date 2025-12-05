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
@testable import Student
import TestsFoundation

final class StudentSubAssignmentsCardItemTests: StudentTestCase {

    private static let testData = (
        id: "some id",
        title: "some title",
        submissionStatusText: "some status",
        score: "42 / 100",
        scoreA11yLabel: "some a11y label"
    )
    private lazy var testData = Self.testData

    func test_init_shouldSetProperties() {
        let submissionStatus = SubmissionStatusLabel.Model(
            text: testData.submissionStatusText,
            icon: .completeLine,
            color: .textSuccess
        )

        let testee = StudentSubAssignmentsCardItem(
            id: testData.id,
            title: testData.title,
            submissionStatus: submissionStatus,
            score: testData.score,
            scoreA11yLabel: testData.scoreA11yLabel
        )

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.submissionStatus.text, testData.submissionStatusText)
        XCTAssertEqual(testee.submissionStatus.icon, .completeLine)
        XCTAssertEqual(testee.submissionStatus.color, .textSuccess)
        XCTAssertEqual(testee.score, testData.score)
        XCTAssertEqual(testee.scoreA11yLabel, testData.scoreA11yLabel)
    }
}
