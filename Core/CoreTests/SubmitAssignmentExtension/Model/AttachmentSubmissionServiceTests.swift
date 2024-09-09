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
import CoreData
import XCTest

class AttachmentSubmissionServiceTests: CoreTestCase {
    private var fileURL: URL!
    private var mockAssembly: MockFileSubmissionAssembly!

    override func setUp() {
        super.setUp()

        let fileURL = URL.Directories.temporary.appendingPathComponent("loadFileURL.txt", isDirectory: false)
        try! "test".write(to: fileURL, atomically: false, encoding: .utf8)
        self.fileURL = fileURL
        mockAssembly = MockFileSubmissionAssembly(testCase: self)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: fileURL)

        super.tearDown()
    }

    func testSubmit() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)

        // MARK: - WHEN
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmissionID, submissionID)
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.courseId, "testCourseID")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentId, "testAssignmentID")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentName, "testName")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.comment, "testComment")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.files, [fileURL])
        XCTAssertEqual(mockAssembly.startedSubmission, submissionID)
    }

    func testGroupCommentSubmit() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)

        // MARK: - WHEN
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: true)

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmissionID, submissionID)
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.courseId, "testCourseID")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentId, "testAssignmentID")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentName, "testName")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.comment, "testComment")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.isGroupComment, true)
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.files, [fileURL])
        XCTAssertEqual(mockAssembly.startedSubmission, submissionID)
    }

    func testReSubmitDeletesPreviousSubmission() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)

        // MARK: - WHEN
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)
        let submissionID2 = testee.submit(urls: [fileURL], courseID: "testCourseID2", assignmentID: "testAssignmentID2", assignmentName: "testName2", comment: "testComment2", isGroupComment: nil)

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.mockComposer.deletedSubmission, submissionID)
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmissionID, submissionID2)
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.courseId, "testCourseID2")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentId, "testAssignmentID2")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.assignmentName, "testName2")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.comment, "testComment2")
        XCTAssertEqual(mockAssembly.mockComposer.startedSubmission?.files, [fileURL])
        XCTAssertEqual(mockAssembly.startedSubmission, submissionID2)
    }

    func testCancel() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)

        // MARK: - WHEN
        testee.fileProgressViewModelCancel(FileProgressListViewModel(submissionID: submissionID, dismiss: {}))

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.canceledSubmission, submissionID)
    }

    func testRetry() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)

        // MARK: - WHEN
        testee.fileProgressViewModelRetry(FileProgressListViewModel(submissionID: submissionID, dismiss: {}))

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.startedSubmission, submissionID)
    }

    func testItemDeletion() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)
        let itemID = NSManagedObjectID()

        // MARK: - WHEN
        testee.fileProgressViewModel(FileProgressListViewModel(submissionID: submissionID, dismiss: {}), delete: itemID)

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.mockComposer.deletedItem, itemID)
    }

    func testSuccess() {
        // MARK: - GIVEN
        let testee = AttachmentSubmissionService(submissionAssembly: mockAssembly)
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", assignmentName: "testName", comment: "testComment", isGroupComment: nil)

        // MARK: - WHEN
        testee.fileProgressViewModel(FileProgressListViewModel(submissionID: submissionID, dismiss: {}), didAcknowledgeSuccess: submissionID)

        // MARK: - THEN
        XCTAssertEqual(mockAssembly.doneSubmission, submissionID)
    }
}

class MockFileSubmissionAssembly: FileSubmissionAssembly {
    public override var composer: FileSubmissionComposer { mockComposer }
    var canceledSubmission: NSManagedObjectID?
    var startedSubmission: NSManagedObjectID?
    var doneSubmission: NSManagedObjectID?
    let mockComposer: MockFileSubmissionComposer

    init(testCase: CoreTestCase) {
        mockComposer = MockFileSubmissionComposer(context: testCase.databaseClient)
        super.init(container: testCase.database, sessionID: "", sharedContainerID: "", sessionConfigurationProtocolClasses: nil, api: testCase.api)
    }

    public override func cancel(submissionID: NSManagedObjectID) {
        canceledSubmission = submissionID
    }

    public override func start(fileSubmissionID submissionID: NSManagedObjectID) {
        startedSubmission = submissionID
    }

    public override func markSubmissionAsDone(submissionID: NSManagedObjectID) {
        doneSubmission = submissionID
    }
}

class MockFileSubmissionComposer: FileSubmissionComposer {
    struct StartedSubmissionParams {
        let courseId: String
        let assignmentId: String
        let assignmentName: String
        let comment: String?
        let isGroupComment: Bool?
        let files: [URL]
    }
    var deletedSubmission: NSManagedObjectID?
    var deletedItem: NSManagedObjectID?
    var startedSubmission: StartedSubmissionParams?
    var startedSubmissionID: NSManagedObjectID?

    public override func makeNewSubmission(courseId: String, assignmentId: String, assignmentName: String, comment: String?, isGroupComment: Bool?, files: [URL]) -> NSManagedObjectID {
        startedSubmission = StartedSubmissionParams(courseId: courseId,
                                                    assignmentId: assignmentId,
                                                    assignmentName: assignmentName,
                                                    comment: comment,
                                                    isGroupComment: isGroupComment,
                                                    files: files)
        let startedSubmissionID = NSManagedObjectID()
        self.startedSubmissionID = startedSubmissionID
        return startedSubmissionID
    }

    public override func deleteItem(itemID: NSManagedObjectID) {
        deletedItem = itemID
    }

    public override func deleteSubmission(submissionID: NSManagedObjectID) {
        deletedSubmission = submissionID
    }
}
