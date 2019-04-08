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

class SyllabusAssignmentListPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: SyllabusAssignmentListPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = SyllabusAssignmentListPresenter(env: env, view: self, courseID: "1")
    }

    func testLoadAssignments() {
        //  given
        let expected = Assignment.make()

        //  when
        presenter.viewIsReady()

        //  then
        XCTAssert(presenter.assignments.first! === expected)
    }

    func testUseCaseFetchesData() {
        //  given
        Assignment.make()

        //   when
        presenter.viewIsReady()

        //  then
        XCTAssertEqual(presenter.assignments.first?.name, "Assignment One")
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
        XCTAssertNoThrow(presenter.select(a, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(a.htmlURL))
    }

    func testFormattedDateNoDueDate() {
        Assignment.make()
        let str = presenter.formattedDueDate(for: IndexPath(row: 0, section: 0))
        XCTAssertEqual(str, "No Due Date")
    }

    func testFormattedDate() {
        Assignment.make(["dueAt": Date(fromISOString: "2018-05-15T20:00:00Z")])
        let str = presenter.formattedDueDate(for: IndexPath(row: 0, section: 0))
        XCTAssertEqual(str, "May 15, 2018 at 2:00 PM")
    }

    func testIconForDiscussion() {
        Assignment.make(["id": "1", "discussionTopic": DiscussionTopic.make(["assignmentID": "1"])])
        let icon = presenter.icon(for: IndexPath(row: 0, section: 0))
        let expected = UIImage.icon(.discussion, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForAssignment() {
        Assignment.make(["id": "1"])
        let icon = presenter.icon(for: IndexPath(row: 0, section: 0))
        let expected = UIImage.icon(.assignment, .line)
        XCTAssertEqual(icon, expected)
    }

    func testIconForQuiz() {
        Assignment.make(["id": "1", "quizID": "1"])
        let icon = presenter.icon(for: IndexPath(row: 0, section: 0))
        let expected = UIImage.icon(.quiz, .line)
        XCTAssertEqual(icon, expected)
    }
}

extension SyllabusAssignmentListPresenterTests: SyllabusAssignmentListViewProtocol {
    func update() {
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
