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
import TestsFoundation
import XCTest

class FileSubmissionBackgroundTerminationHandlerTests: CoreTestCase {
    private lazy var notificationsSender = SubmissionCompletedNotificationsSender(
        context: databaseClient,
        localNotifications: LocalNotificationsInteractor(
            notificationCenter: notificationCenter
        )
    )
    private lazy var testee = FileSubmissionBackgroundTerminationHandler(context: databaseClient,
                                                                         notificationsSender: notificationsSender)

    // MARK: - Error Messages

    func testWritesErrorToFileItemIfItHasNoAPIID() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        XCTAssertEqual(item.uploadError, "The submission process was terminated by the operating system.")
        XCTAssertNil(submission.submissionError)
    }

    func testWritesErrorToSubmissionIfItemHasIDButSubmissionIsNotSubimtted() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission
        item.apiID = "testID"

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        XCTAssertEqual(submission.submissionError, "The submission process was terminated by the operating system.")
        XCTAssertNil(item.uploadError)
    }

    func testWritesNoErrorIfItemHasIDAndSubmissionIsSubmitted() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.isSubmitted = true
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission
        item.apiID = "testID"

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        XCTAssertNil(submission.submissionError)
        XCTAssertNil(item.uploadError)
    }

    // MARK: - Failed Notifications

    func testSendsFailedNotificationIfItemHasNoAPIID() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.courseID = "testCourseID"
        submission.assignmentID = "testAssignmentID"
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        drainMainQueue()
        guard let notification = notificationCenter.requests.last else {
            return XCTFail("Couldn't find UNNotificationRequest")
        }

        XCTAssertEqual(notification.content.title, title)
        XCTAssertEqual(notification.content.body, body)
    }

    func testSendsFailedNotificationIfSubmissionIsNotSubmitted() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.courseID = "testCourseID"
        submission.assignmentID = "testAssignmentID"
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission
        item.apiID = "testID"
        let title = NSString.localizedUserNotificationString(forKey: "Assignment submission failed!", arguments: nil)
        let body = NSString.localizedUserNotificationString(forKey: "Something went wrong with an assignment submission.", arguments: nil)

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        drainMainQueue()
        guard let notification = notificationCenter.requests.last else {
            return XCTFail("Couldn't find UNNotificationRequest")
        }

        XCTAssertEqual(notification.content.title, title)
        XCTAssertEqual(notification.content.body, body)
    }

    func testSendsNoNotificationIfSubmissionIsSubmitted() {
        // MARK: - GIVEN
        let submission: FileSubmission = databaseClient.insert()
        submission.courseID = "testCourseID"
        submission.assignmentID = "testAssignmentID"
        submission.isSubmitted = true
        let item: FileUploadItem = databaseClient.insert()
        item.fileSubmission = submission

        // MARK: - WHEN
        testee.handleTermination(fileUploadItemID: item.objectID)

        // MARK: - THEN
        drainMainQueue()
        XCTAssertNil(notificationCenter.requests.last)
    }
}
