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
import CoreData
import XCTest

class FileSubmissionItemsUploadStarterTests: CoreTestCase {

    func testFailsIfSubmissionNotFoundInCoreData() {
        // MARK: - GIVEN
        let invalidSubmissionID: NSManagedObjectID = (databaseClient.insert() as FileUploadItem).objectID
        let completionEvent = expectation(description: "completion event fire")
        let testee = FileSubmissionItemsUploadStarter(api: api,
                                                      context: databaseClient,
                                                      backgroundSessionProvider: MockBackgroundURLSessionProvider())

        // MARK: - WHEN
        let subscription = testee.startUploads(fileSubmissionID: invalidSubmissionID).sink { completion in
            if case .failure(let error) = completion {
                completionEvent.fulfill()
                XCTAssertEqual(error as? FileSubmissionErrors.CoreData, .submissionNotFound)
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)

        subscription.cancel()
    }

    func testWritesUploadErrorToItemIfItHasNoUploadTarget() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission

        let completionEvent = expectation(description: "completion event fire")
        let testee = FileSubmissionItemsUploadStarter(api: api,
                                                      context: databaseClient,
                                                      backgroundSessionProvider: MockBackgroundURLSessionProvider())

        // MARK: - WHEN
        let subscription = testee.startUploads(fileSubmissionID: submission.objectID).sink { completion in
            if case .finished = completion {
                completionEvent.fulfill()
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(item.uploadError, "Failed to start upload.")

        subscription.cancel()
    }

    func testStartsFileUploadAndSetsTaskIDOnUploadTask() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.localFileURL = URL(string: "/localFile.txt")!
        item.uploadTarget = FileUploadTarget(upload_url: URL(string: "/uploadURL")!, upload_params: [:])
        item.fileSubmission = submission

        let apiMock = api.mock(url: URL(string: "///uploadURL")!, method: .post)
        apiMock.suspend()

        let completionEvent = expectation(description: "completion event fire")
        let testee = FileSubmissionItemsUploadStarter(api: api,
                                                      context: databaseClient,
                                                      backgroundSessionProvider: MockBackgroundURLSessionProvider())

        // MARK: - WHEN
        let subscription = testee.startUploads(fileSubmissionID: submission.objectID).sink { completion in
            if case .finished = completion {
                completionEvent.fulfill()
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.2)
        XCTAssertNil(item.uploadError)

        guard let mockAPITask = apiMock.queue.first else {
            XCTFail("Upload session not started.")
            return
        }

        XCTAssertEqual(mockAPITask.taskID, item.objectID.uriRepresentation().absoluteString)

        subscription.cancel()
    }

    func testResetsPreviousUploadErrorAndUploadedBytesAndAPIIDOnUploadItem() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.apiID = "id1"
        item.localFileURL = URL(string: "/localFile.txt")!
        item.uploadTarget = FileUploadTarget(upload_url: URL(string: "/uploadURL")!, upload_params: [:])
        item.uploadError = "error"
        item.bytesUploaded = 1
        item.fileSubmission = submission

        let apiMock = api.mock(url: URL(string: "///uploadURL")!)
        apiMock.suspend()

        let completionEvent = expectation(description: "completion event fire")
        let testee = FileSubmissionItemsUploadStarter(api: api,
                                                      context: databaseClient,
                                                      backgroundSessionProvider: MockBackgroundURLSessionProvider())

        // MARK: - WHEN
        let subscription = testee.startUploads(fileSubmissionID: submission.objectID).sink { completion in
            if case .finished = completion {
                completionEvent.fulfill()
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(item.uploadError)
        XCTAssertNil(item.apiID)
        XCTAssertEqual(item.bytesUploaded, 0)

        subscription.cancel()
    }
}

final class MockBackgroundURLSessionProvider: BackgroundURLSessionProvider {

    init() {
        super.init(sessionID: "", sharedContainerID: "", uploadProgressObserversCache: MockFileUploadProgressObserversCache())
    }
}
