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

public protocol HCourseSyncInteractor {
    var progressPublisher: AnyPublisher<HOfflineSyncProgress, Never> { get }
    var downloadItems: AnyPublisher<[OfflineCourseItem], Never> { get }
    var errorPublisher: AnyPublisher<Void, Never> { get }
    func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment)
    func cancelSync()
    func clear()
}

public final class HCourseSyncInteractorLive: HCourseSyncInteractor {
    // MARK: - Dependencies

    private let interactorFiles: HCourseSyncFilesInteractor
    private let modulesInteractor: HCourseSyncModulesInteractor
    private let notificationsInteractor: LocalNotificationsInteractor
    private let sessionManager: HOfflineSyncSessionManager

    // MARK: - Private state

    private let progressSubject = CurrentValueSubject<HOfflineSyncProgress, Never>(.zero)
    private let downloadItemsSubject = CurrentValueSubject<[OfflineCourseItem], Never>([])
    private let errorSubject = PassthroughSubject<Void, Never>()
    private var downloadSubscription: AnyCancellable?
    private var modulesFetchSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public

    public var progressPublisher: AnyPublisher<HOfflineSyncProgress, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    public var downloadItems: AnyPublisher<[OfflineCourseItem], Never> {
        downloadItemsSubject.eraseToAnyPublisher()
    }

    public var errorPublisher: AnyPublisher<Void, Never> {
        errorSubject.eraseToAnyPublisher()
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
        self.sessionManager = HOfflineSyncSessionManager(session: session, filesInteractor: interactorFiles)
    }

    public func clear() {
        cancelActiveDownloads()
        let offlineRoot = URL.Paths.Offline.rootURL(sessionID: sessionManager.sessionID)
        try? FileManager.default.removeItem(at: offlineRoot)
        sessionManager.clearSessionData()
        downloadItemsSubject.send([])
        progressSubject.send(.completed)
    }

    public func cancelSync() {
        let previouslySyncedPaths = Set(sessionManager.syncedItemPaths)
        let newSessionFiles = downloadItemsSubject.value
            .flatMap(\.files)
            .filter { file in
                file.isSelected
                    && !previouslySyncedPaths.contains(OfflineType.file(courseID: file.courseID, fileID: file.id).path())
            }
        cancelActiveDownloads()
        interactorFiles.deleteFiles(newSessionFiles, sessionID: sessionManager.sessionID)
        downloadItemsSubject.send([])
        progressSubject.send(.completed)
    }

    public func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment) {
        progressSubject.send(.zero)
        cancelActiveDownloads()
        downloadItemsSubject.send(courses.map { var c = $0; c.downloadState = .loading; return c })

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
        interactorFiles.cancelDownloads()
        downloadSubscription?.cancel()
        downloadSubscription = nil
        modulesFetchSubscription?.cancel()
        modulesFetchSubscription = nil
    }

    private func sendSuccessNotification(courses: [OfflineCourseItem]) {
        notificationsInteractor
            .sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: courses.count)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)
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
                    .map { _ in course.id }
            }
            .sink { [weak self] completedCourseID in
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

                var items = downloadItemsSubject.value
                if let index = items.firstIndex(where: { $0.id == completedCourseID }) {
                    items[index].downloadState = .downloaded
                }
                downloadItemsSubject.send(items)

                if isComplete {
                    sessionManager.finalizeSync(courses: courses)
                    sessionManager.appendSyncItems(courses.map { OfflineType.course(id: $0.id).path() })
                    sendSuccessNotification(courses: courses)
                }
            }
    }

    private func startFileDownload(courses: [OfflineCourseItem], files: [OfflineFileItem]) {
        downloadSubscription = interactorFiles
            .downloadFiles(files: files, sessionID: sessionManager.sessionID)
            .sink { [weak self] updatedFiles in
                guard let self else { return }
                let syncProgress = Self.makeProgress(from: updatedFiles)
                progressSubject.send(syncProgress)
                downloadItemsSubject.send(Self.updatedCourses(from: courses, applying: updatedFiles))
                if syncProgress.isComplete {
                    sessionManager.saveCompletedSync(courses: courses, files: updatedFiles)
                    sendCompletionNotification(items: updatedFiles, courses: courses)
                }
            }
    }

    private func sendCompletionNotification(items: [OfflineFileItem], courses: [OfflineCourseItem]) {
        let hasFailed = items.contains {
            switch $0.downloadState {
            case .failed: true
            default: false
            }
        }
        if hasFailed {
            errorSubject.send()
            notificationsInteractor
                .sendOfflineSyncFailedNotification()
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &subscriptions)
        } else {
            sessionManager.finalizeSync(courses: courses)
            sendSuccessNotification(courses: courses)
        }
    }

    // MARK: - Pure helpers (static)

    private static func updatedCourses(from courses: [OfflineCourseItem], applying files: [OfflineFileItem]) -> [OfflineCourseItem] {
        let filesByID = Dictionary(uniqueKeysWithValues: files.map { ($0.id, $0) })
        return courses.map { applyFileStates(to: $0, filesByID: filesByID) }
    }

    private static func applyFileStates(
        to course: OfflineCourseItem,
        filesByID: [String: OfflineFileItem]
    ) -> OfflineCourseItem {
        var updated = course
        updated.files = course.files.map { file in
            var updatedFile = file
            updatedFile.downloadState = filesByID[file.id]?.downloadState ?? file.downloadState
            return updatedFile
        }
        updated.downloadState = deriveCourseState(from: updated.files)
        return updated
    }

    private static func deriveCourseState(from files: [OfflineFileItem]) -> OfflineDownloadState {
        let selectedFiles = files.filter(\.isSelected)
        return selectedFiles.allSatisfy(\.downloadState.isTerminal) ? .downloaded : .loading
    }

    private static func makeProgress(from items: [OfflineFileItem]) -> HOfflineSyncProgress {
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
}
