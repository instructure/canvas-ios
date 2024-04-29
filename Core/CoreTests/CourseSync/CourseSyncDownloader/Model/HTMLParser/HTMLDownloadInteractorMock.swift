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
import Foundation
import Combine

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
