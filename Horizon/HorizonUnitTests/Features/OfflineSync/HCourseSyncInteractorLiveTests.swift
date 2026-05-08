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

@testable import Core
@testable import Horizon
import Combine
import XCTest
import TestsFoundation

final class HCourseSyncInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        sessionID: "session 1",
        courseID1: "course 1",
        courseID2: "course 2",
        fileID1: "file 1",
        fileID2: "file 2"
    )
    private lazy var testData = Self.testData

    private var filesInteractor: HCourseSyncFilesInteractorMock!
    private var modulesInteractor: HCourseSyncModulesInteractorMock!
    private var pagesInteractor: HCourseSyncPagesInteractorMock!
    private var notificationCenter: MockUserNotificationCenter!
    private var sessionManager: HOfflineSyncSessionManagerMock!
    private var testee: HCourseSyncInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        filesInteractor = HCourseSyncFilesInteractorMock()
        modulesInteractor = HCourseSyncModulesInteractorMock()
        pagesInteractor = HCourseSyncPagesInteractorMock()
        notificationCenter = MockUserNotificationCenter()
        sessionManager = HOfflineSyncSessionManagerMock(sessionID: testData.sessionID)
        testee = makeInteractor()
    }

    override func tearDown() {
        testee = nil
        filesInteractor = nil
        modulesInteractor = nil
        pagesInteractor = nil
        notificationCenter = nil
        sessionManager = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - progressPublisher

    func test_progressPublisher_initialValue_shouldHaveZeroProgressAndNotBeComplete() {
        var received: [HOfflineSyncProgress] = []
        testee.progressPublisher.sink { received.append($0) }.store(in: &subscriptions)

        XCTAssertEqual(received.first?.progress, 0)
        XCTAssertEqual(received.first?.isComplete, false)
    }

    // MARK: - clear

    func test_clear_shouldCallClearSessionData() {
        testee.clear()

        XCTAssertEqual(sessionManager.clearSessionDataCalled, true)
    }

    func test_clear_shouldEmitEmptyDownloadItems() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        testee.downloadContent(courses: [course], environment: environment)
        var received: [[OfflineCourseItem]] = []
        testee.downloadItems.sink { received.append($0) }.store(in: &subscriptions)

        testee.clear()

        XCTAssertEqual(received.last?.isEmpty, true)
    }

    func test_clear_shouldEmitCompletedProgress() {
        var received: [HOfflineSyncProgress] = []
        testee.progressPublisher.sink { received.append($0) }.store(in: &subscriptions)

        testee.clear()

        XCTAssertEqual(received.last?.isComplete, true)
    }

    // MARK: - cancelSync

    func test_cancelSync_shouldEmitEmptyDownloadItems() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        testee.downloadContent(courses: [course], environment: environment)
        var received: [[OfflineCourseItem]] = []
        testee.downloadItems.sink { received.append($0) }.store(in: &subscriptions)

        testee.cancelSync()

        XCTAssertEqual(received.last?.isEmpty, true)
    }

    func test_cancelSync_shouldEmitCompletedProgress() {
        var received: [HOfflineSyncProgress] = []
        testee.progressPublisher.sink { received.append($0) }.store(in: &subscriptions)

        testee.cancelSync()

        XCTAssertEqual(received.last?.isComplete, true)
    }

    func test_cancelSync_shouldDeleteNewlySelectedFiles() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        testee.downloadContent(courses: [course], environment: environment)

        testee.cancelSync()

        XCTAssertEqual(filesInteractor.deletedFiles.map(\.id), [testData.fileID1])
        XCTAssertEqual(filesInteractor.deletedSessionID, testData.sessionID)
    }

    func test_cancelSync_shouldNotDeleteAlreadySyncedFiles() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        testee.downloadContent(courses: [course], environment: environment)
        sessionManager.syncedItemPaths = [OfflineType.file(courseID: testData.courseID1, fileID: testData.fileID1).path()]

        testee.cancelSync()

        XCTAssertEqual(filesInteractor.deletedFiles.isEmpty, true)
    }

    func test_cancelSync_shouldCallDeletePagesForDownloadingCourses() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        testee.downloadContent(courses: [course], environment: environment)

        testee.cancelSync()

        XCTAssertEqual(pagesInteractor.deletedCourseIDs.contains(testData.courseID1), true)
        XCTAssertEqual(pagesInteractor.deletedSessionID, testData.sessionID)
    }

    func test_cancelSync_shouldNotDeleteAlreadySyncedPages() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        testee.downloadContent(courses: [course], environment: environment)
        sessionManager.syncedItemPaths = [OfflineType.course(id: testData.courseID1).path()]

        testee.cancelSync()

        XCTAssertEqual(pagesInteractor.deletedCourseIDs.contains(testData.courseID1), false)
    }

    // MARK: - downloadItems

    func test_downloadContent_shouldSetLoadingStateOnCourses() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var received: [[OfflineCourseItem]] = []
        testee.downloadItems.sink { received.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(received.last?.first?.downloadState, .loading)
    }

    func test_downloadContent_withFilesDownloading_shouldUpdateFileStateInDownloadItems() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var received: [[OfflineCourseItem]] = []
        testee.downloadItems.sink { received.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)
        var downloadingFile = file
        downloadingFile.downloadState = .downloading(progress: 0.5)
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadingFile]))

        XCTAssertEqual(received.last?.first?.files.first?.downloadState, .downloading(progress: 0.5))
    }

    func test_downloadContent_withAllFilesDownloaded_shouldUpdateCourseDownloadStateToDownloaded() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var received: [[OfflineCourseItem]] = []
        testee.downloadItems.sink { received.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)
        var downloadedFile = file
        downloadedFile.downloadState = .downloaded
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadedFile]))

        XCTAssertEqual(received.last?.first?.downloadState, .downloaded)
    }

    // MARK: - downloadContent progress

    func test_downloadContent_withCourseOnlySelection_shouldEmitProgressWithFullCompletion() {
        let course1 = makeCourse(id: testData.courseID1, isSelected: true)
        let course2 = makeCourse(id: testData.courseID2, isSelected: true)
        var progressValues: [HOfflineSyncProgress] = []
        testee.progressPublisher.dropFirst().sink { progressValues.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course1, course2], environment: environment)

        XCTAssertEqual(progressValues.isEmpty, false)
        XCTAssertEqual(progressValues.last?.progress, 1.0)
    }

    func test_downloadContent_withCourseOnlySelection_shouldEmitCompleteWhenAllCoursesProcessed() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        var lastProgress: HOfflineSyncProgress?
        testee.progressPublisher.dropFirst().sink { lastProgress = $0 }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(lastProgress?.isComplete, true)
    }

    func test_downloadContent_shouldResetProgressToZeroWhenCalledAgain() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        testee.downloadContent(courses: [course], environment: environment)
        var received: [HOfflineSyncProgress] = []
        testee.progressPublisher.dropFirst().sink { received.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(received.first?.progress, 0)
        XCTAssertEqual(received.first?.isComplete, false)
    }

    func test_downloadContent_withSelectedFiles_shouldEmitProgressFromFileDownload() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var progressValues: [HOfflineSyncProgress] = []
        testee.progressPublisher.dropFirst().sink { progressValues.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)
        var downloadingFile = file
        downloadingFile.downloadState = .downloading(progress: 0.5)
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadingFile]))

        XCTAssertEqual(progressValues.isEmpty, false)
        XCTAssertEqual(progressValues.last?.isComplete, false)
    }

    // MARK: - downloadContent notifications

    func test_downloadContent_withCourseOnlySelection_shouldSendSuccessNotification() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncCompletedSuccessfully")
    }

    func test_downloadContent_withAllFilesDownloaded_shouldSendSuccessNotification() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var downloadedFile = file
        downloadedFile.downloadState = .downloaded
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadedFile]))

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncCompletedSuccessfully")
    }

    func test_downloadContent_withSomeFilesFailed_shouldSendFailureNotification() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var failedFile = file
        failedFile.downloadState = .failed("download error")
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [failedFile]))

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncFailed")
    }

    // MARK: - downloadContent session manager

    func test_downloadContent_withAllFilesDownloaded_shouldCallFinalizeSync() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var downloadedFile = file
        downloadedFile.downloadState = .downloaded
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadedFile]))

        XCTAssertEqual(sessionManager.finalizeSyncCourses?.first?.id, testData.courseID1)
    }

    func test_downloadContent_withSomeFilesFailed_shouldNotCallFinalizeSync() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var failedFile = file
        failedFile.downloadState = .failed("download error")
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [failedFile]))

        XCTAssertNil(sessionManager.finalizeSyncCourses)
    }

    func test_downloadContent_withAllFilesDownloaded_shouldCallSaveCompletedSync() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var downloadedFile = file
        downloadedFile.downloadState = .downloaded
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [downloadedFile]))

        XCTAssertEqual(sessionManager.saveCompletedSyncCourses?.first?.id, testData.courseID1)
        XCTAssertEqual(sessionManager.saveCompletedSyncFiles?.first?.id, testData.fileID1)
    }

    // MARK: - errorPublisher

    func test_errorPublisher_whenFileDownloadFails_shouldEmit() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var errorReceived = false
        testee.errorPublisher.sink { errorReceived = true }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)
        var failedFile = file
        failedFile.downloadState = .failed("download error")
        filesInteractor.downloadFilesSubject.send(makeFileProgress(files: [failedFile]))

        XCTAssertEqual(errorReceived, true)
    }

    // MARK: - Private helpers

    private func makeInteractor() -> HCourseSyncInteractorLive {
        HCourseSyncInteractorLive(
            interactorFiles: filesInteractor,
            modulesInteractor: modulesInteractor,
            pagesInteractor: pagesInteractor,
            notificationsInteractor: LocalNotificationsInteractor(notificationCenter: notificationCenter),
            sessionManager: sessionManager
        )
    }

    private func makeCourse(
        id: String,
        isSelected: Bool = false,
        files: [OfflineFileItem] = []
    ) -> OfflineCourseItem {
        OfflineCourseItem(
            id: id,
            name: "course name",
            size: nil,
            isExpanded: false,
            isSelected: isSelected,
            subItems: files
        )
    }

    private func makeFileProgress(files: [OfflineFileItem]) -> HFileDownloadProgress {
        let filesByCourse = Dictionary(grouping: files.filter(\.isSelected), by: \.courseID)
        let courseProgresses = filesByCourse.map { courseID, courseFiles -> HCourseFileProgress in
            let totalSize = courseFiles.reduce(0.0) { $0 + $1.sizeInBytes }
            let downloadedSize = courseFiles.reduce(0.0) { sum, file in
                switch file.downloadState {
                case .downloaded: return sum + file.sizeInBytes
                case .downloading(let p): return sum + file.sizeInBytes * Double(p)
                default: return sum
                }
            }
            let state: HSyncCourseState = courseFiles.allSatisfy(\.downloadState.isTerminal) ? .downloaded : .downloading
            return HCourseFileProgress(courseID: courseID, state: state, totalSize: totalSize, downloadedSize: downloadedSize)
        }
        return HFileDownloadProgress(courseProgresses: courseProgresses, files: files)
    }

    private func makeFile(
        id: String,
        courseID: String,
        isSelected: Bool
    ) -> OfflineFileItem {
        OfflineFileItem(
            id: id,
            name: "file name",
            size: "1 MB",
            sizeInBytes: 1_000_000,
            isSelected: isSelected,
            mimeClass: "pdf",
            courseID: courseID
        )
    }
}

// MARK: - Mocks

private final class HCourseSyncFilesInteractorMock: HCourseSyncFilesInteractor {
    let downloadFilesSubject = PassthroughSubject<HFileDownloadProgress, Never>()
    var cancelDownloadsCalled = false
    var deletedFiles: [OfflineFileItem] = []
    var deletedSessionID: String?

    func downloadFiles(courses: [OfflineCourseItem], sessionID: String) -> AnyPublisher<HFileDownloadProgress, Never> {
        let hasSelectedFiles = courses.flatMap(\.selectedFiles).isNotEmpty
        if hasSelectedFiles {
            return downloadFilesSubject.eraseToAnyPublisher()
        }
        return Just(.zero).eraseToAnyPublisher()
    }

    func cancelDownloads() {
        cancelDownloadsCalled = true
    }

    func deleteFiles(_ files: [OfflineFileItem], sessionID: String) {
        deletedFiles = files
        deletedSessionID = sessionID
    }

    func removeUnavailableFiles(courseId: String, newFileIDs: [String], sessionID: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class HCourseSyncModulesInteractorMock: HCourseSyncModulesInteractor {
    func getModuleItems(courseId: String) -> AnyPublisher<[ModuleItem], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class HCourseSyncPagesInteractorMock: HCourseSyncPagesInteractor {
    var deletedCourseIDs: [String] = []
    var deletedSessionID: String?

    func getPages(courseIds: [String]) -> AnyPublisher<HPageDownloadProgress, Error> {
        let progresses = courseIds.map { HCoursePageProgress(courseID: $0, state: .downloaded) }
        return Just(HPageDownloadProgress(courseProgresses: progresses, totalSize: 0, downloadedSize: 0))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func cancelDownloads() {}

    func deletePages(courseIds: [String], sessionID: String) {
        deletedCourseIDs.append(contentsOf: courseIds)
        deletedSessionID = sessionID
    }
}

private final class HOfflineSyncSessionManagerMock: HOfflineSyncSessionManager {
    var sessionID: String
    var syncedItemPaths: [String] = []
    var clearSessionDataCalled = false
    var finalizeSyncCourses: [OfflineCourseItem]?
    var saveCompletedSyncCourses: [OfflineCourseItem]?
    var saveCompletedSyncFiles: [OfflineFileItem]?

    init(sessionID: String) {
        self.sessionID = sessionID
    }

    func clearSessionData() {
        clearSessionDataCalled = true
    }

    func finalizeSync(courses: [OfflineCourseItem]) {
        finalizeSyncCourses = courses
    }

    func saveCompletedSync(courses: [OfflineCourseItem], files: [OfflineFileItem]) {
        saveCompletedSyncCourses = courses
        saveCompletedSyncFiles = files
    }
}
