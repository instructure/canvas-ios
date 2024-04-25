//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation
import Combine

class HTMLDownloadInteractorLiveTests: CoreTestCase {

    let testCourseId = "1"
    let testResourceId = "2"
    let testSectionName = "test"
    let testURL = URL(string: "https://www.instructure.com/logo.png")!

    var subscriptions: [AnyCancellable] = []

    func testDownload() {
        let testee = HTMLDownloadInteractorLive(loginSession: environment.currentSession!, sectionName: testSectionName, scheduler: .main)
        let mockPublisherProvider = URLSessionDataTaskPublisherProviderMock()
        testee.download(testURL, courseId: testCourseId, resourceId: testResourceId, publisherProvider: mockPublisherProvider)
            .sink(receiveCompletion: { _ in }, receiveValue: { [testURL] result in

                let data = try? String(contentsOf: URL(string: result)!, encoding: .utf8)

                XCTAssertNotEqual(result, testURL.path)
                XCTAssertEqual(result, URL.Directories.documents.appendingPathComponent(testURL.lastPathComponent).path)
                XCTAssertEqual(data, "hello")
            })
            .store(in: &subscriptions)
    }

    func testFileDownload() {
        let testee = HTMLDownloadInteractorLive(loginSession: environment.currentSession!, sectionName: testSectionName, scheduler: .main)
        let mockPublisherProvider = URLSessionDataTaskPublisherProviderMock()
        testee.downloadFile(testURL, courseId: testCourseId, resourceId: testResourceId, publisherProvider: mockPublisherProvider)
            .sink(receiveCompletion: { _ in }, receiveValue: { [testURL] result in

                let data = try? String(contentsOf: URL(string: result)!, encoding: .utf8)

                XCTAssertNotEqual(result, testURL.path)
                XCTAssertEqual(result, URL.Directories.documents.appendingPathComponent(testURL.lastPathComponent).path)
                XCTAssertEqual(data, "hello")
            })
            .store(in: &subscriptions)
    }

    func testBaseContentSave() {
        let testee = HTMLDownloadInteractorLive(loginSession: environment.currentSession!, sectionName: testSectionName, scheduler: .main)

        let rootURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseSectionFolder(
                    sessionId: environment.currentSession!.uniqueID,
                    courseId: testCourseId,
                    sectionName: testSectionName
                )
            )
            .appendingPathComponent("\(testSectionName)-\(testResourceId)")

        testee.saveBaseContent(content: "test", folderURL: rootURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertTrue(FileManager.default.fileExists(atPath: rootURL.appendingPathComponent("body.html").path))
            })
            .store(in: &subscriptions)
    }

    class URLSessionDataTaskPublisherProviderMock: URLSessionDataTaskPublisherProvider {
        let testString = "hello"
        let savedURL = URL.Directories.documents.appendingPathComponent("logo.png")

        func getPublisher(for request: URLRequest) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
            let savedData = testString.data(using: .utf8)
            FileManager.default.createFile(atPath: savedURL.path, contents: savedData)

            return Just((tempURL: savedURL, fileName: "logo.png"))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
