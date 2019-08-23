//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Teacher
@testable import Core

class PostGradesPresenterTests: TeacherTestCase {

    var presenter: PostGradesPresenter!
    var updateExpectation = XCTestExpectation(description: "expectation")
    var didUpdatePostGradesExpectation = XCTestExpectation(description: "expectation")
    var errorExpectation = XCTestExpectation(description: "expectation")
    let courseID = "1"
    let assignmentID = "1"
    var didUpdatePostGrades = false
    var errorMessage: String?
    var viewModel: PostGradesPresenter.ViewModel?

    override func setUp() {
        super.setUp()
        viewModel = nil
        errorMessage = nil
        didUpdatePostGrades = false
        errorExpectation = XCTestExpectation(description: "expectation")
        updateExpectation = XCTestExpectation(description: "expectation")
        didUpdatePostGradesExpectation = XCTestExpectation(description: "expectation")
        presenter = PostGradesPresenter(courseID: courseID, assignmentID: assignmentID, view: self, env: environment)
    }

    func testUpdatePostGradesPolicy() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        let str = """
        {
            "data": {
                "postAssignmentGradesForSections": {
                    "assignment": {
                        "id": "\(assignmentID)"
                    }
                }
            }
        }
        """
        api.mock(req, data: str.data(using: .utf8), response: nil, error: nil)
        presenter.updatePostGradesPolicy(postPolicy: .everyone, sectionIDs: ["sectionID"])

        wait(for: [didUpdatePostGradesExpectation], timeout: 0.5)
        XCTAssertTrue(didUpdatePostGrades)
    }

    func testUpdatePostGradesPolicyWithError() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)

        api.mock(req, value: nil, response: nil, error: NSError.internalError())
        presenter.updatePostGradesPolicy(postPolicy: .everyone, sectionIDs: ["sectionID"])

        wait(for: [errorExpectation], timeout: 0.5)
        XCTAssertEqual(errorMessage, "An error ocurred")
    }

    func testViewIsReady() {
        let expectedSections = [APIPostPolicyInfo.SectionNode(id: "1", name: "section a")]
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        let str = """
        {
            "data": {
                "course": {
                    "sections": {
                        "nodes": [{
                            "id": "1",
                            "name": "section a"
                        }]
                    }
                },
                "assignment": {
                    "submissions": {
                        "nodes": [{
                            "score": 0.5,
                            "excused": false,
                            "state": "graded",
                            "postedAt": null
                        }]
                    }
                }
            }
        }
        """
        api.mock(req, data: str.data(using: .utf8), response: nil, error: nil)
        presenter.viewIsReady()

        wait(for: [updateExpectation], timeout: 0.5)
        XCTAssertEqual(viewModel?.gradesCurrentlyHidden, 1)
        XCTAssertEqual(viewModel?.sections, expectedSections)
    }

    func testViewIsReadyWithError() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        api.mock(req, value: nil, response: nil, error: NSError.internalError())
        presenter.viewIsReady()

        wait(for: [errorExpectation], timeout: 0.5)
        XCTAssertEqual(errorMessage, "An error ocurred")
    }
}

extension PostGradesPresenterTests: PostGradesViewProtocol {
    func update(_ viewModel: PostGradesPresenter.ViewModel) {
        self.viewModel = viewModel
        updateExpectation.fulfill()
    }

    func didUpdatePostGradesPolicy() {
        didUpdatePostGrades = true
        didUpdatePostGradesExpectation.fulfill()
    }

    var navigationController: UINavigationController? {
        return nil
    }

    func showAlert(title: String?, message: String?) {
        errorMessage = message
        errorExpectation.fulfill()
    }
}
