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
import TestsFoundation
import XCTest

class SubmissionCompletedNotificationSenderTests: CoreTestCase {
    func testSuccessNotificationBeingSent() {
        // MARK: - GIVEN

        let notificationManager = MockNotificationManager()
        let testee = SubmissionCompletedNotificationsSender(
            context: databaseClient,
            notificationManager: notificationManager
        )

        let courseID = "1"
        let assignmentID = "1"

        let submission: FileSubmission = databaseClient.insert()
        submission.courseID = courseID
        submission.assignmentID = assignmentID

        // MARK: - WHEN

        let completionEvent = expectation(description: "completion event fire")
        let subscription = testee.sendSuccessNofitications(
            fileSubmissionID: submission.objectID,
            apiSubmission: APISubmission.make()
        ).sink { _ in
            completionEvent.fulfill()
        }
        receiveValue: { _ in }

        // MARK: - THEN

        let content = UNMutableNotificationContent()
        let contentTitle = NSString.localizedUserNotificationString(
            forKey: "Assignment submitted!",
            arguments: nil
        )
        let contentBody = NSString.localizedUserNotificationString(
            forKey: "Your files were uploaded and the assignment was submitted successfully.",
            arguments: nil
        )
        content.title = contentTitle
        content.body = contentBody

        let notificationRequestIdentifier = "completed-submission-\(courseID)-\(assignmentID)"

        waitForExpectations(timeout: 0.1)

        guard let firedRequest = notificationManager.mock.requests.first else {
            return XCTFail("Couldn't find UNNotificationRequest with id: \(notificationRequestIdentifier)")
        }

        XCTAssertEqual(firedRequest.identifier, notificationRequestIdentifier)
        XCTAssertEqual(firedRequest.content.title, contentTitle)
        XCTAssertEqual(firedRequest.content.body, contentBody)

        subscription.cancel()
    }

    func testFailedNotificationBeingSent() {
        // MARK: - GIVEN

        let notificationManager = MockNotificationManager()
        let testee = SubmissionCompletedNotificationsSender(
            context: databaseClient,
            notificationManager: notificationManager
        )

        let courseID = "1"
        let assignmentID = "1"

        let submission: FileSubmission = databaseClient.insert()
        submission.courseID = courseID
        submission.assignmentID = assignmentID

        // MARK: - WHEN

        testee.sendFailedNotification(fileSubmissionID: submission.objectID)

        // MARK: - THEN

        let content = UNMutableNotificationContent()
        let contentTitle = NSString.localizedUserNotificationString(
            forKey: "Assignment submission failed!",
            arguments: nil
        )
        let contentBody = NSString.localizedUserNotificationString(
            forKey: "Something went wrong with an assignment submission.",
            arguments: nil
        )
        content.title = contentTitle
        content.body = contentBody

        let notificationRequestIdentifier = "failed-submission-\(courseID)-\(assignmentID)"

        drainMainQueue()
        guard let firedRequest = notificationManager.mock.requests.first else {
            return XCTFail("Couldn't find UNNotificationRequest with id: \(notificationRequestIdentifier)")
        }

        XCTAssertEqual(firedRequest.identifier, notificationRequestIdentifier)
        XCTAssertEqual(firedRequest.content.title, contentTitle)
        XCTAssertEqual(firedRequest.content.body, contentBody)
    }
}
