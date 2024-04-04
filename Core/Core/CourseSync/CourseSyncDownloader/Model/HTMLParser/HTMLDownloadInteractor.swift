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

import Foundation
import Combine
import CombineSchedulers

protocol HTMLDownloadInteractor {
    var sectionName: String { get }
    func download(_ url: URL, publisherProvider: URLSessionDataTaskPublisherProvider) -> AnyPublisher<(data: Data, response: URLResponse), Error>
    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error>
    func save(_ result: (data: Data, response: URLResponse), courseId: String, prefix: String) -> AnyPublisher<URL, Error>
    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error>
}

class HTMLDownloadInteractorLive: HTMLDownloadInteractor {
    private let loginSession: LoginSession
    private let scheduler: AnySchedulerOf<DispatchQueue>
    public let sectionName: String

    init(loginSession: LoginSession, sectionName: String, scheduler: AnySchedulerOf<DispatchQueue>) {
        self.loginSession = loginSession
        self.sectionName = sectionName
        self.scheduler = scheduler
    }

    func download(
        _ url: URL,
        publisherProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if url.baseURL == loginSession.baseURL {
            request.setValue("Authentication", forHTTPHeaderField: "Bearer \(loginSession.accessToken ?? "")")
        }

        return publisherProvider.getPublisher(for: request)
            .mapError { urlError -> Error in
                return urlError
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        return download(url, publisherProvider: URLSessionDataTaskPublisherProviderLive())
    }

    func save(_ result: (data: Data, response: URLResponse), courseId: String, prefix: String) -> AnyPublisher<URL, Error> {
        let rootURL = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: loginSession.uniqueID,
                courseId: courseId,
                sectionName: sectionName
            )
        ).appendingPathComponent(prefix)
        var saveURL = rootURL.appendingPathComponent(UUID.string)
        if let url = result.response.url {
            let fileName = url.lastPathComponent
            saveURL = rootURL.appendingPathComponent(fileName)
        }

        do {
            try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: saveURL.path, contents: result.data, attributes: nil)
            return Result.Publisher(saveURL).eraseToAnyPublisher()
        } catch {
            print("\(error)")
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image")))).eraseToAnyPublisher()
        }
    }

    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error> {
        let saveURL = folderURL.appendingPathComponent("body.html")
        do {
            try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: saveURL.path, contents: nil)
            try content.write(to: saveURL, atomically: true, encoding: .utf8)
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save base content")))).eraseToAnyPublisher()
        }
        return Result.Publisher(content).eraseToAnyPublisher()
    }
}
