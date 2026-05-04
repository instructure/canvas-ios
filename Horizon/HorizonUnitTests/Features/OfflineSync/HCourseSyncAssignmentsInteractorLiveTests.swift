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

@testable import Core
@testable import Horizon
import Combine
import XCTest
import TestsFoundation

final class HCourseSyncAssignmentsInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        sessionID: "session 1",
        courseID: "course 1",
        courseID2: "course 2",
        assignmentID: "assignment 1",
        userID: "1",
        fileID1: "file 1",
        fileID2: "file 2",
        fileSize1: 1000,
        fileSize2: 2000
    )
    private lazy var testData = Self.testData

    private var htmlParser: AssignmentsHTMLParserMock!
    private var filesInteractor: AssignmentsFilesInteractorMock!
    private var testee: HCourseSyncAssignmentsInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        htmlParser = AssignmentsHTMLParserMock()
        filesInteractor = AssignmentsFilesInteractorMock()
        testee = HCourseSyncAssignmentsInteractorLive(
            htmlParser: htmlParser,
            filesInteractor: filesInteractor,
            userId: testData.userID
        )
    }

    override func tearDown() {
        testee = nil
        htmlParser = nil
        filesInteractor = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - attachmentProgressPublisher

    func test_attachmentProgressPublisher_shouldHaveZeroInitialValue() {
        var received: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.first().sink { received.append($0) }.store(in: &subscriptions)

        XCTAssertEqual(received.first?.totalSize, 0)
        XCTAssertEqual(received.first?.downloadedSize, 0)
        XCTAssertEqual(received.first?.isComplete, false)
    }

    // MARK: - cancelDownloads

    func test_cancelDownloads_shouldResetProgressToZero() {
        var received: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { received.append($0) }.store(in: &subscriptions)

        testee.cancelDownloads()

        XCTAssertEqual(received.last?.totalSize, 0)
        XCTAssertEqual(received.last?.downloadedSize, 0)
        XCTAssertEqual(received.last?.isComplete, false)
    }

    // MARK: - getContent

    func test_getContent_withEmptyCourseList_shouldCompleteAndSetIsCompleteTrue() {
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.isComplete, true)
    }

    func test_getContent_withCourseHavingNoAssignments_shouldCompleteAndSetIsCompleteTrue() {
        mockNoAssignments(courseID: testData.courseID)
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.isComplete, true)
    }

    func test_getContent_withAssignmentHavingNoSubmission_shouldCompleteAndSetIsCompleteTrue() {
        api.mock(GetGradingPeriodsRequest(courseID: testData.courseID), value: [])
        api.mock(
            GetAssignmentGroupsRequest(courseID: testData.courseID, gradingPeriodID: nil, perPage: 100),
            value: [APIAssignmentGroup.make(assignments: [
                APIAssignment.make(id: ID(testData.assignmentID), submission: nil)
            ])]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.isComplete, true)
    }

    func test_getContent_withAssignmentHavingSubmissionAndNoAttachments_shouldCompleteAndSetIsCompleteTrue() {
        mockAssignment(courseID: testData.courseID, assignmentID: testData.assignmentID, userID: testData.userID)
        mockSubmission(courseID: testData.courseID, assignmentID: testData.assignmentID, userID: testData.userID, attachments: nil)
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.isComplete, true)
    }

    func test_getContent_shouldResetProgressToZeroOnRepeat() {
        mockNoAssignments(courseID: testData.courseID)
        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        var received: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { received.append($0) }.store(in: &subscriptions)
        testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)

        XCTAssertEqual(received.first?.totalSize, 0)
    }

    func test_getContent_withMultipleCourses_shouldCompleteAndSetIsCompleteTrue() {
        mockNoAssignments(courseID: testData.courseID)
        mockNoAssignments(courseID: testData.courseID2)
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID, testData.courseID2], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.isComplete, true)
    }

    // MARK: - downloadSubmissionAttachments

    func test_getContent_withSubmissionAttachment_shouldUpdateTotalSizeInProgress() {
        mockAssignment(courseID: testData.courseID, assignmentID: testData.assignmentID, userID: testData.userID)
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1)]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.first { $0.totalSize > 0 }?.totalSize, Double(testData.fileSize1))
    }

    func test_getContent_withSubmissionAttachment_whenDownloadCompletes_shouldUpdateDownloadedSize() {
        filesInteractor.downloadPublisher = Just(Float(1.0))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(courseID: testData.courseID, assignmentID: testData.assignmentID, userID: testData.userID)
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1)]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.downloadedSize, Double(testData.fileSize1))
    }

    func test_getContent_withSubmissionAttachment_whenDownloadPartiallyProgresses_shouldUpdateDownloadedSize() {
        filesInteractor.downloadPublisher = Just(Float(0.5))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID
        )
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1)]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        let expectedDownloadedSize = Double(testData.fileSize1) * 0.5
        XCTAssertEqual(progressValues.first { $0.downloadedSize > 0 }?.downloadedSize, expectedDownloadedSize)
    }

    func test_getContent_withSubmissionAttachment_whenDownloadCompletes_shouldAddFileToDownloadedFiles() {
        filesInteractor.downloadPublisher = Just(Float(1.0))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID
        )
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1)]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        let downloadedFile = progressValues.last?.downloadedFiles.first
        XCTAssertEqual(downloadedFile?.fileID, testData.fileID1)
        XCTAssertEqual(downloadedFile?.courseID, testData.courseID)
    }

    func test_getContent_withSubmissionAttachment_whenDownloadPartiallyProgresses_shouldNotAddFileToDownloadedFiles() {
        filesInteractor.downloadPublisher = Just(Float(0.5))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID
        )
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1)]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        XCTAssertEqual(progressValues.last?.downloadedFiles.isEmpty, true)
    }

    func test_getContent_withMultipleSubmissionAttachments_shouldSumTotalSizes() {
        filesInteractor.downloadPublisher = Just(Float(1.0))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID
        )
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [
                APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1),
                APIFile.make(id: ID(testData.fileID2), size: testData.fileSize2)
            ]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        let expectedTotalSize = Double(testData.fileSize1 + testData.fileSize2)
        XCTAssertEqual(progressValues.first { $0.totalSize > 0 }?.totalSize, expectedTotalSize)
    }

    func test_getContent_withMultipleSubmissionAttachments_whenAllDownloadComplete_shouldListAllDownloadedFiles() {
        filesInteractor.downloadPublisher = Just(Float(1.0))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        mockAssignment(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID
        )
        mockSubmission(
            courseID: testData.courseID,
            assignmentID: testData.assignmentID,
            userID: testData.userID,
            attachments: [
                APIFile.make(id: ID(testData.fileID1), size: testData.fileSize1),
                APIFile.make(id: ID(testData.fileID2), size: testData.fileSize2)
            ]
        )
        var progressValues: [HAttachmentDownloadProgress] = []
        testee.attachmentProgressPublisher.sink { progressValues.append($0) }.store(in: &subscriptions)

        XCTAssertFinish(testee.getContent(courseIds: [testData.courseID], sessionID: testData.sessionID))

        let downloadedFileIDs = Set(progressValues.last?.downloadedFiles.map(\.fileID) ?? [])
        XCTAssertEqual(downloadedFileIDs, [testData.fileID1, testData.fileID2])
    }

    // MARK: - Private helpers

    private func mockNoAssignments(courseID: String) {
        api.mock(GetGradingPeriodsRequest(courseID: courseID), value: [])
        api.mock(GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: nil, perPage: 100), value: [])
    }

    private func mockAssignment(courseID: String, assignmentID: String, userID: String) {
        api.mock(GetGradingPeriodsRequest(courseID: courseID), value: [])
        api.mock(
            GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: nil, perPage: 100),
            value: [APIAssignmentGroup.make(assignments: [
                APIAssignment.make(
                    id: ID(assignmentID),
                    submission: APISubmission.make(assignment_id: ID(assignmentID).value, user_id: ID(userID).value)
                )
            ])]
        )
    }

    private func mockSubmission(courseID: String, assignmentID: String, userID: String, attachments: [APIFile]?) {
        api.mock(
            GetSubmission(context: .course(courseID), assignmentID: assignmentID, userID: userID),
            value: APISubmission.make(
                assignment_id: ID(assignmentID).value,
                attachments: attachments,
                body: nil,
                user_id: ID(userID).value
            )
        )
    }
}

// MARK: - Mocks

private final class AssignmentsHTMLParserMock: HTMLParser {
    var sectionName: String = "assignments"
    var envResolver: CourseSyncEnvironmentResolver = CourseSyncEnvironmentResolverLive()

    func sectionFolder(for courseId: CourseSyncID) -> URL {
        URL.Directories.documents
    }

    func parse(
        _ content: String,
        resourceId: String,
        courseId: CourseSyncID,
        baseURL: URL?
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func downloadAttachment(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class AssignmentsFilesInteractorMock: HCourseSyncFilesInteractor {
    var downloadPublisher: AnyPublisher<Float, Error> = Just(Float(1.0))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

    func downloadFiles(
        courses: [OfflineCourseItem],
        sessionID: String
    ) -> AnyPublisher<HFileDownloadProgress, Never> {
        Just(.zero).eraseToAnyPublisher()
    }

    func cancelDownloads() {}

    func deleteFiles(_ files: [OfflineFileItem], sessionID: String) {}

    func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        sessionID: String
    ) -> AnyPublisher< Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func download(file: File, courseID: String, sessionID: String) -> AnyPublisher<Float, Error> {
        downloadPublisher
    }
}
