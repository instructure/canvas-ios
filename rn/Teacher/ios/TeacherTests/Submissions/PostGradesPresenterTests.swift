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
    var didHideGradesExpectation = XCTestExpectation(description: "expectation")
    var errorExpectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")
    var hiddenStateExpectation = XCTestExpectation(description: "expectation")
    let courseID = "1"
    let assignmentID = "1"
    var didUpdatePostGrades = false
    var didUpdateHideGrades = false
    var didShowAllHidden = false
    var didShowAllPosted = false
    var errorMessage: String?
    var viewModel: APIPostPolicyInfo?
    var resultingColor: UIColor?

    override func setUp() {
        super.setUp()
        viewModel = nil
        errorMessage = nil
        didUpdatePostGrades = false
        didUpdateHideGrades = false
        didShowAllHidden = false
        didShowAllPosted = false
        didHideGradesExpectation = XCTestExpectation(description: "expectation")
        colorExpectation = XCTestExpectation(description: "expectation")
        errorExpectation = XCTestExpectation(description: "expectation")
        updateExpectation = XCTestExpectation(description: "expectation")
        didUpdatePostGradesExpectation = XCTestExpectation(description: "expectation")
        hiddenStateExpectation = XCTestExpectation(description: "expectation")
        presenter = PostGradesPresenter(courseID: courseID, assignmentID: assignmentID, view: self, env: environment)
    }

    func testPostGrades() {
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
        api.mock(req, data: str.data(using: .utf8)!, response: nil, error: nil)
        presenter.postGrades(postPolicy: .everyone, sectionIDs: ["sectionID"])

        wait(for: [didUpdatePostGradesExpectation], timeout: 0.5)
        XCTAssertTrue(didUpdatePostGrades)
    }

    func testHideGrades() {
        let req = HideAssignmentGradesPostPolicyRequest(assignmentID: assignmentID)
        let str = """
        {
            "data": {
                "hideAssignmentGradesForSections": {
                    "assignment": {
                        "id": "\(assignmentID)"
                    }
                }
            }
        }
        """
        api.mock(req, data: str.data(using: .utf8)!, response: nil, error: nil)
        presenter.hideGrades(sectionIDs: ["sectionID"])

        wait(for: [didHideGradesExpectation], timeout: 0.5)
        XCTAssertTrue(didUpdateHideGrades)
    }

    func testPostGradesWithError() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)

        api.mock(req, value: nil, response: nil, error: NSError.internalError())
        presenter.postGrades(postPolicy: .everyone, sectionIDs: ["sectionID"])

        wait(for: [errorExpectation], timeout: 0.5)
        XCTAssertEqual(errorMessage, "Internal Error")
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
                        },
                        {
                            "score": 0.6,
                            "excused": false,
                            "state": "graded",
                            "postedAt": "2019-08-22T07:28:44-06:00"
                        }]
                    }
                }
            }
        }
        """
        api.mock(req, data: str.data(using: .utf8)!, response: nil, error: nil)
        presenter.viewIsReady()

        wait(for: [updateExpectation], timeout: 0.5)
        XCTAssertEqual(viewModel?.submissions.hiddenCount, 1)
        XCTAssertEqual(viewModel?.sections, expectedSections)
    }

    func testViewIsReadyWithError() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        api.mock(req, value: nil, response: nil, error: NSError.internalError())
        presenter.viewIsReady()

        wait(for: [errorExpectation], timeout: 0.5)
        XCTAssertEqual(errorMessage, "Internal Error")
    }

    func testColor() {
        _ = Course.make()
        let expectedColor = ContextColor.make()

        presenter.viewIsReady()
        wait(for: [colorExpectation], timeout: 0.5)

        XCTAssertEqual(resultingColor!.hexString, expectedColor.color.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testAllGradesPosted() {
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
                            "postedAt": "2019-08-22T07:28:44-06:00"
                        }]
                    }
                }
            }
        }
        """
        api.mock(req, data: str.data(using: .utf8)!, response: nil, error: nil)
        presenter.viewIsReady()

        wait(for: [hiddenStateExpectation], timeout: 0.5)
        XCTAssertTrue(didShowAllPosted)
    }

    func testAllGradesHidden() {
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
        api.mock(req, data: str.data(using: .utf8)!, response: nil, error: nil)
        presenter.viewIsReady()

        wait(for: [hiddenStateExpectation], timeout: 0.5)
        XCTAssertTrue(didShowAllHidden)
    }
}

extension PostGradesPresenterTests: PostGradesViewProtocol {
    func updateCourseColor(_ color: UIColor) {
        resultingColor = color
        colorExpectation.fulfill()
    }

    func update(_ viewModel: APIPostPolicyInfo) {
        self.viewModel = viewModel
        updateExpectation.fulfill()
    }

    func didPostGrades() {
        didUpdatePostGrades = true
        didUpdatePostGradesExpectation.fulfill()
    }

    func didHideGrades() {
        didUpdateHideGrades = true
        didHideGradesExpectation.fulfill()
    }

    func showAllPostedView() {
        didShowAllPosted = true
        hiddenStateExpectation.fulfill()
    }

    func showAllHiddenView() {
        didShowAllHidden = true
        hiddenStateExpectation.fulfill()
    }

    var navigationController: UINavigationController? {
        return nil
    }

    func showAlert(title: String?, message: String?) {
        errorMessage = message
        errorExpectation.fulfill()
    }
}
