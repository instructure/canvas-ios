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

final class HCourseSyncPagesInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        courseID1: "42",
        courseID2: "99",
        sessionID: "session 1"
    )
    private lazy var testData = Self.testData

    private var htmlParser: HTMLParserMock!
    private var testee: HCourseSyncPagesInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        htmlParser = HTMLParserMock()
        testee = HCourseSyncPagesInteractorLive(htmlParser: htmlParser)
    }

    override func tearDown() {
        testee = nil
        htmlParser = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - getPages

    func test_getPages_whenCourseIdsIsEmpty_shouldReturnZeroProgress() {
        var received: [HPageDownloadProgress] = []

        testee.getPages(courseIds: [])
            .sink(receiveCompletion: { _ in }, receiveValue: { received.append($0) })
            .store(in: &subscriptions)

        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.totalSize, 0)
        XCTAssertEqual(received.first?.downloadedSize, 0)
        XCTAssertEqual(received.first?.courseProgresses.isEmpty, true)
    }

    func test_getPages_withPagesForCourse_shouldEmitDownloadedStateWhenAllPagesComplete() {
        mockFrontPage(courseID: testData.courseID1, pageID: "fp1")
        mockPages(courseID: testData.courseID1, pages: [
            makeAPIPage(pageID: "p1", courseID: testData.courseID1)
        ])
        let expectation = expectation(description: "publisher completes")
        var lastProgress: HPageDownloadProgress?

        testee.getPages(courseIds: [testData.courseID1])
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { lastProgress = $0 }
            )
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1)
        let courseProgress = lastProgress?.courseProgresses.first
        XCTAssertEqual(courseProgress?.courseID, testData.courseID1)
        XCTAssertEqual(courseProgress?.state, .downloaded)
        XCTAssertEqual(lastProgress?.totalSize, 2 * HPageDownloadProgress.bytesPerPage)
        XCTAssertEqual(lastProgress?.downloadedSize, 2 * HPageDownloadProgress.bytesPerPage)
    }

    func test_getPages_withPagesForCourse_shouldEmitIncrementalProgress() {
        mockFrontPage(courseID: testData.courseID1, pageID: "fp1")
        mockPages(courseID: testData.courseID1, pages: [
            makeAPIPage(pageID: "p1", courseID: testData.courseID1),
            makeAPIPage(pageID: "p2", courseID: testData.courseID1)
        ])
        let expectation = expectation(description: "publisher completes")
        var allProgresses: [HPageDownloadProgress] = []

        testee.getPages(courseIds: [testData.courseID1])
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { allProgresses.append($0) }
            )
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1)
        // Expect at least the initial (0 downloaded) and final (all downloaded) emissions
        XCTAssertEqual(allProgresses.first?.downloadedSize, 0)
        XCTAssertEqual(allProgresses.first?.totalSize, 3 * HPageDownloadProgress.bytesPerPage)
        XCTAssertEqual(allProgresses.last?.downloadedSize, 3 * HPageDownloadProgress.bytesPerPage)
    }

    func test_getPages_withMultipleCourses_shouldAggregateAllCoursesProgress() {
        mockFrontPage(courseID: testData.courseID1, pageID: "fp1")
        mockPages(courseID: testData.courseID1, pages: [
            makeAPIPage(pageID: "p1", courseID: testData.courseID1)
        ])
        mockFrontPage(courseID: testData.courseID2, pageID: "fp2")
        mockPages(courseID: testData.courseID2, pages: [
            makeAPIPage(pageID: "p2", courseID: testData.courseID2),
            makeAPIPage(pageID: "p3", courseID: testData.courseID2)
        ])
        let expectation = expectation(description: "publisher completes")
        var lastProgress: HPageDownloadProgress?

        testee.getPages(courseIds: [testData.courseID1, testData.courseID2])
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { lastProgress = $0 }
            )
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1)
        // courseID1: front page + 1 page = 2, courseID2: front page + 2 pages = 3 → total 5
        XCTAssertEqual(lastProgress?.courseProgresses.count, 2)
        XCTAssertEqual(lastProgress?.totalSize, 5 * HPageDownloadProgress.bytesPerPage)
        XCTAssertEqual(lastProgress?.downloadedSize, 5 * HPageDownloadProgress.bytesPerPage)
        XCTAssertEqual(lastProgress?.courseProgresses.allSatisfy { $0.state == .downloaded }, true)
    }

    func test_getPages_withNoPagesForCourse_shouldEmitDownloadedStateWithZeroSizes() {
        mockFrontPage(courseID: testData.courseID1, pageID: "fp1")
        mockPages(courseID: testData.courseID1, pages: [])
        let expectation = expectation(description: "publisher completes")
        var lastProgress: HPageDownloadProgress?

        testee.getPages(courseIds: [testData.courseID1])
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { lastProgress = $0 }
            )
            .store(in: &subscriptions)

        waitForExpectations(timeout: 1)
        // Only the front page exists (1 page total)
        XCTAssertEqual(lastProgress?.courseProgresses.first?.state, .downloaded)
        XCTAssertEqual(lastProgress?.totalSize, 1 * HPageDownloadProgress.bytesPerPage)
        XCTAssertEqual(lastProgress?.downloadedSize, 1 * HPageDownloadProgress.bytesPerPage)
    }

    // MARK: - deletePages

    func test_deletePages_shouldRemovePagesFolder() {
        let folderURL = URL.Paths.Offline.courseSectionFolderURL(
            sessionId: testData.sessionID,
            courseId: testData.courseID1,
            sectionName: "pages"
        )
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        testee.deletePages(courseIds: [testData.courseID1], sessionID: testData.sessionID)

        XCTAssertEqual(FileManager.default.fileExists(atPath: folderURL.path), false)
    }

    func test_deletePages_withMultipleCourses_shouldRemoveAllPagesFolders() {
        let folderURL1 = URL.Paths.Offline.courseSectionFolderURL(
            sessionId: testData.sessionID,
            courseId: testData.courseID1,
            sectionName: "pages"
        )
        let folderURL2 = URL.Paths.Offline.courseSectionFolderURL(
            sessionId: testData.sessionID,
            courseId: testData.courseID2,
            sectionName: "pages"
        )
        try? FileManager.default.createDirectory(at: folderURL1, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: folderURL2, withIntermediateDirectories: true)

        testee.deletePages(courseIds: [testData.courseID1, testData.courseID2], sessionID: testData.sessionID)

        XCTAssertEqual(FileManager.default.fileExists(atPath: folderURL1.path), false)
        XCTAssertEqual(FileManager.default.fileExists(atPath: folderURL2.path), false)
    }

    // MARK: - Private helpers

    private func mockFrontPage(courseID: String, pageID: String) {
        api.mock(
            GetFrontPage(context: .course(courseID)),
            value: .make(
                front_page: true, html_url: URL(string: "https://canvas.instructure.com/courses/\(courseID)/pages/\(pageID)")!, page_id: ID(pageID)
            )
        )
    }

    private func mockPages(courseID: String, pages: [APIPage]) {
        api.mock(GetPages(context: .course(courseID)), value: pages)
    }

    private func makeAPIPage(pageID: String, courseID: String) -> APIPage {
        .make(
            front_page: false, html_url: URL(string: "https://canvas.instructure.com/courses/\(courseID)/pages/\(pageID)")!, page_id: ID(pageID)
        )
    }
}

// MARK: - Mocks

private final class HTMLParserMock: HTMLParser {
    var embeddedContentFailurePublisher: AnyPublisher<CourseSyncID, Never> {
        Empty().eraseToAnyPublisher()
    }

    var sectionName: String = "pages"
    var envResolver: CourseSyncEnvironmentResolver = CourseSyncEnvironmentResolverLive()

    func sectionFolder(for courseId: CourseSyncID) -> URL {
        URL.Directories.documents
    }

    func parse(
        _ content: String,
        resourceId: String,
        courseId: CourseSyncID,
        baseURL: URL?
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func downloadAttachment(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
