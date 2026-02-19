//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Combine
import CoreData
@testable import Core
@testable import Student
import TestsFoundation
import XCTest

final class FileUploadProgressWidgetViewModelTests: StudentTestCase {

    private var testee: FileUploadProgressWidgetViewModel!
    private var listViewModel: FileUploadNotificationCardListViewModel!
    private var widgetRouter: Router!
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = singleSharedTestDatabase.viewContext
        let environment = AppEnvironment.shared
        environment.database = singleSharedTestDatabase
        widgetRouter = environment.router
        listViewModel = FileUploadNotificationCardListViewModel(environment: environment)
    }

    override func tearDown() {
        testee = nil
        listViewModel = nil
        widgetRouter = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInit_setsInitialState() {
        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.uploadCards.count, 0)
    }

    // MARK: - Upload Cards

    func testUploadCards_emptyWhenNoSubmissions() {
        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        XCTAssertEqual(testee.uploadCards.count, 0)
        XCTAssertEqual(testee.state, .empty)
    }

    func testUploadCards_showsVisibleSubmissions() {
        let fileSubmission: FileSubmission = context.insert()
        fileSubmission.assignmentName = "Test Assignment"
        fileSubmission.courseID = "1"
        fileSubmission.assignmentID = "1"
        fileSubmission.isHiddenOnDashboard = false

        let fileItem: FileUploadItem = context.insert()
        fileItem.fileSubmission = fileSubmission
        fileItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("test.pdf")
        fileItem.fileSize = 1000
        fileItem.bytesToUpload = 1000
        fileItem.bytesUploaded = 500

        try? context.save()

        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 1)
        XCTAssertEqual(testee.uploadCards.first?.assignmentName, "Test Assignment")
        XCTAssertEqual(testee.uploadCards.first?.assignmentRoute, "/courses/1/assignments/1")
        XCTAssertEqual(testee.uploadCards.first?.state, .uploading)
        XCTAssertEqual(testee.uploadCards.first?.progress, 0.5)
        XCTAssertEqual(testee.state, .data)
    }

    func testUploadCards_hidesHiddenSubmissions() {
        let fileSubmission: FileSubmission = context.insert()
        fileSubmission.assignmentName = "Test Assignment"
        fileSubmission.courseID = "1"
        fileSubmission.assignmentID = "1"
        fileSubmission.isHiddenOnDashboard = true

        let fileItem: FileUploadItem = context.insert()
        fileItem.fileSubmission = fileSubmission
        fileItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("test.pdf")
        fileItem.fileSize = 1000

        try? context.save()

        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 0)
        XCTAssertEqual(testee.state, .empty)
    }

    func testUploadCards_mapsSuccessState() {
        let fileSubmission: FileSubmission = context.insert()
        fileSubmission.assignmentName = "Test Assignment"
        fileSubmission.courseID = "1"
        fileSubmission.assignmentID = "1"
        fileSubmission.isHiddenOnDashboard = false
        fileSubmission.isSubmitted = true

        let fileItem: FileUploadItem = context.insert()
        fileItem.fileSubmission = fileSubmission
        fileItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("test.pdf")
        fileItem.apiID = "uploaded-id"
        fileItem.fileSize = 1000

        try? context.save()

        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 1)
        XCTAssertEqual(testee.uploadCards.first?.state, .success)
        XCTAssertNil(testee.uploadCards.first?.progress)
    }

    func testUploadCards_mapsFailureState() {
        let fileSubmission: FileSubmission = context.insert()
        fileSubmission.assignmentName = "Test Assignment"
        fileSubmission.courseID = "1"
        fileSubmission.assignmentID = "1"
        fileSubmission.isHiddenOnDashboard = false

        let fileItem: FileUploadItem = context.insert()
        fileItem.fileSubmission = fileSubmission
        fileItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("test.pdf")
        fileItem.uploadError = "Upload failed"
        fileItem.fileSize = 1000

        try? context.save()

        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 1)
        XCTAssertEqual(testee.uploadCards.first?.state, .failed)
        XCTAssertNil(testee.uploadCards.first?.progress)
    }

    // MARK: - Dismiss

    func testDismiss_hidesCard() {
        let fileSubmission: FileSubmission = context.insert()
        fileSubmission.assignmentName = "Test Assignment"
        fileSubmission.courseID = "1"
        fileSubmission.assignmentID = "1"
        fileSubmission.isHiddenOnDashboard = false

        let fileItem: FileUploadItem = context.insert()
        fileItem.fileSubmission = fileSubmission
        fileItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("test.pdf")
        fileItem.fileSize = 1000

        try? context.save()

        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 1)

        let uploadId = testee.uploadCards.first!.id
        testee.dismiss(uploadId: uploadId)

        drainMainQueue()

        XCTAssertEqual(testee.uploadCards.count, 0)
        XCTAssertEqual(testee.state, .empty)
    }

    // MARK: - Protocol Conformance

    func testIsFullWidth_returnsTrue() {
        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        XCTAssertEqual(testee.isFullWidth, true)
    }

    func testIsEditable_returnsFalse() {
        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        XCTAssertEqual(testee.isEditable, false)
    }

    func testRefresh_returnsImmediately() {
        testee = FileUploadProgressWidgetViewModel(
            config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
            router: widgetRouter,
            listViewModel: listViewModel
        )

        let expectation = expectation(description: "refresh completes")
        let subscription = testee.refresh(ignoreCache: true).sink {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }
}
