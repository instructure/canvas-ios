//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class DocViewerAnnotationPutResponseHandlerTests: XCTestCase {
    private let annotation: APIDocViewerAnnotation = .make(id: "testID")
    private let queue = DocViewerAnnotationUploaderQueue()
    private let mockDelegate = MockDocViewerAnnotationProviderDelegate()
    private lazy var task: DocViewerAnnotationUploaderQueue.Task = .put(annotation)
    private lazy var testee = DocViewerAnnotationPutResponseHandler(annotation: annotation, task: task, queue: queue, docViewerDelegate: mockDelegate)

    // MARK: - Success

    func testSuccessWithEmptyQueue() {
        let outcome = testee.handleResponse(annotation, error: nil)
        XCTAssertEqual(outcome, .finished)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: false)])
        XCTAssertTrue(queue.tasks.isEmpty)
    }

    func testSuccessWithUpcomingTasksInQueue() {
        queue.delete("deletedID")
        let outcome = testee.handleResponse(annotation, error: nil)
        XCTAssertEqual(outcome, .processNextTask)
        XCTAssertEqual(mockDelegate.callStack, [])
        XCTAssertEqual(queue.tasks, [.delete(annotationID: "deletedID")])
    }

    // MARK: - Failure

    func testFailureWithoutError() {
        let outcome = testee.handleResponse(nil, error: nil)
        XCTAssertEqual(outcome, .pausedOnError)
        XCTAssertEqual(mockDelegate.callStack, [.failedToSave])
        XCTAssertEqual(queue.tasks, [.put(annotation)])
    }

    func testFailureWithCustomError() {
        let outcome = testee.handleResponse(nil, error: NSError.instructureError("custom error"))
        XCTAssertEqual(outcome, .pausedOnError)
        XCTAssertEqual(mockDelegate.callStack, [.failedToSave])
        XCTAssertEqual(queue.tasks, [.put(annotation)])
    }

    func testFailureWithDocViewerTooBigError() {
        let outcome = testee.handleResponse(nil, error: APIDocViewerError.tooBig)
        XCTAssertEqual(outcome, .pausedOnError)
        XCTAssertEqual(mockDelegate.callStack, [.exceededLimit(annotation)])
        XCTAssertEqual(queue.tasks, [.put(annotation)])
    }

    func testFailureWithTaskForTheSameAnnotationInTheQueue() {
        queue.delete("testID")
        let outcome = testee.handleResponse(nil, error: nil)
        XCTAssertEqual(outcome, .processNextTask)
        XCTAssertEqual(mockDelegate.callStack, [])
        XCTAssertEqual(queue.tasks, [.delete(annotationID: "testID")])
    }
}
