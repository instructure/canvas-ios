//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

@testable import Core
@testable import Student
import TestsFoundation
import XCTest

class StudentAnnotationSubmissionViewModelTests: StudentTestCase {
    private let testee = StudentAnnotationSubmissionViewModel(documentURL: URL(string: "a.b")!,
                                                              courseID: "123",
                                                              assignmentID: "321",
                                                              userID: "111",
                                                              annotatableAttachmentID: "3",
                                                              assignmentName: "Test Assignment",
                                                              courseColor: UIColor(hexString: "#BEEF00")!)

    func testDocumentURL() {
        XCTAssertEqual(testee.documentURL, URL(string: "a.b")!)
    }

    func testNavbar() {
        XCTAssertEqual(testee.navBar.title, "Student Annotation")
        XCTAssertEqual(testee.navBar.subtitle, "Test Assignment")
        XCTAssertEqual(testee.navBar.color, UIColor(hexString: "#BEEF00")!)
        XCTAssertEqual(testee.navBar.closeButtonTitle, "Close")
    }

    func testCloseTapDismissesView() {
        let dismissExpectation = expectation(description: "view dismissed")
        let subscription = testee.dismissView.sink {
            dismissExpectation.fulfill()
        }
        testee.closeTapped()
        wait(for: [dismissExpectation], timeout: 1)
        subscription.cancel()
    }

    func testDoneButtonInitialState() {
        XCTAssertEqual(testee.doneButton.title, "Submit")
        XCTAssertEqual(testee.doneButton.isDisabled, false)
        XCTAssertEqual(testee.doneButton.opacity, 1)
    }

    func testDoneButtonStateDuringSubmissionUpload() {
        let loadingExpectation = expectation(description: "button changed to its loading state")
        let finishedExpectation = expectation(description: "button changed back to its normal state")
        var updateCounter = 0
        let subscription = testee.$doneButton.sink { doneButton in
            switch updateCounter {
            case 1:
                XCTAssertEqual(doneButton.title, "Submitting...")
                XCTAssertEqual(doneButton.isDisabled, true)
                XCTAssertEqual(doneButton.opacity, 0.5)
                loadingExpectation.fulfill()
            case 2:
                XCTAssertEqual(doneButton.title, "Submit")
                XCTAssertEqual(doneButton.isDisabled, false)
                XCTAssertEqual(doneButton.opacity, 1)
                finishedExpectation.fulfill()
            default: // The first update is about the initial state, we're not interested in that
                break
            }
            updateCounter += 1
        }
        testee.postSubmission()
        wait(for: [loadingExpectation, finishedExpectation], timeout: 1)
        subscription.cancel()
    }

    func testSubmissionError() {
        let mockUseCase = CreateSubmission(context: .course("123"), assignmentID: "321", userID: "111", submissionType: .student_annotation)
        api.mock(mockUseCase, value: nil, response: nil, error: NSError.instructureError("This is a test error"))

        let errorExpectation = expectation(description: "error forwarded to view")
        let subscription = testee.$error.sink { error in
            guard let error = error else { return }
            XCTAssertEqual(error.title.lowercased(), "Submission Failed".lowercased())
            XCTAssertEqual(error.message, "This is a test error")
            errorExpectation.fulfill()
        }
        testee.postSubmission()
        wait(for: [errorExpectation], timeout: 1)
        subscription.cancel()
    }

    func testSubmissionSuccessDismissesView() {
        let mockUseCase = CreateSubmission(context: .course("123"), assignmentID: "321", userID: "111", submissionType: .student_annotation)
        api.mock(mockUseCase, value: .make())

        let dismissExpectation = expectation(description: "view dismissed")
        let subscription = testee.dismissView.sink {
            dismissExpectation.fulfill()
        }

        testee.postSubmission()
        wait(for: [dismissExpectation], timeout: 1)
        subscription.cancel()
    }

    func testSubmissionErrorIdIsUnique() {
        XCTAssertNotEqual(SubmissionError(title: "a", message: "b").id, SubmissionError(title: "a", message: "b").id)
    }
}
