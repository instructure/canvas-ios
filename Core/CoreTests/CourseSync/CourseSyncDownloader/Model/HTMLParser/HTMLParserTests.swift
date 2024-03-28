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

    func testReplaceingLinks() {
        let interactor = HTMLDownloadInteractorMock()
        testee = HTMLParser(loginSession: environment.currentSession!, downloadInteractor: interactor)

        let urlToDownload = "https://instructure.com/logo.png"
        let testHTMLContent: String = """
            <h1>Hello world!</h1>
        Some random content
        <p>paragraph test</p>
        <img src="\(urlToDownload)">
        """

        testee.parse(testHTMLContent, resourceId: testResourceId, courseId: testCourseId)
            .sink(receiveCompletion: { _ in }, receiveValue: { result in
                let isURLDownloaded = interactor.urls[URL(string: urlToDownload)!]
                XCTAssertNotNil(isURLDownloaded)
                XCTAssertTrue(isURLDownloaded!)

                XCTAssertFalse(result.contains(urlToDownload))
                XCTAssertTrue(result.contains(URL.Directories.documents.appendingPathComponent("local-0").lastPathComponent))
            })
            .store(in: &subscriptions)
    }
}

class HTMLDownloadInteractorMock: HTMLDownloadInteractor {
    var sectionName: String = "MockSectionName"
    var urls: [URL: Bool] = [:]
    private var counter: Int = 0

    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        urls[url] = false

        return Just((data: Data(), response: .init(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func save(_ result: (data: Data, response: URLResponse), courseId: String, prefix: String) -> AnyPublisher<URL, Error> {
        var localURL = URL.Directories.documents.appendingPathComponent("local-\(counter)")
        counter += 1
        if let url = result.response.url {
            urls[url] = true
        }
        return Just(localURL)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
