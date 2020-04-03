//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Student
import Core
import TestsFoundation

class QuizListPresenterTests: StudentTestCase {

    var resultingError: NSError?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: QuizListPresenter!

    var updateExpectation: XCTestExpectation!
    var onUpdateNavBar: ((String?, UIColor?) -> Void)?

    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    override func setUp() {
        super.setUp()
        updateExpectation = XCTestExpectation(description: "presenter updated")
        presenter = QuizListPresenter(env: env, view: self, courseID: "1")
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.course.useCase.courseID, presenter.courseID)
        XCTAssertEqual(presenter.quizzes.useCase.courseID, presenter.courseID)
    }

    func testLoadColors() {
        let c = Course.make()
        ContextColor.make(canvasContextID: c.canvasContextID)

        presenter.colors.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadCourse() {
        let c = Course.make()
        ContextColor.make(canvasContextID: c.canvasContextID)

        presenter.course.eventHandler()
        XCTAssertEqual(resultingSubtitle, c.name)
    }

    func testLoadQuizzes() {
        Quiz.make()

        presenter.quizzes.eventHandler()
        wait(for: [updateExpectation], timeout: 0.1)
    }

    func testQuizListItemModelGradeViewableStubs() {
        let quiz = Quiz.make()
        XCTAssertEqual(quiz.gradingType, .points)
        XCTAssertEqual(quiz.viewableGrade, nil)
        XCTAssertEqual(quiz.viewableScore, nil)
    }

    func testQuizzes() {
        Quiz.make(from: .make(id: "a", quiz_type: .assignment))
        Quiz.make(from: .make(id: "g", quiz_type: .graded_survey))
        Quiz.make(from: .make(id: "p", quiz_type: .practice_quiz))
        Quiz.make(from: .make(id: "s", quiz_type: .survey))

        presenter.quizzes.eventHandler()

        XCTAssertEqual(presenter.quiz(IndexPath(row: 0, section: 0))?.quizType, QuizType.assignment)
        XCTAssertEqual(presenter.quiz(IndexPath(row: 0, section: 1))?.quizType, QuizType.practice_quiz)
        XCTAssertEqual(presenter.quiz(IndexPath(row: 0, section: 2))?.quizType, QuizType.graded_survey)
        XCTAssertEqual(presenter.quiz(IndexPath(row: 0, section: 3))?.quizType, QuizType.survey)
    }

    func testSectionOrder() {
        XCTAssertEqual(presenter.sectionOrder(QuizType.assignment.rawValue), 0)
        XCTAssertEqual(presenter.sectionOrder(QuizType.practice_quiz.rawValue), 1)
        XCTAssertEqual(presenter.sectionOrder(QuizType.graded_survey.rawValue), 2)
        XCTAssertEqual(presenter.sectionOrder(QuizType.survey.rawValue), 3)
        XCTAssertEqual(presenter.sectionOrder("something_else"), 4)
    }

    func testSection() {
        Quiz.make(from: .make(quiz_type: .survey))
        presenter.quizzes.eventHandler()

        XCTAssertEqual(presenter.section(0)?.name, "survey")
    }

    func testSectionTitle() {
        Quiz.make(from: .make(id: "a", quiz_type: .assignment))
        Quiz.make(from: .make(id: "g", quiz_type: .graded_survey))
        Quiz.make(from: .make(id: "p", quiz_type: .practice_quiz))
        Quiz.make(from: .make(id: "s", quiz_type: .survey))

        presenter.quizzes.eventHandler()

        XCTAssertEqual(presenter.sectionTitle(0), "Assignments")
        XCTAssertEqual(presenter.sectionTitle(1), "Practice Quizzes")
        XCTAssertEqual(presenter.sectionTitle(2), "Graded Surveys")
        XCTAssertEqual(presenter.sectionTitle(3), "Surveys")
        XCTAssertNil(presenter.sectionTitle(4))
    }

    func testSelect() {
        let quiz = Quiz.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(quiz, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(quiz.htmlURL!))
        XCTAssertEqual(router?.calls.last?.2, .detail)
    }
}

extension QuizListPresenterTests: QuizListViewProtocol {
    func update(isLoading: Bool) {
        updateExpectation.fulfill()
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        onUpdateNavBar?(subtitle, color)
    }
}
