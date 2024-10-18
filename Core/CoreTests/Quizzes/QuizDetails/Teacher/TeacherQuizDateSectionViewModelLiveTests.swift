//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class QuizDateSectionViewModelTests: CoreTestCase {
    func testProperties() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)

        let apiQuiz = APIQuiz.make(due_at: dueAt, lock_at: lockAt, unlock_at: unlockAt)
        let quiz = Quiz.make(from: apiQuiz)
        let testee = TeacherQuizDateSectionViewModelLive(quiz: quiz)

        XCTAssertFalse(testee.isButton)
        XCTAssertEqual(testee.hasMultipleDueDates, false)
        XCTAssertEqual(testee.dueAt, dueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertEqual(testee.forText, "-")
    }

    func testAllDatesOnly() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let title = "Test"
        let dates = [APIAssignmentDate.make(base: false, title: title, due_at: dueAt, unlock_at: unlockAt, lock_at: lockAt)]
        let apiQuiz = APIQuiz.make(all_dates: dates)
        let quiz = Quiz.make(from: apiQuiz)
        let testee = TeacherQuizDateSectionViewModelLive(quiz: quiz)

        XCTAssertEqual(testee.dueAt, dueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertNotNil(testee.forText, title)
    }

    func testAllDatesandDueDate() {
        let dueAt = Date()
        let lockAt = Date(timeIntervalSinceNow: 100)
        let unlockAt = Date(timeIntervalSinceNow: -100)
        let title = "Test"
        let dates = [APIAssignmentDate.make(base: false, title: title, due_at: dueAt, unlock_at: unlockAt, lock_at: lockAt)]
        let quizDueAt = Date(timeIntervalSinceNow: 200)
        let quizLockAt = Date(timeIntervalSinceNow: 300)
        let quizUnlockAt = Date(timeIntervalSinceNow: 400)
        let apiQuiz = APIQuiz.make(all_dates: dates, due_at: quizDueAt, lock_at: quizLockAt, unlock_at: quizUnlockAt)
        let quiz = Quiz.make(from: apiQuiz)
        let testee = TeacherQuizDateSectionViewModelLive(quiz: quiz)

        XCTAssertEqual(testee.dueAt, quizDueAt)
        XCTAssertEqual(testee.lockAt, lockAt)
        XCTAssertEqual(testee.unlockAt, unlockAt)
        XCTAssertNotNil(testee.forText, title)
    }

    func testBaseTitle() {
        let dates = [APIAssignmentDate.make(base: true)]
        let apiQuiz = APIQuiz.make(all_dates: dates)
        let quiz = Quiz.make(from: apiQuiz)
        let testee = TeacherQuizDateSectionViewModelLive(quiz: quiz)

        XCTAssertNotNil(testee.forText, "Everyone")
    }

    func testRoute() {
        let quiz = Quiz.make()
        let testee = TeacherQuizDateSectionViewModelLive(quiz: quiz)

        testee.buttonTapped(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(router.calls.isEmpty)
    }
}
