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

import Foundation
import XCTest
@testable import Core
@testable import Teacher
import TestsFoundation

class SubmissionWordCountViewModelTests: TeacherTestCase {

    private static let testData = (
        userId: "some userId",
        placeholder: ""
    )
    private lazy var testData = Self.testData

    private var interactor: SubmissionWordCountInteractorMock!

    override func setUp() {
        super.setUp()

        interactor = .init()
    }

    override func tearDown() {
        interactor = nil
        super.tearDown()
    }

    func test_init_shouldCallInteractorWithUserIdAndAttempt() {
        _ = makeViewModel(attempt: 42)

        XCTAssertEqual(interactor.getWordCountCallsCount, 1)
        XCTAssertEqual(interactor.getWordCountInput?.userId, testData.userId)
        XCTAssertEqual(interactor.getWordCountInput?.attempt, 42)
    }

    func test_didChangeAttempt_shouldCallInteractorWithUserIdAndAttempt() {
        let testee = makeViewModel(attempt: 7)

        testee.didChangeAttempt.send(42)

        XCTAssertEqual(interactor.getWordCountCallsCount, 2)
        XCTAssertEqual(interactor.getWordCountInput?.userId, testData.userId)
        XCTAssertEqual(interactor.getWordCountInput?.attempt, 42)
    }

    func test_wordCount() {
        let testee = makeViewModel()
        XCTAssertEqual(testee.wordCount, "")
        XCTAssertEqual(testee.hasContent, false)

        interactor.getWordCountOutputValue = 7
        testee.didChangeAttempt.send(0)
        XCTAssertEqual(testee.wordCount, "7")
        XCTAssertEqual(testee.hasContent, true)

        interactor.getWordCountOutputValue = 0
        testee.didChangeAttempt.send(0)
        XCTAssertEqual(testee.wordCount, "0")
        XCTAssertEqual(testee.hasContent, true)

        interactor.getWordCountOutputValue = nil
        testee.didChangeAttempt.send(0)
        XCTAssertEqual(testee.wordCount, "")
        XCTAssertEqual(testee.hasContent, false)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        userId: String = testData.userId,
        attempt: Int = 0
    ) -> SubmissionWordCountViewModel {
        .init(
            userId: userId,
            attempt: attempt,
            interactor: interactor,
            scheduler: .immediate
        )
    }
}
