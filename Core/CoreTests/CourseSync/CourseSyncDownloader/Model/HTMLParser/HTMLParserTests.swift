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
    var subscriptions: [AnyCancellable] = []

    func testReplacingLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://instructure.com")
        let urlToDownload = URL(string: "https://instructure.com/logo.png")!
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload.absoluteString)">
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                let isURLDownloaded = interactor.fileNames[urlToDownload.lastPathComponent]
                XCTAssertNotNil(isURLDownloaded)
                XCTAssertTrue(isURLDownloaded!)

                XCTAssertFalse(result.contains("https://instructure.com/logo.png"))
                XCTAssertTrue(result.contains(URL.Directories.documents.appendingPathComponent(urlToDownload.lastPathComponent).lastPathComponent))
            })
            .store(in: &subscriptions)
    }

    func testReplacingRelativeLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

        let baseURL = URL(string: "https://www.instructure.com")!
        let urlToDownload = "https://www.instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        some simple text
        <a href="/some_image.png">Relative test</a>
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId, baseURL: baseURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                XCTAssertFalse(result.contains("<a href=\"/some_image.png\">Relative test</a>"))
                XCTAssertTrue(result.contains("<a href=\"https://www.instructure.com/some_image.png\">Relative test</a>"))
            })
            .store(in: &subscriptions)
    }

    func testSavingBaseContent() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParserLive(sessionId: environment.currentSession!.uniqueID, downloadInteractor: interactor)

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
            .appendingPathComponent("\(interactor.sectionName)-\(testResourceId)")

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
    var fileNames: [String: Bool] = [:]
    private var counter: Int = 0
    var savedBaseContents: [URL] = []

    func download(_ url: URL, publisherProvider: Core.URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
        fileNames[url.lastPathComponent] = false

        return Just((tempURL: url, fileName: url.lastPathComponent))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func download(_ url: URL) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
        download(url, publisherProvider: URLSessionDataTaskPublisherProviderLive())
    }

    func copy(_ localURL: URL, fileName: String, courseId: String, resourceId: String) -> AnyPublisher<URL, Error> {
        let saveURL = URL.Directories.documents.appendingPathComponent(fileName)
        counter += 1
        fileNames[localURL.lastPathComponent] = true

        return Just(saveURL)
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
