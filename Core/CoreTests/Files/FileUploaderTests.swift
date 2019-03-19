//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import TestsFoundation
@testable import Core
import XCTest

class FileUploaderTests: CoreTestCase {
    class MockURLSession: URLSession {
        override func finishTasksAndInvalidate() {}
    }

    let session = MockURLSession()
    var fileUploader: FileUploader!
    let user = KeychainEntry(
        accessToken: "1",
        baseURL: URL(string: "https://canvas.instructure.com")!,
        expiresAt: nil,
        locale: nil,
        refreshToken: nil,
        userID: "1",
        userName: "user"
    )

    var onUpdate: (() -> Void)?

    lazy var files: Store<LocalUseCase<File>> = { [weak self] in
        return environment.subscribe(scope: .all(orderBy: #keyPath(File.id))) {
            self?.onUpdate?()
        }
    }()

    var file: File? {
        return files.first
    }

    override func setUp() {
        super.setUp()
        environment.currentSession = user
        fileUploader = FileUploader(bundleID: "core-tests", appGroup: nil, environment: environment)
        fileUploader.backgroundAPI = api
        files.refresh()
    }

    func testSubmissionFlow() {
        let courseID = "1"
        let assignmentID = "2"
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")!
        databaseClient.performAndWait {
            let file = File.make()
            file.id = nil
            file.taskID = nil
            file.localFileURL = url
            file.prepareForSubmission(courseID: courseID, assignmentID: assignmentID)
            try! databaseClient.save()
        }

        let context = FileUploadContext.submission(courseID: "1", assignmentID: "2")
        let body = PostFileUploadTargetRequest.Body(name: url.lastPathComponent, on_duplicate: .rename, parent_folder_id: nil)
        let request = PostFileUploadTargetRequest(context: context, body: body)
        api.mock(request, value: FileUploadTarget.make(), response: nil, error: nil)
        let started = XCTestExpectation(description: "started upload")
        fileUploader.upload(file!, context: context) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
            started.fulfill()
        }
        wait(for: [started], timeout: 0.1)
        let task = MockAPITask(taskIdentifier: 1)

        // send data
        let sent = XCTestExpectation(description: "sent data")
        onUpdate = {
            if self.file?.bytesSent == 1 {
                sent.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didSendBodyData: 0, totalBytesSent: 1, totalBytesExpectedToSend: 10)
        wait(for: [sent], timeout: 0.1)

        // receive data
        let response = APIFile.make(["id": "45"])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(response)
        let received = XCTestExpectation(description: "received data")
        onUpdate = {
            if self.file?.id == response.id.value {
                received.fulfill()
            }
        }
        fileUploader.urlSession(session, dataTask: task, didReceive: data)
        wait(for: [received], timeout: 0.1)

        // complete
        XCTAssertNotNil(file?.taskID)
        let completed = XCTestExpectation(description: "task completed")
        onUpdate = {
            if self.file?.taskID == nil {
                completed.fulfill()
            }
        }
        fileUploader.urlSession(session, task: task, didCompleteWithError: nil)
        wait(for: [completed], timeout: 0.1)

        // submitted
        XCTAssertNotNil(file?.assignmentID)
    }
}
