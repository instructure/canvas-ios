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
    let testPrefix = "test"
    let testResponse = (data: Data(base64Encoded: "aGVsbG8=")!,
                        response: URLResponse.init(
                            url: URL(string: "https://www.instructure.com/logo.png")!,
                            mimeType: nil,
                            expectedContentLength: 100,
                            textEncodingName: nil
                        ))

    var subscriptions: [AnyCancellable] = []

    func testDownload() {
        let testee = HTMLDownloadInteractorLive(loginSession: environment.currentSession!, sectionName: testSectionName, scheduler: .main)
        let url = URL(string: "https://www.instructure.com/logo.png")!
        let mockPublisherProvider = URLSessionDataTaskPublisherProviderMock()
        testee.download(url, publisherProvider: mockPublisherProvider)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                let response = result.response
                let data = result.data

                XCTAssertEqual(response.url, URL(string: "https://www.instructure.com/logo.png"))
                XCTAssertEqual(data, Data(base64Encoded: "aGVsbG8=")!)
            })
            .store(in: &subscriptions)
    }

    func testFileSave() {
        let testee = HTMLDownloadInteractorLive(loginSession: environment.currentSession!, sectionName: testSectionName, scheduler: .main)

        let rootURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseSectionFolder(
                    sessionId: environment.currentSession!.uniqueID,
                    courseId: testCourseId,
                    sectionName: testSectionName
                )
            )
            .appendingPathComponent("\(testPrefix)-\(testResourceId)")
        let saveURL = rootURL.appendingPathComponent("logo.png")

        testee.save(testResponse, courseId: testCourseId, prefix: "\(testPrefix)-\(testResourceId)")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertTrue(FileManager.default.fileExists(atPath: saveURL.path))
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
            .appendingPathComponent("\(testPrefix)-\(testResourceId)")

        testee.saveBaseContent(content: "test", folderURL: rootURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertTrue(FileManager.default.fileExists(atPath: rootURL.appendingPathComponent("body.html").path))
            })
            .store(in: &subscriptions)
    }

    class URLSessionDataTaskPublisherProviderMock: URLSessionDataTaskPublisherProvider {
        let testResponse = (data: Data(base64Encoded: "aGVsbG8=")!,
                            response: URLResponse.init(
                                url: URL(string: "https://www.instructure.com/logo.png")!,
                                mimeType: nil,
                                expectedContentLength: 100,
                                textEncodingName: nil
                            ))

        func getPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
            return Just(testResponse)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
    }
}
