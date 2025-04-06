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

import Combine
import CombineExt
import CoreData
import Foundation

public protocol CourseSyncFilesInteractor {
    func getFiles(
        courseId: String,
        useCache: Bool,
        environment: AppEnvironment
    ) -> AnyPublisher<[File], Error>
    func downloadFile(
        courseId: String,
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String,
        updatedAt: Date?,
        environment: AppEnvironment
    ) -> AnyPublisher<Float, Error>
    func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        environment: AppEnvironment
    ) -> AnyPublisher<Void, Error>
}

public final class CourseSyncFilesInteractorLive: CourseSyncFilesInteractor, LocalFileURLCreator {
    private let fileManager: FileManager
    private let offlineFileInteractor: OfflineFileInteractor

    public init(
        fileManager: FileManager = .default,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()
    ) {
        self.fileManager = fileManager
        self.offlineFileInteractor = offlineFileInteractor
    }

    /// Recursively looks up every file and folder under the specified `courseId` and returns a list of `File`.
    public func getFiles(
        courseId: String,
        useCache: Bool,
        environment: AppEnvironment
    ) -> AnyPublisher<[File], Error> {
        unowned let unownedSelf = self

        let store = ReactiveStore(
            useCase: GetFolderByPath(
                context: .course(courseId)
            ),
            environment: environment
        )
        let publisher = useCache ? store.getEntitiesFromDatabase() : store.getEntities(ignoreCache: true)

        return publisher
            .flatMap {
                Publishers.Sequence(sequence: $0)
                    .filter { !$0.lockedForUser && !$0.hiddenForUser }
                    .setFailureType(to: Error.self)
                    .flatMap { unownedSelf.getFiles(folderID: $0.id, initialArray: [], useCache: useCache, environment: environment) }
            }
            .map {
                $0
                    .compactMap { $0.file }
                    .filter { $0.url != nil && $0.mimeClass != nil }
            }
            .replaceEmpty(with: [])
            .eraseToAnyPublisher()
    }

    private func getFiles(
        folderID: String,
        initialArray: [FolderItem],
        useCache: Bool,
        environment: AppEnvironment
    ) -> AnyPublisher<[FolderItem], Error> {
        unowned let unownedSelf = self

        var result = initialArray

        return getFolderItems(folderID: folderID, useCache: useCache, environment: environment)
            .flatMap { files, folderIDs in
                result.append(contentsOf: files)

                guard folderIDs.count > 0 else {
                    return Just([result])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Publishers.Sequence(sequence: folderIDs)
                    .setFailureType(to: Error.self)
                    .flatMap(maxPublishers: .max(1)) {
                        unownedSelf.getFiles(
                            folderID: $0,
                            initialArray: result,
                            useCache: useCache,
                            environment: environment
                        )
                        .handleEvents(receiveOutput: { result = $0 })
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .first()
            .map { _ in result }
            .eraseToAnyPublisher()
    }

    private func getFolderItems(folderID: String, useCache: Bool, environment: AppEnvironment) -> AnyPublisher<([FolderItem], [String]), Error> {
        let store = ReactiveStore(
            useCase: GetFolderItems(
                folderID: folderID
            ),
            environment: environment
        )
        let publisher = useCache ? store.getEntitiesFromDatabase() : store.getEntities(ignoreCache: true)

        return publisher
            .tryCatch { error -> AnyPublisher<[FolderItem], Error> in
                if error.isForbidden {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    throw error
                }
            }
            .map {
                let files = $0
                    .filter {
                        if let file = $0.file {
                            return !file.lockedForUser && !file.hiddenForUser
                        } else {
                            return false
                        }
                    }
                let folderIDs = $0
                    .filter { $0.folder != nil }
                    .compactMap { $0.folder }
                    .filter { !$0.lockedForUser && !$0.hiddenForUser }
                    .map { $0.id }

                return (files, folderIDs)
            }
            .eraseToAnyPublisher()
    }

    public func downloadFile(
        courseId: String,
        url: URL,
        fileID: String,
        fileName: String,
        mimeClass: String,
        updatedAt: Date?,
        environment: AppEnvironment
    ) -> AnyPublisher<Float, Error> {
        guard let sessionID = environment.currentSession?.uniqueID else {
            return Fail(error:
                NSError.instructureError(
                    String(localized: "There was an unexpected error. Please try again.", bundle: .core)
                )
            )
            .eraseToAnyPublisher()
        }

        let localURL = prepareLocalURL(
            fileName: offlineFileInteractor.filePath(
                sessionID: sessionID,
                courseId: courseId,
                fileID: fileID,
                fileName: fileName
            ),
            mimeClass: mimeClass,
            location: URL.Directories.documents
        )

        if fileManager.fileExists(atPath: localURL.path), // File exists on the disk
           let fileModificationDate = fileManager.fileModificationDate(url: localURL),
           let updatedAt = updatedAt, // and
           fileModificationDate >= updatedAt { // is up to date
            return AnyPublisher<Float, Error>.create { subscriber in
                subscriber.send(1)
                subscriber.send(completion: .finished)

                return AnyCancellable {}
            }

        } else {
            return DownloadTaskPublisher(parameters:
                DownloadTaskParameters(
                    remoteURL: url,
                    localURL: localURL
                )
            )
            .eraseToAnyPublisher()
        }
    }

    public func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        environment: AppEnvironment
    ) -> AnyPublisher<Void, Error> {
        guard let sessionID = environment.currentSession?.uniqueID else {
            return Fail(error:
                NSError.instructureError(
                    String(localized: "There was an unexpected error. Please try again.", bundle: .core)
                )
            )
            .eraseToAnyPublisher()
        }

        let courseFolderURL = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseFolder(sessionID: sessionID, courseId: courseId)
        )
        let courseFileIDsArr: [String] = (try? fileManager.contentsOfDirectory(atPath: courseFolderURL.path)) ?? []
        let courseFileIDs = Set(courseFileIDsArr)
        let mappedNewFileIDs = newFileIDs.map { "file-\($0)" }

        let unavailableFileFolderURLs = courseFileIDs
            .subtracting(Set(mappedNewFileIDs))
            .map { courseFolderURL.appendingPathComponent($0) }

        unowned let unownedSelf = self

        return unavailableFileFolderURLs
            .publisher
            .tryMap { try unownedSelf.fileManager.removeItem(at: $0) }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
