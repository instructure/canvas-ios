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

import Combine
import SwiftUI
import TestsFoundation
import XCTest
@testable import Core
@testable import Teacher

class SubmissionGraderViewModelTests: TeacherTestCase {

    private enum TestConstants {
        static let submissionId = "some submissionId"
    }

    private var assignment: Assignment!
    private var submission: Submission!

    override func setUp() {
        super.setUp()

        assignment = Assignment(context: databaseClient)

        submission = Submission(context: databaseClient)
        submission.id = TestConstants.submissionId
    }

    override func tearDown() {
        assignment = nil
        submission = nil
        super.tearDown()
    }

    func test_initialValues() {
        let testee = makeViewModel()

        XCTAssertEqual(testee.selectedAttempt, submission)
        XCTAssertEqual(testee.studentAnnotationViewModel.submissionId, submission.id)
    }

    // MARK: - contextColor

    func test_contextColor() {
        let publisher = PassthroughSubject<Color, Never>()

        let testee = makeViewModel(contextColor: publisher.eraseToAnyPublisher())
        XCTAssertEqual(testee.contextColor.hexString, Brand.shared.primary.hexString)

        publisher.send(.green)
        XCTAssertEqual(testee.contextColor.hexString, Color.green.hexString)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        contextColor: AnyPublisher<Color, Never> = Publishers.typedEmpty()
    ) -> SubmissionGraderViewModel {
        SubmissionGraderViewModel(
            assignment: assignment,
            latestSubmission: submission,
            contextColor: contextColor,
            gradeStatusInteractor: GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId"),
            env: environment
        )
    }
}
