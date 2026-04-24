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

// MARK: - Progress Model

public struct HOfflineSyncProgress {
    let progress: Double
    let downloadedSize: String
    let totalSize: String
    let isComplete: Bool
}

// MARK: - Protocol

public protocol HCourseSyncInteractor {
    var progressPublisher: AnyPublisher<HOfflineSyncProgress, Never> { get }
    func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment)
    func clear()
}

// MARK: - Live Implementation

public final class HCourseSyncInteractorLive: HCourseSyncInteractor {
    // MARK: - Dependencies

    private let interactorFiles: HCourseSyncFilesInteractor
    private let modulesInteractor: HCourseSyncModulesInteractor
    private let notificationsInteractor: LocalNotificationsInteractor
    private var session: SessionDefaults
    // MARK: - Private state

    private let progressSubject = CurrentValueSubject<HOfflineSyncProgress, Never>(
        HOfflineSyncProgress(progress: 0, downloadedSize: "", totalSize: "", isComplete: false)
    )
    private var downloadSubscription: AnyCancellable?
    private var modulesFetchSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public

    public var progressPublisher: AnyPublisher<HOfflineSyncProgress, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    init(
        interactorFiles: HCourseSyncFilesInteractor = HCourseSyncFilesInteractorLive(),
        modulesInteractor: HCourseSyncModulesInteractor = HCourseSyncModulesInteractorLive(),
        notificationsInteractor: LocalNotificationsInteractor = .init(),
        session: SessionDefaults
    ) {
        self.interactorFiles = interactorFiles
        self.modulesInteractor = modulesInteractor
        self.notificationsInteractor = notificationsInteractor
        self.session = session
    }

    public func clear() {
        cancelActiveDownloads()
        let sessionID = session.sessionID
        let offlineRoot = URL.Paths.Offline.rootURL(sessionID: sessionID)
        try? FileManager.default.removeItem(at: offlineRoot)
        session.horizonOfflineSyncItems = []
        session.horizonOfflineSyncFileMetadata = [:]
    }

    public func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment) {
        cancelActiveDownloads()
        removeDeselectedCourseFolders(courses: courses)
        updateFileMetadata(courses: courses)
        removeUnavailableFiles(courses: courses, environment: environment)
        session.horizonOfflineSyncItems = []

        let files = courses.flatMap(\.selectedFiles)
        if files.isEmpty {
            startNoFilesProgress(courses: courses)
        } else {
            prefetchModules(courses: courses)
            startFileDownload(courses: courses, files: files)
        }
    }

    // MARK: - Private helpers

    private func cancelActiveDownloads() {
        downloadSubscription?.cancel()
        modulesFetchSubscription?.cancel()
    }

    private func removeDeselectedCourseFolders(courses: [OfflineCourseItem]) {
        let sessionID = session.sessionID
        let newCourseIDs = Set(courses.map(\.id))
        session.horizonOfflineSyncItems
            .compactMap { OfflineType.parse(path: $0) }
            .compactMap { if case .course(let id) = $0 { return id } else { return nil } }
            .filter { !newCourseIDs.contains($0) }
            .forEach { courseID in
                let folderURL = URL.Directories.documents.appendingPathComponent(
                    URL.Paths.Offline.courseFolder(sessionID: sessionID, courseId: courseID)
                )
                try? FileManager.default.removeItem(at: folderURL)
            }
    }

    private func updateFileMetadata(courses: [OfflineCourseItem]) {
        var metadata = session.horizonOfflineSyncFileMetadata
        courses.flatMap(\.selectedFiles).forEach { file in
            metadata[file.id] = file.toDic()
        }
        session.horizonOfflineSyncFileMetadata = metadata
    }

    private func removeUnavailableFiles(courses: [OfflineCourseItem], environment: AppEnvironment) {
        courses.forEach { course in
            interactorFiles
                .removeUnavailableFiles(
                    courseId: course.id,
                    newFileIDs: course.selectedFiles.map(\.id),
                    sessionID: session.sessionID
                )
                .sink()
                .store(in: &subscriptions)
        }
    }

    private func prefetchModules(courses: [OfflineCourseItem]) {
        modulesFetchSubscription = courses.publisher
            .flatMap { [modulesInteractor] course in
                modulesInteractor.getModuleItems(courseId: course.id)
                    .replaceError(with: [])
                    .first()
            }
            .sink()
    }

    private func startNoFilesProgress(courses: [OfflineCourseItem]) {
        guard !courses.isEmpty else { return }

        let total = courses.count
        var completedCount = 0

        modulesFetchSubscription = courses.publisher
            .flatMap { [modulesInteractor] course in
                modulesInteractor.getModuleItems(courseId: course.id)
                    .replaceError(with: [])
                    .first()
            }
            .sink { [weak self] _ in
                guard let self else { return }
                completedCount += 1
                let progress = Double(completedCount) / Double(total)
                let isComplete = completedCount == total
                progressSubject.send(HOfflineSyncProgress(
                    progress: progress,
                    downloadedSize: "",
                    totalSize: "",
                    isComplete: isComplete
                ))
                if isComplete {
                    appendSyncItems(courses.map { OfflineType.course(id: $0.id).path() })
                    notificationsInteractor
                        .sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: courses.count)
                        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        .store(in: &subscriptions)
                }
            }
    }

    private func startFileDownload(courses: [OfflineCourseItem], files: [OfflineFileItem]) {
        downloadSubscription = interactorFiles
            .downloadFiles(files: files, sessionID: session.sessionID)
            .sink { [weak self] items in
                guard let self else { return }
                let syncProgress = makeProgress(from: items)
                progressSubject.send(syncProgress)
                if syncProgress.isComplete {
                    saveCompletedSync(courses: courses, files: items)
                    sendCompletionNotification(items: items, coursesCount: courses.count)
                }
            }
    }

    private func saveCompletedSync(courses: [OfflineCourseItem], files: [OfflineFileItem]) {
        let coursePaths = courses.map { OfflineType.course(id: $0.id).path() }
        let filePaths = files
            .filter { $0.downloadState == .downloaded }
            .map { OfflineType.file(courseID: $0.courseID, fileID: $0.id).path() }
        appendSyncItems(coursePaths + filePaths)
    }

    private func appendSyncItems(_ newItems: [String]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            session.horizonOfflineSyncItems += newItems
        }
    }

    private func makeProgress(from items: [OfflineFileItem]) -> HOfflineSyncProgress {
        let total = items.reduce(0) { $0 + $1.sizeInBytes }
        let downloaded = items.reduce(0.0) { sum, item in
            switch item.downloadState {
            case .downloaded:
                return sum + item.sizeInBytes
            case .downloading(let progress):
                return sum + item.sizeInBytes * Double(progress)
            default:
                return sum
            }
        }
        return HOfflineSyncProgress(
            progress: total > 0 ? downloaded / total : 0,
            downloadedSize: Int(downloaded).humanReadableFileSize,
            totalSize: Int(total).humanReadableFileSize,
            isComplete: items.allSatisfy(\.downloadState.isTerminal)
        )
    }

    private func sendCompletionNotification(items: [OfflineFileItem], coursesCount: Int) {
        let hasFailed = items.contains {
            switch $0.downloadState {
            case .failed: true
            default: false
            }
        }
        if hasFailed {
            notificationsInteractor
                .sendOfflineSyncFailedNotification()
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &subscriptions)
        } else {
            notificationsInteractor
                .sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: coursesCount)
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &subscriptions)
        }
    }
}
