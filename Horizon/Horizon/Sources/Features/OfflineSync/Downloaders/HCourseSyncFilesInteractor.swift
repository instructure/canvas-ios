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

struct HCourseFileProgress {
    let courseID: String
    let state: HSyncCourseState
    let totalSize: Double
    let downloadedSize: Double
}

struct HFileDownloadProgress {
    let courseProgresses: [HCourseFileProgress]
    let files: [OfflineFileItem]

    var totalSize: Double { courseProgresses.reduce(0) { $0 + $1.totalSize } }
    var downloadedSize: Double { courseProgresses.reduce(0) { $0 + $1.downloadedSize } }

    var isComplete: Bool {
        files.filter(\.isSelected).allSatisfy(\.downloadState.isTerminal)
    }

    static let zero = HFileDownloadProgress(courseProgresses: [], files: [])
}

protocol HCourseSyncFilesInteractor {
    func downloadFiles(
        courses: [OfflineCourseItem],
        sessionID: String
    ) -> AnyPublisher<HFileDownloadProgress, Never>

    func cancelDownloads()
    func deleteFiles(_ files: [OfflineFileItem], sessionID: String)

    func removeUnavailableFiles(
        courseId: String,
        newFileIDs: [String],
        sessionID: String
    ) -> AnyPublisher<Void, Error>
    func download(file: File, courseID: String, sessionID: String) -> AnyPublisher<Float, Error>
}

final class HCourseSyncFilesInteractorLive: HCourseSyncFilesInteractor, LocalFileURLCreator {
    // MARK: - Dependencies

    private let offlineFileInteractor: OfflineFileInteractor
    private var subscriptions = Set<AnyCancellable>()
    private let fileManager: FileManager

    // MARK: - Init

    init(
        fileManager: FileManager = .default,
        offlineFileInteractor: OfflineFileInteractor = OfflineFileInteractorLive()
    ) {
        self.offlineFileInteractor = offlineFileInteractor
        self.fileManager = fileManager
    }

    func cancelDownloads() {
        subscriptions.removeAll()
    }

    func deleteFiles(_ files: [OfflineFileItem], sessionID: String) {
        files.forEach { file in
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
            try? fileManager.removeItem(at: localURL.deletingLastPathComponent())
        }
    }

    func downloadFiles(
        courses: [OfflineCourseItem],
        sessionID: String
    ) -> AnyPublisher<HFileDownloadProgress, Never> {
        let files = courses.flatMap(\.selectedFiles)

        guard !files.isEmpty else {
            return Just(.zero).eraseToAnyPublisher()
        }

        let subject = CurrentValueSubject<[OfflineFileItem], Never>(files)

        files.enumerated().publisher
            .flatMap(maxPublishers: .max(6)) { [weak self] index, file in
                self?.fileDownloadPublisher(index: index, file: file, sessionID: sessionID)
                    ?? Just((index, .failed(String(localized: "There was an unexpected error. Please try again.", bundle: .horizon))))
                        .eraseToAnyPublisher()
            }
            .sink { index, state in
                var current = subject.value
                guard current.indices.contains(index) else { return }
                current[index].downloadState = state
                subject.send(current)
            }
            .store(in: &subscriptions)

        return subject
            .map { [weak self] files in self?.makeProgress(from: files) ?? .zero }
            .eraseToAnyPublisher()
    }

    private func fileDownloadPublisher(
        index: Int,
        file: OfflineFileItem,
        sessionID: String
    ) -> AnyPublisher<(Int, OfflineDownloadState), Never> {
        downloadSingleFile(file: file, sessionID: sessionID)
            .map { progress -> (Int, OfflineDownloadState) in
                progress >= 1
                    ? (index, .downloaded)
                    : (index, .downloading(progress: progress))
            }
            .prepend((index, .loading))
            .catch { error in Just((index, .failed(error.localizedDescription))) }
            .eraseToAnyPublisher()
    }

    private func makeProgress(from files: [OfflineFileItem]) -> HFileDownloadProgress {
        let selectedFiles = files.filter(\.isSelected)
        let filesByCourse = Dictionary(grouping: selectedFiles, by: \.courseID)
        let courseProgresses = filesByCourse.map { courseID, courseFiles in
            makeCourseProgress(courseID: courseID, files: courseFiles)
        }
        return HFileDownloadProgress(courseProgresses: courseProgresses, files: files)
    }

    private func makeCourseProgress(courseID: String, files: [OfflineFileItem]) -> HCourseFileProgress {
        let totalSize = files.reduce(0.0) { $0 + $1.sizeInBytes }
        let downloadedSize = files.reduce(0.0) { sum, file in
            switch file.downloadState {
            case .downloaded: return sum + file.sizeInBytes
            case .downloading(let p): return sum + file.sizeInBytes * Double(p)
            default: return sum
            }
        }
        let state: HSyncCourseState = files.allSatisfy(\.downloadState.isTerminal) ? .downloaded : .downloading
        return HCourseFileProgress(
            courseID: courseID,
            state: state,
            totalSize: totalSize,
            downloadedSize: downloadedSize
        )
    }

    private func downloadSingleFile(
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

        if fileManager.fileExists(atPath: localURL.path),
           let fileModificationDate = fileManager.fileModificationDate(url: localURL),
           let updatedAt = file.updatedAt,
           fileModificationDate >= updatedAt {
            return AnyPublisher<Float, Error>.create { subscriber in
                subscriber.send(1)
                subscriber.send(completion: .finished)
                return AnyCancellable {}
            }
        } else {
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

        return unavailableFileFolderURLs
            .publisher
            .tryMap { [unowned self] in try self.fileManager.removeItem(at: $0) }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func download(file: File, courseID: String, sessionID: String) -> AnyPublisher<Float, Error> {
        guard let url = file.url else {
            return Just(0).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let localURL = prepareLocalURL(
            fileName: offlineFileInteractor.filePath(
                sessionID: sessionID,
                courseId: courseID,
                fileID: file.id ?? "",
                fileName: file.displayName ?? ""
            ),
            mimeClass: file.mimeClass ?? "",
            location: URL.Directories.documents
        )
        if self.fileManager.fileExists(atPath: localURL.path) {
            return Just(Float(1))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
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
}
