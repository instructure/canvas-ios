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

class DocViewerAnnotationDeleteResponseHandlerTests: XCTestCase {
    private let queue = DocViewerAnnotationUploaderQueue()
    private let mockDelegate = MockDocViewerAnnotationProviderDelegate()
    private lazy var task: DocViewerAnnotationUploaderQueue.Task = .delete(annotationID: "deletedID")
    private lazy var testee = DocViewerAnnotationDeleteResponseHandler(task: task, queue: queue, docViewerDelegate: mockDelegate)

    // MARK: - Success

    func testSuccessWithEmptyQueue() {
        let outcome = testee.handleResponse(nil, error: nil)
        XCTAssertEqual(outcome, .finished)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: false)])
        XCTAssertTrue(queue.tasks.isEmpty)
    }

    func testSuccessWithUpcomingTasksInQueue() {
        queue.put(.make(id: "deletedID2"))
        let outcome = testee.handleResponse(nil, error: nil)
        XCTAssertEqual(outcome, .processNextTask)
        XCTAssertTrue(mockDelegate.callStack.isEmpty)
        XCTAssertEqual(queue.tasks, [.put(.make(id: "deletedID2"))])
    }

    // MARK: - Failure

    func testFailure() {
        let outcome = testee.handleResponse(nil, error: NSError.instructureError("delete error"))
        XCTAssertEqual(outcome, .pausedOnError)
        XCTAssertEqual(mockDelegate.callStack, [.failedToSave])
        XCTAssertEqual(queue.tasks, [.delete(annotationID: "deletedID")])
    }

    func testUploadFailureWithTaskForTheSameAnnotationInTheQueue() {
        queue.put(.make(id: "deletedID"))
        let outcome = testee.handleResponse(nil, error: NSError.instructureError("delete error"))
        XCTAssertEqual(outcome, .processNextTask)
        XCTAssertTrue(mockDelegate.callStack.isEmpty)
        XCTAssertEqual(queue.tasks, [.put(.make(id: "deletedID"))])
    }
}
