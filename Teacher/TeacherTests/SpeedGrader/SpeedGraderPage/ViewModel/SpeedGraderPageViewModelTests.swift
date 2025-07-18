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

class SpeedGraderPageViewModelTests: TeacherTestCase {

    private static let testData = (
        submissionId: "some submissionId",
        placeholder: ""
    )
    private lazy var testData = Self.testData

    private var testee: SpeedGraderPageViewModel!

    private var assignment: Assignment!
    private var submission: Submission!

    private var gradeStatusInteractorMock: GradeStatusInteractorMock!
    private var submissionWordCountInteractor: SubmissionWordCountInteractorMock!
    private var customGradebookColumnsInteractor: CustomGradebookColumnsInteractorMock!

    override func setUp() {
        super.setUp()

        assignment = Assignment(context: databaseClient)

        submission = Submission(context: databaseClient)
        submission.id = testData.submissionId

        gradeStatusInteractorMock = .init()
        submissionWordCountInteractor = .init()
        customGradebookColumnsInteractor = .init()
    }

    override func tearDown() {
        assignment = nil
        submission = nil
        gradeStatusInteractorMock = nil
        submissionWordCountInteractor = nil
        customGradebookColumnsInteractor = nil
        testee = nil
        super.tearDown()
    }

    func test_initialValues() {
        let testee = makeViewModel()

        XCTAssertEqual(testee.selectedAttempt, submission)
        XCTAssertEqual(testee.studentAnnotationViewModel.submissionId, submission.id)
        XCTAssertEqual(testee.isDetailsTabEmpty, true)
    }

    // MARK: - contextColor

    func test_contextColor() {
        let publisher = PassthroughSubject<Color, Never>()

        let testee = makeViewModel(contextColor: publisher.eraseToAnyPublisher())
        XCTAssertEqual(testee.contextColor.hexString, Brand.shared.primary.hexString)

        publisher.send(.green)
        XCTAssertEqual(testee.contextColor.hexString, Color.green.hexString)
    }

    // MARK: - isDetailsTabEmpty

    func test_isDetailsTabEmpty() {
        let studentNotesEntries = PassthroughSubject<[StudentNotesEntry], Error>()
        let wordCount = PassthroughSubject<Int?, Error>()
        customGradebookColumnsInteractor.getStudentNotesEntriesOutput = studentNotesEntries.eraseToAnyPublisher()
        submissionWordCountInteractor.getWordCountOutput = wordCount.eraseToAnyPublisher()

        testee = makeViewModel()
        XCTAssertEqual(testee.isDetailsTabEmpty, true)

        // add student notes
        studentNotesEntries.send([.make()])
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == false }

        // clear student notes
        studentNotesEntries.send([])
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == true }

        // add word count
        wordCount.send(42)
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == false }

        // clear word count
        wordCount.send(nil)
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == true }

        // add everything
        studentNotesEntries.send([.make()])
        wordCount.send(42)
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == false }

        // clear everything
        studentNotesEntries.send([])
        wordCount.send(nil)
        waitUntil(shouldFail: true) { testee.isDetailsTabEmpty == true }
    }

    // MARK: - didSelectAttempt

    func test_didSelectAttempt_shouldSignalSubViewModels() {
        testee = makeViewModel()

        testee.didSelectAttempt(attemptNumber: 42)

        XCTAssertEqual(submissionWordCountInteractor.getWordCountInput?.attempt, 42)
        XCTAssertEqual(gradeStatusInteractorMock.observeGradeStatusChangesInput?.attempt, 42)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        contextColor: AnyPublisher<Color, Never> = Publishers.typedEmpty()
    ) -> SpeedGraderPageViewModel {
        .init(
            assignment: assignment,
            latestSubmission: submission,
            contextColor: contextColor,
            studentAnnotationViewModel: .init(submission: submission),
            gradeViewModel: .init(
                assignment: assignment,
                submission: submission,
                gradeInteractor: GradeInteractorMock()
            ),
            gradeStatusViewModel: .init(
                userId: submission.userID,
                submissionId: submission.id,
                attempt: submission.attempt,
                interactor: gradeStatusInteractorMock,
                scheduler: .immediate
            ),
            commentListViewModel: .init(
                assignment: assignment,
                latestSubmission: submission,
                latestAttemptNumber: submission.attempt,
                currentUserId: "",
                contextColor: contextColor,
                interactor: SubmissionCommentsInteractorMock(),
                env: environment
            ),
            rubricsViewModel: .init(
                assignment: assignment,
                submission: submission,
                interactor: RubricGradingInteractorMock()
            ),
            submissionWordCountViewModel: .init(
                userId: submission.userID,
                attempt: submission.attempt,
                interactor: submissionWordCountInteractor,
                scheduler: .immediate
            ),
            studentNotesViewModel: .init(
                userId: submission.userID,
                interactor: customGradebookColumnsInteractor,
                scheduler: .immediate
            )
        )
    }
}
