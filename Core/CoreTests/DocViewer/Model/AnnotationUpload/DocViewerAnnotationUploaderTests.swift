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

class DocViewerAnnotationUploaderTests: CoreTestCase {
    private let sessionID = "testSessionID"
    private let mockDelegate = MockDocViewerAnnotationProviderDelegate()
    private let queue = DocViewerAnnotationUploaderQueue()
    private lazy var testee: DocViewerAnnotationUploader = {
        let uploader = DocViewerAnnotationUploader(api: api, sessionID: sessionID, queue: queue)
        uploader.docViewerDelegate = mockDelegate
        return uploader
    }()

    // MARK: - Successful Save

    func testConsumesSaveAnnotationTaskOnEmptyQueue() {
        api.mock(PutDocViewerAnnotationRequest(body: .make(), sessionID: sessionID), value: .make())
        XCTAssertTrue(queue.tasks.isEmpty)

        testee.save(.make())

        XCTAssertTrue(queue.tasks.isEmpty)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true), .saveStateChanged(isSaving: false)])
    }

    func testConsumesDeleteAnnotationTaskOnEmptyQueue() {
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deletedID", sessionID: sessionID))
        XCTAssertTrue(queue.tasks.isEmpty)

        testee.delete(annotationID: "deletedID")

        XCTAssertTrue(queue.tasks.isEmpty)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true), .saveStateChanged(isSaving: false)])
    }

    func testConsumesAllTasksInQueue() {
        let delete1Mock = api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted1", sessionID: sessionID))
        delete1Mock.suspend()
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted2", sessionID: sessionID))
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted3", sessionID: sessionID))
        XCTAssertTrue(queue.tasks.isEmpty)

        testee.delete(annotationID: "deleted1")
        testee.delete(annotationID: "deleted2")
        testee.delete(annotationID: "deleted3")

        XCTAssertEqual(queue.tasks.count, 2) // the first task is in progress and out of the queue
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true)])
        delete1Mock.resume()
        XCTAssertTrue(queue.tasks.isEmpty)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true),
                                                .saveStateChanged(isSaving: true),
                                                .saveStateChanged(isSaving: true),
                                                .saveStateChanged(isSaving: false)
        ])
    }

    // MARK: - Failed Uploads

    func testFailedUploadPausesQueueAndPutsTaskBackToQueue() {
        let delete1Mock = api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted1", sessionID: sessionID), error: NSError.instructureError("testError"))
        delete1Mock.suspend()
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted2", sessionID: sessionID))

        testee.delete(annotationID: "deleted1")
        testee.delete(annotationID: "deleted2")
        delete1Mock.resume()

        XCTAssertEqual(queue.tasks, [.delete(annotationID: "deleted1"), .delete(annotationID: "deleted2")])
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true),
                                                .failedToSave
        ])
    }

    func testFailedUploadRetriedWhenAsked() {
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted1", sessionID: sessionID), error: NSError.instructureError("testError"))

        testee.delete(annotationID: "deleted1")
        api.mock(DeleteDocViewerAnnotationRequest(annotationID: "deleted1", sessionID: sessionID))
        testee.retryFailedRequest()

        XCTAssertTrue(queue.tasks.isEmpty)
        XCTAssertEqual(mockDelegate.callStack, [.saveStateChanged(isSaving: true),
                                                .failedToSave,
                                                .saveStateChanged(isSaving: true),
                                                .saveStateChanged(isSaving: false)
        ])
    }
}
