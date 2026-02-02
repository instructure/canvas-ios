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

@testable import Horizon
import TestsFoundation
import XCTest
import Combine

final class HAnnouncementDetailsViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var testee: HAnnouncementDetailsViewModel!
    private var mockAnnouncementInteractor: AnnouncementInteractorMock!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockAnnouncementInteractor = AnnouncementInteractorMock()
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        mockAnnouncementInteractor = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeViewModel(announcementModel: AnnouncementModel) -> HAnnouncementDetailsViewModel {
        HAnnouncementDetailsViewModel(
            announcementModel: announcementModel,
            interactor: mockAnnouncementInteractor
        )
    }

    private func makeAnnouncementModel(
        id: String = "announcement-1",
        title: String = "Test Announcement",
        content: String = "Test content",
        courseID: String? = "course-123",
        courseName: String? = "Test Course",
        date: Date? = Date(),
        isRead: Bool = false,
        isGlobal: Bool = false
    ) -> AnnouncementModel {
        AnnouncementModel(
            id: id,
            title: title,
            content: content,
            courseID: courseID,
            courseName: courseName,
            date: date,
            isRead: isRead,
            isGlobal: isGlobal
        )
    }

    // MARK: - Initialization Tests

    func test_init_shouldStoreAnnouncementModel() {
        let announcement = makeAnnouncementModel(
            id: "announcement-123",
            title: "Important Announcement",
            content: "This is important"
        )

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertEqual(testee.announcementModel.id, "announcement-123")
        XCTAssertEqual(testee.announcementModel.title, "Important Announcement")
        XCTAssertEqual(testee.announcementModel.content, "This is important")
    }

    func test_init_shouldCallMarkAnnouncementAsRead() {
        let announcement = makeAnnouncementModel(id: "announcement-456")

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "announcement-456")
    }

    func test_init_shouldMarkCorrectAnnouncement_whenUnread() {
        let unreadAnnouncement = makeAnnouncementModel(
            id: "unread-1",
            title: "Unread Announcement",
            isRead: false
        )

        testee = makeViewModel(announcementModel: unreadAnnouncement)

        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "unread-1")
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.isRead, false)
    }

    func test_init_shouldStillMarkAsRead_whenAlreadyRead() {
        let readAnnouncement = makeAnnouncementModel(
            id: "read-1",
            title: "Read Announcement",
            isRead: true
        )

        testee = makeViewModel(announcementModel: readAnnouncement)

        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "read-1")
    }

    func test_init_shouldMarkGlobalAnnouncement() {
        let globalAnnouncement = makeAnnouncementModel(
            id: "global-1",
            title: "Global Announcement",
            isGlobal: true
        )

        testee = makeViewModel(announcementModel: globalAnnouncement)

        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "global-1")
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.isGlobal, true)
    }

    func test_init_shouldMarkCourseAnnouncement() {
        let courseAnnouncement = makeAnnouncementModel(
            id: "course-announcement-1",
            title: "Course Announcement",
            courseID: "course-456",
            courseName: "Math 101",
            isGlobal: false
        )

        testee = makeViewModel(announcementModel: courseAnnouncement)

        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "course-announcement-1")
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.courseID, "course-456")
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.isGlobal, false)
    }

    // MARK: - AnnouncementModel Property Tests

    func test_announcementModel_shouldReturnCorrectData() {
        let announcement = makeAnnouncementModel(
            id: "test-1",
            title: "Test Title",
            content: "Test Content",
            courseID: "course-789",
            courseName: "Science 101"
        )

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertEqual(testee.announcementModel.id, "test-1")
        XCTAssertEqual(testee.announcementModel.title, "Test Title")
        XCTAssertEqual(testee.announcementModel.content, "Test Content")
        XCTAssertEqual(testee.announcementModel.courseID, "course-789")
        XCTAssertEqual(testee.announcementModel.courseName, "Science 101")
    }

    func test_announcementModel_shouldPreserveNilCourseID() {
        let announcement = makeAnnouncementModel(
            id: "test-2",
            title: "No Course",
            courseID: nil,
            courseName: nil
        )

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertNil(testee.announcementModel.courseID)
        XCTAssertNil(testee.announcementModel.courseName)
    }

    func test_announcementModel_shouldPreserveDate() {
        let specificDate = Date(timeIntervalSince1970: 1234567890)
        let announcement = makeAnnouncementModel(
            id: "test-3",
            date: specificDate
        )

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertEqual(testee.announcementModel.date, specificDate)
    }

    func test_announcementModel_shouldPreserveNilDate() {
        let announcement = makeAnnouncementModel(
            id: "test-4",
            date: nil
        )

        testee = makeViewModel(announcementModel: announcement)

        XCTAssertNil(testee.announcementModel.date)
    }

    // MARK: - Integration Tests

    func test_multipleInstances_shouldEachMarkTheirOwnAnnouncement() {
        let announcement1 = makeAnnouncementModel(id: "ann-1", title: "First")
        let announcement2 = makeAnnouncementModel(id: "ann-2", title: "Second")

        let viewModel1 = makeViewModel(announcementModel: announcement1)
        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 1)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "ann-1")

        let viewModel2 = makeViewModel(announcementModel: announcement2)
        XCTAssertEqual(mockAnnouncementInteractor.markAnnouncementAsReadCallCount, 2)
        XCTAssertEqual(mockAnnouncementInteractor.lastMarkedAnnouncementAsRead?.id, "ann-2")

        XCTAssertEqual(viewModel1.announcementModel.id, "ann-1")
        XCTAssertEqual(viewModel2.announcementModel.id, "ann-2")
    }
}
