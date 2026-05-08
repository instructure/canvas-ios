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

final class HCourseSyncFilesInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        sessionID: "test-session-files",
        courseID: "course 1",
        fileID1: "file 1",
        fileID2: "file 2"
    )
    private lazy var testData = Self.testData

    private var testee: HCourseSyncFilesInteractorLive!
    private var offlineFileInteractor: OfflineFileInteractorMock!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        offlineFileInteractor = OfflineFileInteractorMock()
        testee = HCourseSyncFilesInteractorLive(offlineFileInteractor: offlineFileInteractor)
    }

    override func tearDown() {
        testee = nil
        offlineFileInteractor = nil
        subscriptions.removeAll()
        cleanupSessionDirectory()
        super.tearDown()
    }

    // MARK: - downloadFiles

    func test_downloadFiles_withNoFiles_shouldEmitEmptyCollection() {
        var received: [[OfflineFileItem]] = []
        testee.downloadFiles(files: [], sessionID: testData.sessionID)
            .sink { received.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(received.first?.count, 0)
    }

    func test_downloadFiles_withFiles_shouldEmitInitialFilesAtIdleState() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)
        var received: [[OfflineFileItem]] = []
        testee.downloadFiles(files: [file], sessionID: testData.sessionID)
            .sink { received.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(received.first?.first?.downloadState, .idle)
        XCTAssertEqual(received.first?.first?.id, testData.fileID1)
    }

    func test_downloadFiles_whenAPIFails_shouldTransitionFileToFailedState() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)
        api.mock(
            GetFile(context: .course(testData.courseID), fileID: testData.fileID1),
            error: NSError.instructureError("network error")
        )

        XCTAssertSingleOutput(
            testee.downloadFiles(files: [file], sessionID: testData.sessionID)
                .first(where: { items in
                    if case .failed = items.first?.downloadState { return true }
                    return false
                })
        ) { items in
            guard case .failed = items.first?.downloadState else {
                XCTFail("Expected .failed state")
                return
            }
        }
    }

    func test_downloadFiles_withMultipleFiles_shouldTrackEachFileIndependently() {
        let file1 = makeFile(id: testData.fileID1, courseID: testData.courseID)
        let file2 = makeFile(id: testData.fileID2, courseID: testData.courseID)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID2), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(files: [file1, file2], sessionID: testData.sessionID)
                .first(where: { items in items.allSatisfy { if case .failed = $0.downloadState { return true }; return false } })
        ) { items in
            XCTAssertEqual(items.count, 2)
        }
    }

    // MARK: - removeUnavailableFiles

    func test_removeUnavailableFiles_withNonExistentDirectory_shouldCompleteSuccessfully() {
        XCTAssertFinish(
            testee.removeUnavailableFiles(
                courseId: testData.courseID,
                newFileIDs: [],
                sessionID: testData.sessionID
            )
        )
    }

    func test_removeUnavailableFiles_whenFileNotInNewList_shouldRemoveFile() {
        createFileFolderInCourseDirectory(fileID: testData.fileID1)

        XCTAssertFinish(
            testee.removeUnavailableFiles(
                courseId: testData.courseID,
                newFileIDs: [],
                sessionID: testData.sessionID
            )
        )

        XCTAssertEqual(courseDirectoryContents().contains("file-\(testData.fileID1)"), false)
    }

    func test_removeUnavailableFiles_whenFileIsInNewList_shouldKeepFile() {
        createFileFolderInCourseDirectory(fileID: testData.fileID1)

        XCTAssertFinish(
            testee.removeUnavailableFiles(
                courseId: testData.courseID,
                newFileIDs: [testData.fileID1],
                sessionID: testData.sessionID
            )
        )

        XCTAssertEqual(courseDirectoryContents().contains("file-\(testData.fileID1)"), true)
    }

    func test_removeUnavailableFiles_withMultipleFiles_shouldOnlyRemoveFilesNotInNewList() {
        createFileFolderInCourseDirectory(fileID: testData.fileID1)
        createFileFolderInCourseDirectory(fileID: testData.fileID2)

        XCTAssertFinish(
            testee.removeUnavailableFiles(
                courseId: testData.courseID,
                newFileIDs: [testData.fileID1],
                sessionID: testData.sessionID
            )
        )

        let contents = courseDirectoryContents()
        XCTAssertEqual(contents.contains("file-\(testData.fileID1)"), true)
        XCTAssertEqual(contents.contains("file-\(testData.fileID2)"), false)
    }

    // MARK: - Private helpers

    private func makeFile(id: String, courseID: String) -> OfflineFileItem {
        OfflineFileItem(
            id: id,
            name: "file name",
            size: "1 MB",
            sizeInBytes: 1_000_000,
            isSelected: true,
            mimeClass: "pdf",
            courseID: courseID
        )
    }

    private func courseFolderURL() -> URL {
        URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseFolder(sessionID: testData.sessionID, courseId: testData.courseID)
        )
    }

    private func createFileFolderInCourseDirectory(fileID: String) {
        let folderURL = courseFolderURL().appendingPathComponent("file-\(fileID)")
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }

    private func courseDirectoryContents() -> [String] {
        (try? FileManager.default.contentsOfDirectory(atPath: courseFolderURL().path)) ?? []
    }

    private func cleanupSessionDirectory() {
        let sessionRoot = URL.Directories.documents.appendingPathComponent(testData.sessionID)
        try? FileManager.default.removeItem(at: sessionRoot)
    }
}

// MARK: - Mocks

private final class OfflineFileInteractorMock: OfflineFileInteractor {
    var isOffline: Bool = false

    func filePath(sessionID: String, courseId: String, fileID: String, fileName: String) -> String {
        "\(sessionID)/Offline/Files/course-\(courseId)/file-\(fileID)/\(fileName)"
    }

    func isItemAvailableOffline(courseID: String?, fileID: String?) -> Bool { false }
    func filePath(source: OfflineFileSource?) -> String? { nil }
    func isItemAvailableOffline(source: OfflineFileSource?) -> Bool { false }
}
