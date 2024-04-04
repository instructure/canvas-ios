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

class HTMLParserTests: CoreTestCase {
    var testee: HTMLParser!
    let testCourseId: String = "1"
    let testResourceId: String = "2"
    let testPrefix: String = "test"
    var subscriptions: [AnyCancellable] = []

    func testReplacingLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(loginSession: environment.currentSession!, downloadInteractor: interactor, prefix: testPrefix)

        let baseURL = URL(string: "https://instructure.com")
        let urlToDownload = "https://instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                let isURLDownloaded = interactor.urls[URL(string: urlToDownload)!]
                XCTAssertNotNil(isURLDownloaded)
                XCTAssertTrue(isURLDownloaded!)

                XCTAssertFalse(result.contains(urlToDownload))
                XCTAssertTrue(result.contains(URL.Directories.documents.appendingPathComponent("local-0").lastPathComponent))
            })
            .store(in: &subscriptions)
    }

    func testReplacingRelativeLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(loginSession: environment.currentSession!, downloadInteractor: interactor)

        let baseURL = URL(string: "https://www.instructure.com")!
        let urlToDownload = "https://www.instructure.com/logo.png"
        let relativeURL = """
<a href="/some_image.png">
"""
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        some simple text
        <a href="\(relativeURL)">Relative test</a>
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                XCTAssertFalse(result.contains("<a href=\"\(relativeURL)\">Relative test</a>"))
                XCTAssertTrue(result.contains("<a href=\"\(baseURL)\(relativeURL)\">Relative test</a>"))
            })
            .store(in: &subscriptions)
    }

    func testSavingBaseContent() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(loginSession: environment.currentSession!, downloadInteractor: interactor, prefix: "test")

        let baseURL = URL(string: "https://www.instructure.com")
        let urlToDownload = "https://www.instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        """

        let rootURL = URL.Directories.documents.appendingPathComponent(
                URL.Paths.Offline.courseSectionFolder(
                    sessionId: environment.currentSession!.uniqueID,
                    courseId: testCourseId,
                    sectionName: interactor.sectionName
                )
            )
            .appendingPathComponent("\(testPrefix)-\(testResourceId)")

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                XCTAssertEqual(interactor.savedBaseContents.count, 1)
                XCTAssertEqual(interactor.savedBaseContents.first!, rootURL)
            })
            .store(in: &subscriptions)
    }
}

class HTMLDownloadInteractorMock: HTMLDownloadInteractor {

    var sectionName: String = "MockSectionName"
    var urls: [URL: Bool] = [:]
    private var counter: Int = 0
    var savedBaseContents: [URL] = []

    func download(_ url: URL, publisherProvider: Core.URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        urls[url] = false

        return Just((data: Data(), response: .init(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        download(url, publisherProvider: URLSessionDataTaskPublisherProviderLive())
    }

    func save(_ result: (data: Data, response: URLResponse), courseId: String, prefix: String) -> AnyPublisher<URL, Error> {
        let localURL = URL.Directories.documents.appendingPathComponent("local-\(counter)")
        counter += 1
        if let url = result.response.url {
            urls[url] = true
        }
        return Just(localURL)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error> {
        savedBaseContents.append(folderURL)
        return Just(content)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
