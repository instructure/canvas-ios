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

class SyllabusActionableItemsPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: SyllabusActionableItemsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")
    var models: [SyllabusActionableItemsViewController.ViewModel] = []

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = SyllabusActionableItemsPresenter(env: env, view: self, courseID: "1")
    }

    func testUseCaseFetchesData() {
        //  given
        Assignment.make()

        //   when
        presenter.viewIsReady()

        //  then
        XCTAssertEqual(models.first?.title, "Assignment One")
    }

    func testLoadCourseColorsAndTitle() {
        //  given
        let expected = Course.make()
        let expectedColor = Color.make()

        //  when
        presenter.viewIsReady()
        XCTAssertEqual(presenter.course.count, 1)
        wait(for: [expectation], timeout: 0.4)
        presenter.loadColor()

        //  then
        XCTAssertEqual(resultingBackgroundColor, expectedColor.color)
        XCTAssertEqual(resultingSubtitle, expected.name)
    }

    func testSelect() {
        let a = Assignment.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(a.htmlURL, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(a.htmlURL))
    }

    func testFormattedDateNoDueDate() {
        let a = Assignment.make()
        let str = presenter.formattedDueDate(a.dueAt)
        XCTAssertEqual(str, "No Due Date")
    }

    func testFormattedDate() {
        let a = Assignment.make(["dueAt": Date(fromISOString: "2018-05-15T20:00:00Z")])
        let str = presenter.formattedDueDate(a.dueAt)
        XCTAssertEqual(str, "May 15, 2018 at 2:00 PM")
    }

    func testIconForDiscussion() {
        let a = Assignment.make(["id": "1", "submissionTypesRaw": ["discussion_topic"]])
        let icon = presenter.icon(for: a)
        let expected = UIImage.icon(.discussion, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForAssignment() {
        let a = Assignment.make(["id": "1"])
        let icon = presenter.icon(for: a)
        let expected = UIImage.icon(.assignment, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForQuiz() {
        let a = Assignment.make(["id": "1", "quizID": "1"])
        let icon = presenter.icon(for: a)
        let expected = UIImage.icon(.quiz, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForExternalTool() {
        let a = Assignment.make(["id": "1", "submissionTypesRaw": ["external_tool"]])
        let icon = presenter.icon(for: a)
        let expected = UIImage.icon(.lti, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForLocked() {
        let a = Assignment.make(["id": "1", "submissionTypesRaw": ["external_tool"], "lockedForUser": true])
        let icon = presenter.icon(for: a)
        let expected = UIImage.icon(.lock, .line)
        XCTAssertEqual(icon, expected)
    }

    func testSortOrder() {
        Assignment.make(["name": "a", "dueAt": Date(fromISOString: "2017-05-15T20:00:00Z")])
        Assignment.make(["name": "b", "dueAt": Date(fromISOString: "2018-05-15T20:00:00Z")])
        Assignment.make(["name": "c", "dueAt": nil])

        CalendarEvent.make(["title": "cA", "endAt": Date(fromISOString: "2016-05-15T20:00:00Z")])
        CalendarEvent.make(["title": "cB", "endAt": Date(fromISOString: "2017-06-15T20:00:00Z")])
        CalendarEvent.make(["title": "cC", "endAt": nil])

        presenter.viewIsReady()

        let order = models.map { $0.title }
        XCTAssertEqual(order, ["cA", "a", "cB", "b", "c", "cC"])
    }
}

extension SyllabusActionableItemsPresenterTests: SyllabusActionableItemsViewProtocol {
    func update(models: [SyllabusActionableItemsViewController.ViewModel]) {
        self.models = models
        expectation.fulfill()
    }

    var navigationController: UINavigationController? {
        return UINavigationController(nibName: nil, bundle: nil)
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        colorExpectation.fulfill()
    }
}
