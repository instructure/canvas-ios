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
    func download(_ url: URL, courseId: String, resourceId: String, publisherProvider: URLSessionDataTaskPublisherProvider) -> AnyPublisher<String, Error>
    func download(_ url: URL, courseId: String, resourceId: String) -> AnyPublisher<String, Error>
    func downloadFile(_ url: URL, courseId: String, resourceId: String) -> AnyPublisher<String, Error>
    func downloadFile(_ url: URL, courseId: String, resourceId: String, publisherProvider: URLSessionDataTaskPublisherProvider) -> AnyPublisher<String, Error>
    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error>
}

class HTMLDownloadInteractorLive: HTMLDownloadInteractor {
    public let sectionName: String
    private let loginSession: LoginSession?
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let fileManager: FileManager

    init(loginSession: LoginSession?, sectionName: String, scheduler: AnySchedulerOf<DispatchQueue>, fileManager: FileManager = .default) {
        self.loginSession = loginSession
        self.sectionName = sectionName
        self.scheduler = scheduler
        self.fileManager = fileManager
    }

    func downloadFile(
        _ url: URL,
        courseId: String,
        resourceId: String,
        publisherProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) -> AnyPublisher<String, Error> {
        let fileID = url.lastPathComponent
        var downloadURL = url
        if downloadURL.lastPathComponent != "download" {
            downloadURL = url.appendingPathComponent("download")
        }
        if let loginSession, let request = try? downloadURL.urlRequest(relativeTo: loginSession.baseURL, accessToken: loginSession.accessToken, actAsUserID: loginSession.actAsUserID) {
            return publisherProvider.getPublisher(for: request)
                .receive(on: scheduler)
                .flatMap { [weak self] (tempURL: URL, fileName: String) in
                    if let self {
                        return self.copyFile(tempURL, fileId: fileID, fileName: fileName, courseId: courseId, resourceId: resourceId)
                            .map { [sectionName] _ in
                                "\(loginSession.baseURL)/courses/\(courseId)/files/\(sectionName)/\(resourceId)/\(fileID)/offline"
                            }
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: NSError.instructureError(String(localized: "Failed to copy file", bundle: .core))).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError.instructureError(String(localized: "Failed to construct request", bundle: .core))).eraseToAnyPublisher()
        }
    }

    func downloadFile(_ url: URL, courseId: String, resourceId: String) -> AnyPublisher<String, Error> {
        return downloadFile(url, courseId: courseId, resourceId: resourceId, publisherProvider: URLSessionDataTaskPublisherProviderLive())
    }

    func download(
        _ url: URL,
        courseId: String,
        resourceId: String,
        publisherProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) -> AnyPublisher<String, Error> {
        if let loginSession, let request = try? url.urlRequest(relativeTo: loginSession.baseURL, accessToken: loginSession.accessToken, actAsUserID: loginSession.actAsUserID) {
            return publisherProvider.getPublisher(for: request)
                .receive(on: scheduler)
                .flatMap { [weak self] (tempURL: URL, fileName: String) in
                    return self?.copy(tempURL, fileName: fileName, courseId: courseId, resourceId: resourceId) ??
                    Fail(error: NSError.instructureError(String(localized: "Failed to copy file", bundle: .core))).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError.instructureError(String(localized: "Failed to construct request", bundle: .core))).eraseToAnyPublisher()
        }
    }

    func download(_ url: URL, courseId: String, resourceId: String) -> AnyPublisher<String, Error> {
        return download(url, courseId: courseId, resourceId: resourceId, publisherProvider: URLSessionDataTaskPublisherProviderLive())
    }

    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error> {
        let saveURL = folderURL.appendingPathComponent("body.html")
        do {
            try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: saveURL.path, contents: nil)
            try content.write(to: saveURL, atomically: true, encoding: .utf8)
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save base content", bundle: .core)))).eraseToAnyPublisher()
        }
        return Result.Publisher(content).eraseToAnyPublisher()
    }

    private func copy(_ tempURL: URL, fileName: String, courseId: String, resourceId: String) -> AnyPublisher<String, Error> {
        let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: loginSession?.uniqueID ?? "",
            courseId: courseId,
            sectionName: sectionName,
            resourceId: resourceId
        )

        let saveURL = rootURL.appendingPathComponent(fileName)

        do {
            try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.removeItem(at: saveURL)
            try fileManager.moveItem(at: tempURL, to: saveURL)
            return Result.Publisher(saveURL.path).eraseToAnyPublisher()
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image", bundle: .core)))).eraseToAnyPublisher()
        }
    }

    private func copyFile(_ tempURL: URL, fileId: String, fileName: String, courseId: String, resourceId: String) -> AnyPublisher<String, Error> {
        let rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: loginSession?.uniqueID ?? "",
            courseId: courseId,
            sectionName: sectionName,
            resourceId: resourceId
        ).appendingPathComponent("file-\(fileId)")

        let saveURL = rootURL.appendingPathComponent(fileName)

        do {
            try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.removeItem(at: saveURL)
            try fileManager.moveItem(at: tempURL, to: saveURL)
            return Result.Publisher(saveURL.path).eraseToAnyPublisher()
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image", bundle: .core)))).eraseToAnyPublisher()
        }
    }
}
