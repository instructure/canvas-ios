//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Combine
import Foundation

protocol HCourseSyncFilesInteractor {
    func downloadFiles(
        files: [OfflineFileItem],
        sessionID: String
    ) -> AnyPublisher<[OfflineFileItem], Never>

     func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        sessionID: String
    ) -> AnyPublisher<Void, Error>
}

final class HCourseSyncFilesInteractorLive: HCourseSyncFilesInteractor, LocalFileURLCreator {
    // MARK: - Dependencies

    private let offlineFileInteractor: OfflineFileInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let fileManager: FileManager

    // MARK: - Init

    init(
        fileManager: FileManager = .default,
        offlineFileInteractor: OfflineFileInteractor =  OfflineFileInteractorLive()
    ) {
        self.offlineFileInteractor = offlineFileInteractor
        self.fileManager = fileManager
    }

    func downloadFiles(
        files: [OfflineFileItem],
        sessionID: String
    ) -> AnyPublisher<[OfflineFileItem], Never> {

        let subject = CurrentValueSubject<[OfflineFileItem], Never>(files)

        files.enumerated().publisher
            .flatMap(maxPublishers: .max(6)) { [weak self] index, file -> AnyPublisher<(Int, OfflineDownloadState), Never> in

                guard let self = self else {
                    return Just((index, .failed(String(localized: "There was an unexpected error. Please try again.", bundle: .horizon))))
                        .eraseToAnyPublisher()
                }

                return self.downloadSingleFile(file: file, sessionID: sessionID)
                    .map { progress -> (Int, OfflineDownloadState) in
                        progress >= 1
                        ? (index, .downloaded)
                        : (index, .downloading(progress: progress))
                    }
                    .prepend((index, .loading))
                    .catch { error in
                        Just((index, .failed(error.localizedDescription)))
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { index, state in
                var current = subject.value
                guard current.indices.contains(index) else { return }

                current[index].downloadState = state
                subject.send(current)
            }
            .store(in: &subscriptions)
        return subject.eraseToAnyPublisher()
    }

    public func downloadSingleFile(
        file: OfflineFileItem,
        sessionID: String
    ) -> AnyPublisher<Float, Error> {
        let localURL = prepareLocalURL(
            fileName: offlineFileInteractor.filePath(
                sessionID: sessionID,
                courseId: file.courseID,
                fileID: file.id,
                fileName: file.name
            ),
            mimeClass: file.mimeClass,
            location: URL.Directories.documents
        )

        return ReactiveStore(useCase: GetFile(context: .course(file.courseID), fileID: file.id))
            .getEntities()
            .tryMap { files -> URL in
                guard let file = files.first,
                      let remoteURL = file.url else {
                    throw NSError.instructureError("Invalid file data")
                }
                return remoteURL
            }
            .flatMap { remoteURL -> AnyPublisher<Float, Error> in
                return DownloadTaskPublisher(
                    parameters: DownloadTaskParameters(
                        remoteURL: remoteURL,
                        localURL: localURL
                    )
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

     func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        sessionID: String
    ) -> AnyPublisher<Void, Error> {
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
