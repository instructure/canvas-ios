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
    private let pagesInteractor: HCourseSyncPagesInteractor
    private let notificationsInteractor: LocalNotificationsInteractor
    private let sessionManager: HOfflineSyncSessionManager
    private let assignmentsInteractor: HCourseSyncAssignmentsInteractor
    private let syllabusInteractor: HCourseSyncSyllabusInteractor
    private let scoresInteractor: HCourseSyncScoresInteractor

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
        interactorFiles: HCourseSyncFilesInteractor,
        modulesInteractor: HCourseSyncModulesInteractor = HCourseSyncModulesInteractorLive(),
        pagesInteractor: HCourseSyncPagesInteractor,
        notificationsInteractor: LocalNotificationsInteractor = .init(),
        sessionManager: HOfflineSyncSessionManager,
        assignmentsInteractor: HCourseSyncAssignmentsInteractor,
        syllabusInteractor: HCourseSyncSyllabusInteractor,
        scoresInteractor: HCourseSyncScoresInteractor
    ) {
        self.interactorFiles = interactorFiles
        self.modulesInteractor = modulesInteractor
        self.pagesInteractor = pagesInteractor
        self.notificationsInteractor = notificationsInteractor
        self.sessionManager = sessionManager
        self.assignmentsInteractor = assignmentsInteractor
        self.syllabusInteractor = syllabusInteractor
        self.scoresInteractor = scoresInteractor
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
        let newSessionCourseIds = downloadItemsSubject.value
            .filter { !previouslySyncedPaths.contains(OfflineType.course(id: $0.id, enrollmentID: $0.enrollmentID).path()) }
        cancelActiveDownloads()
        interactorFiles.deleteFiles(newSessionFiles, sessionID: sessionManager.sessionID)
        sessionManager.deleteCourseFolder(courseIds: newSessionCourseIds.map(\.id), sessionID: sessionManager.sessionID)
        downloadItemsSubject.send([])
        progressSubject.send(.completed)
    }

    public func downloadContent(courses: [OfflineCourseItem], environment: AppEnvironment) {
        progressSubject.send(.zero)
        cancelActiveDownloads()
        downloadItemsSubject.send(courses.map { var c = $0; c.downloadState = .loading; return c })
        prefetchModules(courses: courses)
        startFileDownload(courses: courses)
        assignmentsInteractor.getContent(courseIds: courses.map(\.id), sessionID: sessionManager.sessionID)
            .sink()
            .store(in: &subscriptions)

        // Syllabus and scores are lightweight cache-only fetches; their completion is intentionally
        // not tracked in the progress/isComplete signal. cancelActiveDownloads() calls cancelRequests()
        // on each interactor, so they are cleaned up on cancel.
        syllabusInteractor.getContent(courseIDs: courses.map(\.id))
        scoresInteractor.getContent(courses: courses)
    }

    // MARK: - Private helpers

    private func cancelActiveDownloads() {
        interactorFiles.cancelDownloads()
        pagesInteractor.cancelDownloads()
        assignmentsInteractor.cancelDownloads()
        scoresInteractor.cancelRequests()
        syllabusInteractor.cancelRequests()
        downloadSubscription?.cancel()
        downloadSubscription = nil
        modulesFetchSubscription?.cancel()
        modulesFetchSubscription = nil
        subscriptions.removeAll()
    }

    private func sendSuccessNotification(courses: [OfflineCourseItem]) {
        notificationsInteractor
            .sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: courses.count)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)
    }

    private func prefetchPages(courses: [OfflineCourseItem]) -> AnyPublisher<HPageDownloadProgress, Never> {
        pagesInteractor.getPages(courseIds: courses.map(\.id))
            .replaceError(with: .zero)
            .eraseToAnyPublisher()
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

    private func startFileDownload(courses: [OfflineCourseItem]) {
        let files = courses.flatMap(\.selectedFiles)
        let fileSizes = files.map(\.sizeInBytes).reduce(0, +)
        if files.isNotEmpty {
            progressSubject.send(HOfflineSyncProgress(
                progress: .zero,
                downloadedSize: 0.humanReadableFileSize,
                totalSize: Int(fileSizes).humanReadableFileSize,
                isComplete: false
            ))
        }
        let filePublisher = interactorFiles.downloadFiles(courses: courses, sessionID: sessionManager.sessionID)
        let pagePublisher = prefetchPages(courses: courses).share()
        let attachmentPublisher = assignmentsInteractor.attachmentProgressPublisher

        downloadSubscription = filePublisher
            .combineLatest(pagePublisher, attachmentPublisher)
            .sink { [weak self] (fileProgress, pageProgress, attachmentProgress) in
                guard let self else { return }
                let totalSize = fileProgress.totalSize + Double(pageProgress.totalSize) + attachmentProgress.totalSize
                let downloadedSize = fileProgress.downloadedSize + Double(pageProgress.downloadedSize) + attachmentProgress.downloadedSize
                let pagesComplete = pageProgress.courseProgresses.allSatisfy { $0.state == .downloaded }
                let isComplete = fileProgress.isComplete && pagesComplete && attachmentProgress.isComplete

                let rawProgress: Double = isComplete ? 1.0 : (totalSize > 0 ? downloadedSize / totalSize : 0)
                progressSubject.send(HOfflineSyncProgress(
                    progress: rawProgress,
                    downloadedSize: Int(downloadedSize).humanReadableFileSize,
                    totalSize: Int(totalSize).humanReadableFileSize,
                    isComplete: isComplete
                ))
                var updatedCourses = Self.updatedCourses(
                    from: courses,
                    fileProgress: fileProgress,
                    pageProgress: pageProgress,
                    attachmentsComplete: attachmentProgress.isComplete
                )
                downloadItemsSubject.send(updatedCourses)

                if isComplete {
                    for file in attachmentProgress.downloadedFiles {
                        if let index = updatedCourses.firstIndex(where: { $0.id == file.courseID }) {
                            updatedCourses[index].appendFile(id: file.fileID, courseID: file.courseID)
                        }
                    }
                    sendCompletionNotification(items: fileProgress.files, courses: updatedCourses)
                    sessionManager.saveCompletedSync(courses: updatedCourses, files: fileProgress.files)
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

    private static func updatedCourses(
        from courses: [OfflineCourseItem],
        fileProgress: HFileDownloadProgress,
        pageProgress: HPageDownloadProgress,
        attachmentsComplete: Bool
    ) -> [OfflineCourseItem] {
        let filesByID = Dictionary(uniqueKeysWithValues: fileProgress.files.map { ($0.id, $0) })
        let fileStateByCourse = Dictionary(uniqueKeysWithValues: fileProgress.courseProgresses.map { ($0.courseID, $0.state) })
        let pageStateByCourse = Dictionary(uniqueKeysWithValues: pageProgress.courseProgresses.map { ($0.courseID, $0.state) })

        return courses.map { course in
            var updated = course
            updated.files = course.files.map { file in
                var updatedFile = file
                updatedFile.downloadState = filesByID[file.id]?.downloadState ?? file.downloadState
                return updatedFile
            }
            let filesDownloaded = fileStateByCourse[course.id].map { $0 == .downloaded } ?? true
            let pagesDownloaded = pageStateByCourse[course.id].map { $0 == .downloaded } ?? true
            updated.downloadState = (filesDownloaded && pagesDownloaded && attachmentsComplete) ? .downloaded : .loading
            return updated
        }
    }
}
