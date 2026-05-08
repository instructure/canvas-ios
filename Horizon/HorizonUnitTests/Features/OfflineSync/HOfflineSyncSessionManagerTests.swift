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

final class HOfflineSyncSessionManagerTests: HorizonTestCase {

    private static let testData = (
        sessionID: "session 1",
        courseID1: "course 1",
        courseID2: "course 2",
        fileID1: "file 1",
        fileID2: "file 2"
    )
    private lazy var testData = Self.testData

    private var session: SessionDefaults!
    private var filesInteractor: HCourseSyncFilesInteractorMock!
    private var pagesInteractor: HCourseSyncPagesInteractorMock!
    private var testee: HOfflineSyncSessionManager!

    override func setUp() {
        super.setUp()
        session = SessionDefaults(sessionID: testData.sessionID)
        filesInteractor = HCourseSyncFilesInteractorMock()
        pagesInteractor = HCourseSyncPagesInteractorMock()
        testee = HOfflineSyncSessionManagerLive(
            session: session,
            filesInteractor: filesInteractor,
            pagesInteractor: pagesInteractor
        )
    }

    override func tearDown() {
        testee = nil
        filesInteractor = nil
        pagesInteractor = nil
        session.reset()
        session = nil
        super.tearDown()
    }

    // MARK: - sessionID

    func test_sessionID_shouldReturnSessionID() {
        XCTAssertEqual(testee.sessionID, testData.sessionID)
    }

    // MARK: - syncedItemPaths

    func test_syncedItemPaths_shouldReturnSessionItems() {
        session.offlineSyncSelections = ["path 1", "path 2"]

        XCTAssertEqual(testee.syncedItemPaths, ["path 1", "path 2"])
    }

    // MARK: - clearSessionData

    func test_clearSessionData_shouldClearSyncItems() {
        session.offlineSyncSelections = ["path 1"]

        testee.clearSessionData()

        XCTAssertEqual(session.offlineSyncSelections, [])
    }

    func test_clearSessionData_shouldClearFileMetadata() {
        session.horizonOfflineSyncFileMetadata = [testData.fileID1: ["key": "value"]]

        testee.clearSessionData()

        XCTAssertEqual(session.horizonOfflineSyncFileMetadata.isEmpty, true)
    }

    // MARK: - finalizeSync

    func test_finalizeSync_shouldUpdateFileMetadataForSelectedFiles() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.finalizeSync(courses: [course])

        XCTAssertNotNil(session.horizonOfflineSyncFileMetadata[testData.fileID1])
    }

    func test_finalizeSync_shouldNotUpdateFileMetadataForDeselectedFiles() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: false)
        let course = makeCourse(id: testData.courseID1, files: [file])

        testee.finalizeSync(courses: [course])

        XCTAssertNil(session.horizonOfflineSyncFileMetadata[testData.fileID1])
    }

    func test_finalizeSync_shouldClearSyncItems() {
        session.offlineSyncSelections = ["path 1", "path 2"]

        testee.finalizeSync(courses: [])

        XCTAssertEqual(session.offlineSyncSelections, [])
    }

    func test_finalizeSync_shouldCallRemoveUnavailableFilesForEachCourse() {
        let course1 = makeCourse(id: testData.courseID1)
        let course2 = makeCourse(id: testData.courseID2)

        testee.finalizeSync(courses: [course1, course2])

        XCTAssertEqual(filesInteractor.removeUnavailableFilesCourseIDs, [testData.courseID1, testData.courseID2])
    }

    func test_finalizeSync_shouldCallDeletePagesForDeselectedCourses() {
        session.offlineSyncSelections = [OfflineType.course(id: testData.courseID2).path()]
        let course1 = makeCourse(id: testData.courseID1)

        testee.finalizeSync(courses: [course1])

        XCTAssertEqual(pagesInteractor.deletedCourseIDs, [testData.courseID2])
    }

    func test_finalizeSync_shouldNotDeletePagesForRetainedCourses() {
        session.offlineSyncSelections = [OfflineType.course(id: testData.courseID1).path()]
        let course1 = makeCourse(id: testData.courseID1)

        testee.finalizeSync(courses: [course1])

        XCTAssertEqual(pagesInteractor.deletedCourseIDs, [])
    }

    // MARK: - saveCompletedSync

    func test_saveCompletedSync_shouldAppendCourseAndDownloadedFilePaths() {
        let course = makeCourse(id: testData.courseID1)
        var file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)
        file.downloadState = .downloaded

        testee.saveCompletedSync(courses: [course], files: [file])

        let expectedCoursePath = OfflineType.course(id: testData.courseID1).path()
        let expectedFilePath = OfflineType.file(courseID: testData.courseID1, fileID: testData.fileID1).path()
        XCTAssertEqual(session.offlineSyncSelections.contains(expectedCoursePath), true)
        XCTAssertEqual(session.offlineSyncSelections.contains(expectedFilePath), true)
    }

    func test_saveCompletedSync_shouldNotIncludeNonDownloadedFiles() {
        let course = makeCourse(id: testData.courseID1)
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID1, isSelected: true)

        testee.saveCompletedSync(courses: [course], files: [file])

        let filePath = OfflineType.file(courseID: testData.courseID1, fileID: testData.fileID1).path()
        XCTAssertEqual(session.offlineSyncSelections.contains(filePath), false)
    }

    func test_saveCompletedSync_shouldAppendToExistingItems() {
        session.offlineSyncSelections = [OfflineType.course(id: testData.courseID1).path()]
        let course2 = makeCourse(id: testData.courseID2)

        testee.saveCompletedSync(courses: [course2], files: [])

        XCTAssertEqual(session.offlineSyncSelections.count, 2)
        XCTAssertEqual(session.offlineSyncSelections.contains(OfflineType.course(id: testData.courseID1).path()), true)
        XCTAssertEqual(session.offlineSyncSelections.contains(OfflineType.course(id: testData.courseID2).path()), true)
    }

    // MARK: - Private helpers

    private func makeCourse(
        id: String,
        files: [OfflineFileItem] = []
    ) -> OfflineCourseItem {
        OfflineCourseItem(id: id, name: "course name", size: nil, isExpanded: false, isSelected: false, subItems: files)
    }

    private func makeFile(
        id: String,
        courseID: String,
        isSelected: Bool = false
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
    var removeUnavailableFilesCourseIDs: [String] = []

    func downloadFiles(courses: [OfflineCourseItem], sessionID: String) -> AnyPublisher<HFileDownloadProgress, Never> {
        Empty().eraseToAnyPublisher()
    }

    func cancelDownloads() {}

    func deleteFiles(_ files: [OfflineFileItem], sessionID: String) {}

    func removeUnavailableFiles(courseId: String, newFileIDs: [String], sessionID: String) -> AnyPublisher<Void, Error> {
        removeUnavailableFilesCourseIDs.append(courseId)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class HCourseSyncPagesInteractorMock: HCourseSyncPagesInteractor {
    var deletedCourseIDs: [String] = []

    func getPages(courseIds: [String]) -> AnyPublisher<HPageDownloadProgress, Error> {
        Empty().eraseToAnyPublisher()
    }

    func cancelDownloads() {}

    func deletePages(courseIds: [String], sessionID: String) {
        deletedCourseIDs.append(contentsOf: courseIds)
    }
}
