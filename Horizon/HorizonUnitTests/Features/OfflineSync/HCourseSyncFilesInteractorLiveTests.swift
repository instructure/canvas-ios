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
        courseID2: "course 2",
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
        var received: [HFileDownloadProgress] = []
        testee.downloadFiles(courses: [], sessionID: testData.sessionID)
            .sink { received.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(received.first?.files.count, 0)
    }

    func test_downloadFiles_withFiles_shouldEmitInitialFilesAtLoadingState() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)
        var received: [HFileDownloadProgress] = []
        testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
            .sink { received.append($0) }
            .store(in: &subscriptions)

        XCTAssertEqual(received.first?.files.first?.downloadState, .loading)
        XCTAssertEqual(received.first?.files.first?.id, testData.fileID1)
    }

    func test_downloadFiles_whenAPIFails_shouldTransitionFileToFailedState() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)
        api.mock(
            GetFile(context: .course(testData.courseID), fileID: testData.fileID1),
            error: NSError.instructureError("network error")
        )

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { progress in
                    if case .failed = progress.files.first?.downloadState { return true }
                    return false
                })
        ) { progress in
            guard case .failed = progress.files.first?.downloadState else {
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
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file1, file2])], sessionID: testData.sessionID)
                .first(where: { progress in progress.files.allSatisfy { if case .failed = $0.downloadState { return true }; return false } })
        ) { progress in
            XCTAssertEqual(progress.files.count, 2)
        }
    }

    // MARK: - downloadFiles - cache behavior

    func test_downloadFiles_whenLocalFileIsUpToDate_shouldSkipAPIAndReturnDownloaded() {
        let updatedAt = Date.make(year: 2025, month: 1, day: 1)
        let modificationDate = Date.make(year: 2025, month: 6, day: 1)
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc", updatedAt: updatedAt)
        createLocalFile(fileID: testData.fileID1, courseID: testData.courseID, modificationDate: modificationDate)

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState == .downloaded })
        ) { progress in
            XCTAssertEqual(progress.files.first?.downloadState, .downloaded)
        }
    }

    func test_downloadFiles_whenLocalFileIsStale_shouldDownloadFromAPI() {
        let updatedAt = Date.make(year: 2025, month: 6, day: 1)
        let modificationDate = Date.make(year: 2025, month: 1, day: 1)
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc", updatedAt: updatedAt)
        createLocalFile(fileID: testData.fileID1, courseID: testData.courseID, modificationDate: modificationDate)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            guard case .failed = progress.files.first?.downloadState else {
                XCTFail("Expected .failed state")
                return
            }
        }
    }

    func test_downloadFiles_whenLocalFileHasNoUpdatedAt_shouldDownloadFromAPI() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc", updatedAt: nil)
        createLocalFile(fileID: testData.fileID1, courseID: testData.courseID)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            guard case .failed = progress.files.first?.downloadState else {
                XCTFail("Expected .failed state")
                return
            }
        }
    }

    func test_downloadFiles_whenLocalFileDoesNotExist_shouldDownloadFromAPI() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc")
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            guard case .failed = progress.files.first?.downloadState else {
                XCTFail("Expected .failed state")
                return
            }
        }
    }

    func test_downloadFiles_whenAPIFileHasNoDownloadURL_shouldFail() {
        var apiFile = APIFile.make()
        apiFile.url = nil
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc")
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), value: apiFile)

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            guard case .failed = progress.files.first?.downloadState else {
                XCTFail("Expected .failed state")
                return
            }
        }
    }

    // MARK: - downloadFiles - course progress

    func test_downloadFiles_whenFilesAreLoading_shouldSetCourseStateToDownloading() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)

        XCTAssertFirstValue(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
        ) { progress in
            XCTAssertEqual(progress.courseProgresses.first?.state, .downloading)
        }
    }

    func test_downloadFiles_whenAllFilesTerminate_shouldSetCourseStateToDownloaded() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            XCTAssertEqual(progress.courseProgresses.first?.state, .downloaded)
        }
    }

    func test_downloadFiles_whenAllFilesFail_shouldReportTotalSizeFromFileSizes() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, sizeInBytes: 5_000)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            XCTAssertEqual(progress.courseProgresses.first?.totalSize, 5_000)
        }
    }

    func test_downloadFiles_whenAllFilesFail_shouldReportZeroDownloadedSize() {
        let file = makeFile(id: testData.fileID1, courseID: testData.courseID, sizeInBytes: 5_000)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(courses: [makeCourse(id: testData.courseID, files: [file])], sessionID: testData.sessionID)
                .first(where: { $0.files.first?.downloadState.isTerminal == true })
        ) { progress in
            XCTAssertEqual(progress.courseProgresses.first?.downloadedSize, 0)
        }
    }

    func test_downloadFiles_withFilesFromMultipleCourses_shouldCreateSeparateCourseProgresses() {
        let file1 = makeFile(id: testData.fileID1, courseID: testData.courseID)
        let file2 = makeFile(id: testData.fileID2, courseID: testData.courseID2)
        api.mock(GetFile(context: .course(testData.courseID), fileID: testData.fileID1), error: NSError.instructureError("error"))
        api.mock(GetFile(context: .course(testData.courseID2), fileID: testData.fileID2), error: NSError.instructureError("error"))

        XCTAssertSingleOutput(
            testee.downloadFiles(
                courses: [
                    makeCourse(id: testData.courseID, files: [file1]),
                    makeCourse(id: testData.courseID2, files: [file2])
                ],
                sessionID: testData.sessionID
            )
            .first(where: { $0.files.allSatisfy(\.downloadState.isTerminal) })
        ) { progress in
            XCTAssertEqual(progress.courseProgresses.count, 2)
        }
    }

    // MARK: - deleteFiles

    func test_deleteFiles_shouldRemoveLocalFileDirectory() {
        createFileDirectory(fileID: testData.fileID1, courseID: testData.courseID)

        testee.deleteFiles(
            [makeFile(id: testData.fileID1, courseID: testData.courseID, mimeClass: "doc")],
            sessionID: testData.sessionID
        )

        XCTAssertEqual(fileDirectoryExists(fileID: testData.fileID1, courseID: testData.courseID), false)
    }

    func test_deleteFiles_withEmptyList_shouldNotRemoveAnyFiles() {
        createFileDirectory(fileID: testData.fileID1, courseID: testData.courseID)

        testee.deleteFiles([], sessionID: testData.sessionID)

        XCTAssertEqual(fileDirectoryExists(fileID: testData.fileID1, courseID: testData.courseID), true)
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

    private func makeCourse(id: String, files: [OfflineFileItem]) -> OfflineCourseItem {
        OfflineCourseItem(id: id, name: "course name", size: nil, isExpanded: false, isSelected: true, subItems: files)
    }

    private func makeFile(
        id: String,
        courseID: String,
        sizeInBytes: Double = 1_000_000,
        mimeClass: String = "pdf",
        updatedAt: Date? = nil
    ) -> OfflineFileItem {
        OfflineFileItem(
            id: id,
            name: "file name",
            size: "1 MB",
            sizeInBytes: sizeInBytes,
            isSelected: true,
            mimeClass: mimeClass,
            courseID: courseID,
            updatedAt: updatedAt
        )
    }

    private func localFileURL(fileID: String, courseID: String) -> URL {
        URL.Directories.documents.appendingPathComponent(
            "\(testData.sessionID)/Offline/Files/course-\(courseID)/file-\(fileID)/file name"
        )
    }

    private func createLocalFile(fileID: String, courseID: String, modificationDate: Date = Date()) {
        let fileURL = localFileURL(fileID: fileID, courseID: courseID)
        try? FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? "content".write(to: fileURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.modificationDate: modificationDate], ofItemAtPath: fileURL.path)
    }

    private func fileDirectoryURL(fileID: String, courseID: String) -> URL {
        URL.Directories.documents.appendingPathComponent(
            "\(testData.sessionID)/Offline/Files/course-\(courseID)/file-\(fileID)"
        )
    }

    private func createFileDirectory(fileID: String, courseID: String) {
        try? FileManager.default.createDirectory(
            at: fileDirectoryURL(fileID: fileID, courseID: courseID),
            withIntermediateDirectories: true
        )
    }

    private func fileDirectoryExists(fileID: String, courseID: String) -> Bool {
        FileManager.default.fileExists(atPath: fileDirectoryURL(fileID: fileID, courseID: courseID).path)
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
