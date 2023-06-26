//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation
import TestsFoundation
import XCTest

class CourseSyncFilesInteractorLiveTests: CoreTestCase {
    override func setUp() {
        super.setUp()
        // Delete any existing file that might exist from previous runs
        try? FileManager.default.removeItem(at: URL.Directories.documents)
        try? FileManager.default.removeItem(at: URL.Directories.temporary)
    }

    func testFileDownloadProgress() {
        let testee = CourseSyncFilesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 5

        let url = URL(string: "1.jpg")!
        let mock = api.mock(url: url)
        mock.suspend()

        var progressList: [Float] = []
        let subscription = testee.getFile(
            url: url,
            fileID: "fileID",
            fileName: "fileName",
            mimeClass: "mimeClass"
        ).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                default:
                    break
                }
            },
            receiveValue: { progress in
                progressList.append(progress)
                expectation.fulfill()
            }
        )

        mock.download(didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 10)
        mock.download(didWriteData: 2, totalBytesWritten: 2, totalBytesExpectedToWrite: 10)
        mock.download(didWriteData: 2, totalBytesWritten: 4, totalBytesExpectedToWrite: 10)
        mock.download(didWriteData: 6, totalBytesWritten: 10, totalBytesExpectedToWrite: 10)
        FileManager.default.createFile(atPath: URL.Directories.temporary.path, contents: "test".data(using: .utf8))
        mock.download(didFinishDownloadingTo: URL.Directories.temporary)

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(progressList.count, 4)
        XCTAssertEqual(progressList[0], 0)
        XCTAssertEqual(progressList[1], 0.2)
        XCTAssertEqual(progressList[2], 0.4)
        XCTAssertEqual(progressList[3], 1)
        subscription.cancel()
    }

    func testFileDownloadError() {
        let testee = CourseSyncFilesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")
        expectation.expectedFulfillmentCount = 3

        let url = URL(string: "1.jpg")!
        let mock = api.mock(url: url)
        mock.suspend()

        var progressList: [Float] = []
        let subscription = testee.getFile(
            url: url,
            fileID: "1",
            fileName: "fileName",
            mimeClass: "mimeClass"
        ).sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    if error.localizedDescription == "Failed." {
                        expectation.fulfill()
                    }
                default:
                    break
                }
            },
            receiveValue: { progress in
                progressList.append(progress)
                expectation.fulfill()
            }
        )

        mock.download(didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 10)
        mock.download(didWriteData: 2, totalBytesWritten: 2, totalBytesExpectedToWrite: 10)
        mock.complete(withError: NSError.instructureError("Failed."))

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(progressList.count, 2)
        XCTAssertEqual(progressList[0], 0)
        XCTAssertEqual(progressList[1], 0.2)
        subscription.cancel()
    }

    func testMissingSessionError() {
        let testee = CourseSyncFilesInteractorLive()
        let expectation = expectation(description: "Publisher sends value")

        environment.currentSession = nil

        let subscription = testee.getFile(url: URL(string: "1")!, fileID: "1", fileName: "1", mimeClass: "1")
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    if error.localizedDescription == "There was an unexpected error. Please try again." {
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }, receiveValue: { _ in })

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }
}
