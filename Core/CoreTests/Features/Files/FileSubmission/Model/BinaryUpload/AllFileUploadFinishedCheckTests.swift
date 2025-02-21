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

import Core
import CoreData
import XCTest

class AllFileUploadFinishedCheckTests: CoreTestCase {

    func testFinishesWhenAllItemsHaveAPIID() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item1: FileUploadItem = databaseClient.insert()
        item1.apiID = "id1"
        item1.fileSubmission = submission
        let item2: FileUploadItem = databaseClient.insert()
        item2.apiID = "id1"
        item2.fileSubmission = submission

        let completionEvent = expectation(description: "completion event fire")
        let testee = AllFileUploadFinishedCheck(context: databaseClient, fileSubmissionID: submission.objectID)

        // MARK: - WHEN
        let subscription = testee.isAllUploadFinished().sink { completion in
            if case .finished = completion {
                completionEvent.fulfill()
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 1)

        subscription.cancel()
    }

    func testNotReadyErrorWhenOneFileHasNoAPIIDAndOtherHas() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item1: FileUploadItem = databaseClient.insert()
        item1.apiID = "id1"
        item1.fileSubmission = submission
        let item2: FileUploadItem = databaseClient.insert()
        item2.fileSubmission = submission

        let completionEvent = expectation(description: "completion event fire")
        let testee = AllFileUploadFinishedCheck(context: databaseClient, fileSubmissionID: submission.objectID)

        // MARK: - WHEN
        let subscription = testee.isAllUploadFinished().sink { completion in
            if case .failure(let error) = completion {
                completionEvent.fulfill()
                XCTAssertEqual(error, .notFinished)
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 1)

        subscription.cancel()
    }

    func testNotReadyErrorWhenOneFileIsUploadingAndOtherFailed() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item1: FileUploadItem = databaseClient.insert()
        item1.uploadError = "error"
        item1.fileSubmission = submission
        let item2: FileUploadItem = databaseClient.insert()
        item2.fileSubmission = submission

        let completionEvent = expectation(description: "completion event fire")
        let testee = AllFileUploadFinishedCheck(context: databaseClient, fileSubmissionID: submission.objectID)

        // MARK: - WHEN
        let subscription = testee.isAllUploadFinished().sink { completion in
            if case .failure(let error) = completion {
                completionEvent.fulfill()
                XCTAssertEqual(error, .notFinished)
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 1)

        subscription.cancel()
    }

    func testUploadFailedErrorWhenOneFileHasAPIIDAndOtherHasError() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item1: FileUploadItem = databaseClient.insert()
        item1.apiID = "id1"
        item1.fileSubmission = submission
        let item2: FileUploadItem = databaseClient.insert()
        item2.fileSubmission = submission
        item2.uploadError = "error"

        let completionEvent = expectation(description: "completion event fire")
        let testee = AllFileUploadFinishedCheck(context: databaseClient, fileSubmissionID: submission.objectID)

        // MARK: - WHEN
        let subscription = testee.isAllUploadFinished().sink { completion in
            if case .failure(let error) = completion {
                completionEvent.fulfill()
                XCTAssertEqual(error, .uploadFailed)
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 1)

        subscription.cancel()
    }

    func testSubmissionNotFoundErrorWhenSubmissionNotFoundInCoreData() {
        // MARK: - GIVEN
        let invalidSubmissionID: NSManagedObjectID = (databaseClient.insert() as FileUploadItem).objectID
        let completionEvent = expectation(description: "completion event fire")
        let testee = AllFileUploadFinishedCheck(context: databaseClient, fileSubmissionID: invalidSubmissionID)

        // MARK: - WHEN
        let subscription = testee.isAllUploadFinished().sink { completion in
            if case .failure(let error) = completion {
                completionEvent.fulfill()
                XCTAssertEqual(error, .coreData(.submissionNotFound))
            }
        }

        // MARK: - THEN
        waitForExpectations(timeout: 1)

        subscription.cancel()
    }
}
