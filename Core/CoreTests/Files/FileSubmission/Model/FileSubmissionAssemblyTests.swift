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

class FileSubmissionAssemblyTests: CoreTestCase {
    private var testFileURL: URL!
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    override func setUp() {
        super.setUp()
        createTestFile()
    }

    override func tearDown() {
        deleteTestFile()
        super.tearDown()
    }

    func testSubmission() {
        // MARK: - GIVEN
        let testee = FileSubmissionAssembly.makeShareExtensionAssembly()
        let submissionID = testee.composer.makeNewSubmission(courseId: "testCourse", assignmentId: "testAssignment", comment: "testComment", files: [testFileURL])
        let submission = try! databaseClient.existingObject(with: submissionID) as! FileSubmission
        XCTAssertEqual(databaseClient.registeredObjects.count, 2) // submission + item

        // MARK: File target request API mock
        let body = PostFileUploadTargetRequest.Body(name: "test.txt", on_duplicate: .rename, parent_folder_path: nil, size: 8)
        let fileUploadTargetRequest = PostFileUploadTargetRequest(context: .submission(courseID: "testCourse",
                                                                                       assignmentID: "testAssignment",
                                                                                       comment: "testComment"),
                                                                  body: body)
        api.mock(fileUploadTargetRequest, value: FileUploadTarget(upload_url: URL(string: "/uploadURL")!, upload_params: ["testKey": "testValue"]), error: nil)

        // MARK: Binary upload mock
        let session = testee.backgroundURLSessionProvider.session
        let mockDataTask = session.dataTask(with: URL(string: "/")!)
        mockDataTask.taskID = submission.files.first!.objectID.uriRepresentation().absoluteString
        let uploadResponse = try! encoder.encode(APIFile.make(id: "apiID"))
        let urlSessionDelegate = session.delegate as! URLSessionDataDelegate

        // MARK: Submission mock
        let requestedSubmission = CreateSubmissionRequest.Body.Submission(text_comment: "testComment",
                                                                          submission_type: .online_upload,
                                                                          file_ids: ["apiID"])
        let submissionRequest = CreateSubmissionRequest(context: .course("testCourse"),
                                                        assignmentID: "testAssignment",
                                                        body: .init(submission: requestedSubmission))
        api.mock(submissionRequest, value: APISubmission.make())

        // MARK: - WHEN
        testee.start(fileSubmissionID: submissionID)

        // MARK: - THEN
        urlSessionDelegate.urlSession?(session, dataTask: mockDataTask, didReceive: uploadResponse)
        urlSessionDelegate.urlSession?(session, task: mockDataTask, didCompleteWithError: nil)
        drainMainQueue()

        // After successful upload entities from CoreData should be removed and file should be deleted
        XCTAssertEqual(databaseClient.registeredObjects.count, 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFileURL.relativePath))
    }

    func testCancelDeletesSubmission() {
        let testee = FileSubmissionAssembly.makeShareExtensionAssembly()
        let submissionID = testee.composer.makeNewSubmission(courseId: "testCourse", assignmentId: "testAssignment", comment: "testComment", files: [])
        XCTAssertEqual(databaseClient.registeredObjects.count, 1)
        testee.cancel(submissionID: submissionID)
        drainMainQueue()
        databaseClient.reset()
        XCTAssertEqual(databaseClient.registeredObjects.count, 0)
    }

    func testCallsShareCompletedBlockWhenUploadContinuesInApp() {
        // MARK: - GIVEN
        let shareCompletedCallback = expectation(description: "Share completed callback called")
        let testee = FileSubmissionAssembly.makeShareExtensionAssembly()
        testee.setupShareUIDismissBlock {
            shareCompletedCallback.fulfill()
        }
        let submissionID = testee.composer.makeNewSubmission(courseId: "testCourse", assignmentId: "testAssignment", comment: "testComment", files: [testFileURL])
        let submission = try! databaseClient.existingObject(with: submissionID) as! FileSubmission

        // MARK: File target request API mock
        let body = PostFileUploadTargetRequest.Body(name: "test.txt", on_duplicate: .rename, parent_folder_path: nil, size: 8)
        let fileUploadTargetRequest = PostFileUploadTargetRequest(context: .submission(courseID: "testCourse",
                                                                                       assignmentID: "testAssignment",
                                                                                       comment: "testComment"),
                                                                  body: body)
        api.mock(fileUploadTargetRequest, value: FileUploadTarget(upload_url: URL(string: "/uploadURL")!, upload_params: ["testKey": "testValue"]), error: nil)

        // MARK: Binary upload mock
        let session = testee.backgroundURLSessionProvider.session
        let mockDataTask = session.dataTask(with: URL(string: "/")!)
        mockDataTask.taskID = submission.files.first!.objectID.uriRepresentation().absoluteString
        let urlSessionDelegate = session.delegate as! URLSessionDataDelegate

        // MARK: - WHEN
        testee.start(fileSubmissionID: submissionID)

        // MARK: - THEN
        urlSessionDelegate.urlSession?(session, task: mockDataTask, didCompleteWithError: URLError(.backgroundSessionWasDisconnected))
        waitForExpectations(timeout: 0.1)
    }

    private func createTestFile() {
        let url = URL.temporaryDirectory.appendingPathComponent("\(UUID.string)/test.txt")
        testFileURL = url
        XCTAssertNoThrow(try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true))
        FileManager.default.createFile(atPath: url.path, contents: "testfile".data(using: .utf8)!)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testFileURL.relativePath))
    }

    private func deleteTestFile() {
        try? FileManager.default.removeItem(at: testFileURL)
    }
}
