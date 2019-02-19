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
import Core
@testable import Student
import TestsFoundation

class CourseNavigationPresenterTests: PersistenceTestCase {

    var resultingTabs: [CourseNavigationViewModel]?
    var presenter: CourseNavigationPresenter!
    var resultingError: NSError?
    var navigationController: UINavigationController?

    var expectation = XCTestExpectation(description: "expectation")

    override func setUp() {
        super.setUp()
        resultingTabs = nil
        expectation = XCTestExpectation(description: "expectation")
        presenter = CourseNavigationPresenter(courseID: "1", view: self, env: env, useCase: MockUseCase {})
    }

    @discardableResult
    func tab() -> Tab {
        return Tab.make(["contextRaw": "course_1"])
    }

    func testLoadTabs() {
        //  given
        let expected = tab()

        //  when
        presenter.loadTabs()
        wait(for: [expectation], timeout: 0.1)
        //  then
        XCTAssertEqual(resultingTabs?.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(["position": 2, "id": "b", "contextRaw": "course_1"])
        Tab.make(["position": 3, "id": "c", "contextRaw": "course_1"])
        Tab.make(["position": 1, "id": "a", "contextRaw": "course_1"])

        presenter.loadTabs()

        XCTAssertEqual(resultingTabs?.count, 3)
        XCTAssertEqual(resultingTabs?.first?.id, "a")
        XCTAssertEqual(resultingTabs?.last?.id, "c")
    }

    func testUseCaseFetchesData() {
        //  given
        tab()

        //   when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingTabs?.first?.label, Tab.make().label)
    }
}

extension CourseNavigationPresenterTests: CourseNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
    }

    func showTabs(_ tabs: [CourseNavigationViewModel]) {
        resultingTabs = tabs
        expectation.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
