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

class AssignmentListPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingAssignments: [Assignment]?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: AssignmentListPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentListPresenter(env: env, view: self, courseID: "1")
    }

    func testLoadAssignments() {
        //  given
        let expected = Assignment.make()

        //  when
        presenter.loadDataForView()

        //  then
        XCTAssert(resultingAssignments?.first! === expected)
    }

    func testUseCaseFetchesData() {
        //  given
        Assignment.make()

        //   when
        presenter.loadDataForView()

        //  then
        XCTAssertEqual(resultingAssignments?.first?.name, "Assignment One")
    }

    func testLoadCourseColorsAndTitle() {
        //  given
        let expected = Course.make()
        let expectedColor = Color.make()

        //  when
        presenter.loadDataForView()

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
}

extension AssignmentListPresenterTests: AssignmentListViewProtocol {
    func update(list: [Assignment]) {
        resultingAssignments = list
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
