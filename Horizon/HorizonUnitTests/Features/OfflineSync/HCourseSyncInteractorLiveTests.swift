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
    private var notificationCenter: MockUserNotificationCenter!
    private var session: SessionDefaults!
    private var testee: HCourseSyncInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        filesInteractor = HCourseSyncFilesInteractorMock()
        modulesInteractor = HCourseSyncModulesInteractorMock()
        notificationCenter = MockUserNotificationCenter()
        session = SessionDefaults(sessionID: testData.sessionID)
        testee = makeInteractor()
    }

    override func tearDown() {
        testee = nil
        filesInteractor = nil
        modulesInteractor = nil
        notificationCenter = nil
        subscriptions.removeAll()
        session.reset()
        session = nil
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

    func test_clear_shouldClearSessionSyncItems() {
        session.horizonOfflineSyncItems = ["item 1", "item 2"]

        testee.clear()

        XCTAssertEqual(session.horizonOfflineSyncItems, [])
    }

    func test_clear_shouldClearSessionFileMetadata() {
        session.horizonOfflineSyncFileMetadata = [testData.fileID1: ["key": "value"]]

        testee.clear()

        XCTAssertEqual(session.horizonOfflineSyncFileMetadata.isEmpty, true)
    }

    // MARK: - downloadContent

    func test_downloadContent_shouldResetSessionSyncItems() {
        session.horizonOfflineSyncItems = ["item 1"]

        testee.downloadContent(courses: [], environment: environment)

        XCTAssertEqual(session.horizonOfflineSyncItems, [])
    }

    func test_downloadContent_withSelectedFiles_shouldUpdateFileMetadataInSession() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertNotNil(session.horizonOfflineSyncFileMetadata[testData.fileID1])
    }

    func test_downloadContent_withCourseOnlySelection_shouldEmitProgressForEachCourse() {
        let course1 = makeCourse(id: testData.courseID1, isSelected: true)
        let course2 = makeCourse(id: testData.courseID2, isSelected: true)
        var progressValues: [HOfflineSyncProgress] = []
        testee.progressPublisher.dropFirst().sink { progressValues.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course1, course2], environment: environment)

        XCTAssertEqual(progressValues.count, 2)
        XCTAssertEqual(progressValues.first?.progress, 0.5)
        XCTAssertEqual(progressValues.last?.progress, 1.0)
    }

    func test_downloadContent_withCourseOnlySelection_shouldEmitCompleteWhenAllCoursesProcessed() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)
        var lastProgress: HOfflineSyncProgress?
        testee.progressPublisher.dropFirst().sink { lastProgress = $0 }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(lastProgress?.isComplete, true)
    }

    func test_downloadContent_withCourseOnlySelection_shouldSendSuccessNotification() {
        let course = makeCourse(id: testData.courseID1, isSelected: true)

        testee.downloadContent(courses: [course], environment: environment)

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncCompletedSuccessfully")
    }

    func test_downloadContent_withSelectedFiles_shouldEmitProgressFromFileDownload() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])
        var progressValues: [HOfflineSyncProgress] = []
        testee.progressPublisher.dropFirst().sink { progressValues.append($0) }.store(in: &subscriptions)

        testee.downloadContent(courses: [course], environment: environment)
        var downloadingFile = file
        downloadingFile.downloadState = .downloading(progress: 0.5)
        filesInteractor.downloadFilesSubject.send([downloadingFile])

        XCTAssertEqual(progressValues.isEmpty, false)
        XCTAssertEqual(progressValues.last?.isComplete, false)
    }

    func test_downloadContent_withAllFilesDownloaded_shouldSendSuccessNotification() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var downloadedFile = file
        downloadedFile.downloadState = .downloaded
        filesInteractor.downloadFilesSubject.send([downloadedFile])

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncCompletedSuccessfully")
    }

    func test_downloadContent_withSomeFilesFailed_shouldSendFailureNotification() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.downloadContent(courses: [course], environment: environment)
        var failedFile = file
        failedFile.downloadState = .failed("download error")
        filesInteractor.downloadFilesSubject.send([failedFile])

        XCTAssertEqual(notificationCenter.requests.last?.identifier, "OfflineSyncFailed")
    }

    // MARK: - Private helpers

    private func makeInteractor() -> HCourseSyncInteractorLive {
        HCourseSyncInteractorLive(
            interactorFiles: filesInteractor,
            modulesInteractor: modulesInteractor,
            notificationsInteractor: LocalNotificationsInteractor(notificationCenter: notificationCenter),
            session: session
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
    let downloadFilesSubject = PassthroughSubject<[OfflineFileItem], Never>()

    func downloadFiles(files: [OfflineFileItem], sessionID: String) -> AnyPublisher<[OfflineFileItem], Never> {
        downloadFilesSubject.eraseToAnyPublisher()
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
