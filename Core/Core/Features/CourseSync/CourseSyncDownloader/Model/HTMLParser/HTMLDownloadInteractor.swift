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

    /// - returns: The path to the downloaded file, relative to the app's `Documents` directory.
    func download(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String,
        documentsDirectory: URL
    ) -> AnyPublisher<String, Error>

    /// - returns: A remote url of the file prefixed with `/offline` so when we route to this file from rich content the file presenter will know to look for the file locally.
    func downloadFile(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String
    ) -> AnyPublisher<String, Never>

    func saveBaseContent(
        content: String,
        folderURL: URL
    ) -> AnyPublisher<String, Error>
}

class HTMLDownloadInteractorLive: HTMLDownloadInteractor {
    public let sectionName: String
    //private let loginSession: LoginSession?
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let fileManager: FileManager
    private let downloadTaskProvider: URLSessionDataTaskPublisherProvider

    init(
        //loginSession: LoginSession?,
        sectionName: String,
        scheduler: AnySchedulerOf<DispatchQueue>,
        fileManager: FileManager = .default,
        downloadTaskProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) {
        //self.loginSession = loginSession
        self.sectionName = sectionName
        self.scheduler = scheduler
        self.fileManager = fileManager
        self.downloadTaskProvider = downloadTaskProvider
    }

    func downloadFile(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String
    ) -> AnyPublisher<String, Never> {
        let fileID = url.pathComponents[(url.pathComponents.firstIndex(of: "files") ?? 0) + 1]
        return Just(url)
            .setFailureType(to: Error.self)
            .flatMap { url in
                if url.pathComponents.contains("files") && !url.containsQueryItem(named: "verifier") {
                    let context = Context(url: url)
                    return ReactiveStore(
                        useCase: GetFile(context: context, fileID: fileID),
                        environment: courseId.env
                    )
                    .getEntities(ignoreCache: false)
                    .map { files in
                        return files.first?.url ?? url
                    }
                    .eraseToAnyPublisher()
                } else {
                    return Just(url).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .flatMap { [downloadTaskProvider, scheduler, fileManager, sectionName] url in
                guard
                    let loginSession = courseId.env.currentSession,
                    let request = try? url.urlRequest(relativeTo: loginSession.baseURL, accessToken: loginSession.accessToken, actAsUserID: loginSession.actAsUserID)
                else {
                    let error = NSError.instructureError(String(localized: "Failed to construct request", bundle: .core))
                    return Fail<String, any Error>(error: error).eraseToAnyPublisher()
                }

                return downloadTaskProvider
                    .getPublisher(for: request)
                    .receive(on: scheduler)
                    .flatMap { (tempURL: URL, fileName: String) in
                        return Self.copy(
                            tempURL,
                            fileId: fileID,
                            fileName: fileName,
                            courseId: courseId,
                            resourceId: resourceId,
                            fileManager: fileManager,
                            sectionName: sectionName
                        )
                        .map { [sectionName] _ in
                            "\(loginSession.baseURL)/courses/\(courseId)/files/\(sectionName)/\(resourceId)/\(fileID)/offline"
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }

    func download(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String,
        documentsDirectory: URL
    ) -> AnyPublisher<String, Error> {
        guard
            let loginSession = courseId.env.currentSession,
            let request = try? url.urlRequest(relativeTo: loginSession.baseURL, accessToken: loginSession.accessToken, actAsUserID: loginSession.actAsUserID)
        else {
            return Fail(error: NSError.instructureError(String(localized: "Failed to construct request", bundle: .core))).eraseToAnyPublisher()
        }
        return downloadTaskProvider
            .getPublisher(for: request)
            .receive(on: scheduler)
            .flatMap { [fileManager, sectionName] (tempURL: URL, fileName: String) in
                return Self.copy(
                    tempURL,
                    fileId: nil,
                    fileName: fileName,
                    courseId: courseId,
                    resourceId: resourceId,
                    fileManager: fileManager,
                    sectionName: sectionName
                )
                .map { fileUrl in
                    fileUrl.replacing(documentsDirectory.path(), with: "")
                }
            }
            .eraseToAnyPublisher()
    }

    func saveBaseContent(content: String, folderURL: URL) -> AnyPublisher<String, Error> {
        let saveURL = folderURL.appendingPathComponent("body.html")

        print()
        print("Saved Content:")
        print(saveURL)

        do {
            try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: saveURL.path, contents: nil)
            try content.write(to: saveURL, atomically: true, encoding: .utf8)
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save base content", bundle: .core)))).eraseToAnyPublisher()
        }
        return Result.Publisher(content).eraseToAnyPublisher()
    }

    /// - returns: The absolute URL of the local file inside the Offline folder.
    private static func copy(
        _ tempURL: URL,
        fileId: String?,
        fileName: String,
        courseId: CourseSyncID,
        resourceId: String,
        fileManager: FileManager,
        sectionName: String
    ) -> AnyPublisher<String, Error> {
        var rootURL = URL.Paths.Offline.courseSectionResourceFolderURL(
            sessionId: courseId.env.currentSession?.uniqueID ?? "",
            courseId: courseId.value,
            sectionName: sectionName,
            resourceId: resourceId
        )

        if let fileId {
            rootURL.append(path: "file-\(fileId)", directoryHint: .isDirectory)
        }

        let saveURL = rootURL.appendingPathComponent(fileName)

        do {
            try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
            try? fileManager.removeItem(at: saveURL)
            try fileManager.moveItem(at: tempURL, to: saveURL)
            return Result.Publisher(saveURL.path).eraseToAnyPublisher()
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image", bundle: .core)))).eraseToAnyPublisher()
        }
    }
}
