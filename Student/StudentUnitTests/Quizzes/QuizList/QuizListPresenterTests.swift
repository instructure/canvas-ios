//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Student
import Core
import TestsFoundation

class QuizListPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingQuizzes: [QuizListItemModel]?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: QuizListPresenter!

    let update = XCTestExpectation(description: "presenter updated")

    var color: UIColor?
    var navigationController: UINavigationController?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    override func setUp() {
        super.setUp()
        presenter = QuizListPresenter(env: env, view: self, courseID: "1")
    }

    func testQuizListItemModelGradeViewableStubs() {
        let quiz = Quiz.make()
        XCTAssertEqual(quiz.gradingType, .points)
        XCTAssertEqual(quiz.viewableGrade, nil)
        XCTAssertEqual(quiz.viewableScore, nil)
    }

    func testLoadCourse() {
        XCTAssertNil(resultingSubtitle)
        XCTAssertNil(resultingBackgroundColor)

        let c = Course.make()
        Color.make(["canvasContextID": c.canvasContextID, "color": UIColor.red])

        presenter.viewIsReady()

        wait(for: [update], timeout: 0.1)
        XCTAssertEqual(resultingSubtitle, c.name)
        XCTAssertEqual(resultingBackgroundColor, c.color)
    }

    func testLoadQuizzes() {
        //  given
        let expected = Quiz.make()

        //  when
        presenter.viewIsReady()

        //  then
        let quiz = presenter?.quizzes[IndexPath(row: 0, section: 0)]
        XCTAssertEqual(quiz?.title, expected.title)
    }

    func testSelect() {
        let quiz = Quiz.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(quiz, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(quiz.htmlURL))
    }
}

extension QuizListPresenterTests: QuizListViewProtocol {
    func update(isLoading: Bool) {
        update.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
    }
}
