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
@testable import Teacher
import XCTest

class StudentAnnotationSubmissionViewerViewModelTests: TeacherTestCase {
    private let mockRequest = CanvaDocsSessionRequest(submissionId: "123", attempt: "6")
    private var testee: StudentAnnotationSubmissionViewerViewModel!

    override func setUp() {
        super.setUp()

        let submission = Submission(context: databaseClient)
        submission.id = "123"
        submission.attempt = 6
        testee = StudentAnnotationSubmissionViewerViewModel(submission: submission)
    }

    func testSessionDefaultValue() {
        XCTAssertNil(testee.session)
    }

    func testUnknownFailureResult() {
        execute({
            testee.viewDidAppear()
        }, withExpectedUpdates: [
            nil,
            .failure(NSError.instructureError(String(localized: "Unknown Error", bundle: .teacher)))
        ])
    }

    func testKnownFailureResult() {
        execute({
            api.mock(mockRequest, value: nil, response: nil, error: NSError.instructureError("This is a test error"))
            testee.viewDidAppear()
        }, withExpectedUpdates: [
            nil,
            .failure(NSError.instructureError("This is a test error"))
        ])
    }

    func testSuccessResult() {
        execute({
            api.mock(mockRequest, value: .init(annotation_context_launch_id: nil, canvadocs_session_url: APIURL(rawValue: URL(string: "http://a.com")!)), response: nil, error: nil)
            testee.viewDidAppear()
        }, withExpectedUpdates: [
            nil,
            .success(URL(string: "http://a.com")!)
        ])
    }

    func testSuccessOnRetryAfterFailure() {
        execute({
            api.mock(mockRequest, value: nil, response: nil, error: NSError.instructureError("This is a test error"))
            testee.viewDidAppear()
            api.mock(mockRequest, value: .init(annotation_context_launch_id: nil, canvadocs_session_url: APIURL(rawValue: URL(string: "http://a.com")!)), response: nil, error: nil)
            testee.retry()
        }, withExpectedUpdates: [
            nil,
            .failure(NSError.instructureError("This is a test error")),
            nil,
            .success(URL(string: "http://a.com")!)
        ])
    }

    private func execute(_ testActions: () -> Void, withExpectedUpdates results: [Result<URL, Error>?]) {
        var updateCounter = 0
        let updateExpectation = expectation(description: "view model updates")
        updateExpectation.expectedFulfillmentCount = results.count

        let subscription = testee.$session.sink { result in
            defer { updateCounter += 1 }

            guard updateCounter < results.count else { return }
            updateExpectation.fulfill()

            let expectedResult = results[updateCounter]

            switch (expectedResult, result) {
            case (.success(let expectedURL), .success(let resultURL)):
                XCTAssertEqual(expectedURL, resultURL)
            case (.failure(let expectedError), .failure(let resultError)):
                XCTAssertEqual(expectedError.localizedDescription, resultError.localizedDescription)
            case (nil, nil):
                break
            default:
                XCTFail("Invalid result. Expected: \(String(describing: expectedResult)). Actual: \(String(describing: result))")
            }
        }

        testActions()
        wait(for: [updateExpectation], timeout: 0.1)
        subscription.cancel()
    }
}
