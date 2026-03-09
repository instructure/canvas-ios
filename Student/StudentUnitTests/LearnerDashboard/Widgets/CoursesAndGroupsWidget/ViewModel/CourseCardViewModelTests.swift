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
@testable import Student
@testable import TestsFoundation
import SwiftUI
import XCTest

final class CourseCardViewModelTests: StudentTestCase {

    private static let testData = (
        id: "course1",
        title: "some title",
        color: Color.course4,
        imageUrl: URL(string: "https://example.com/image.jpg")!,
        grade: "some grade",
        announcementId: "announcement1"
    )
    private lazy var testData = Self.testData

    private var testee: CourseCardViewModel!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            color: testData.color,
            imageUrl: testData.imageUrl,
            grade: testData.grade,
            unreadAnnouncementCount: 42
        ))

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.courseColor, testData.color)
        XCTAssertEqual(testee.imageUrl, testData.imageUrl)
        XCTAssertEqual(testee.grade, testData.grade)
        XCTAssertEqual(testee.unreadAnnouncementCount, 42)
    }

    // MARK: - isAvailableOffline

    func test_isAvailableOffline_shouldUseCurrentValue() {
        testee = makeViewModel(model: .make(id: testData.id))

        // selection contains id
        env.userDefaults?.offlineSyncSelections = ["courses/\(testData.id)"]
        XCTAssertEqual(testee.isAvailableOffline, true)

        // selection does not contain id
        env.userDefaults?.offlineSyncSelections = ["courses/other_course"]
        XCTAssertEqual(testee.isAvailableOffline, false)

        // selection is empty
        env.userDefaults?.offlineSyncSelections = []
        XCTAssertEqual(testee.isAvailableOffline, false)
    }

    // MARK: - shouldShowAnnouncementsButton

    func test_shouldShowAnnouncementsButton() {
        // WHEN unreadAnnouncementCount is 0
        var testee = makeViewModel(model: .make(unreadAnnouncementCount: 0))
        // THEN
        XCTAssertEqual(testee.shouldShowAnnouncementsButton, false)

        // WHEN unreadAnnouncementCount is 1
        testee = makeViewModel(model: .make(unreadAnnouncementCount: 1))
        // THEN
        XCTAssertEqual(testee.shouldShowAnnouncementsButton, true)

        // WHEN unreadAnnouncementCount is greater than 1
        testee = makeViewModel(model: .make(unreadAnnouncementCount: 3))
        // THEN
        XCTAssertEqual(testee.shouldShowAnnouncementsButton, true)
    }

    // MARK: - openAnnouncementsA11yLabel

    func test_openAnnouncementsA11yLabel() {
        // WHEN unreadAnnouncementCount is 1
        testee = makeViewModel(model: .make(unreadAnnouncementCount: 1))
        // THEN
        XCTAssertEqual(testee.openAnnouncementsA11yLabel, "Open New Announcement")

        // WHEN unreadAnnouncementCount is greater than 1
        testee = makeViewModel(model: .make(unreadAnnouncementCount: 3))
        // THEN
        XCTAssertEqual(testee.openAnnouncementsA11yLabel, "Open Announcements")
    }

    // MARK: - didTapCard

    func test_didTapCard_shouldRouteToCourse() {
        testee = makeViewModel(model: .make(id: testData.id))
        let vc = UIViewController()

        testee.didTapCard(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/courses/course1")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    // MARK: - didTapManageOfflineContent

    func test_didTapManageOfflineContent_shouldRouteToSyncPicker() {
        testee = makeViewModel(model: .make(id: testData.id))
        let vc = UIViewController()

        testee.didTapManageOfflineContent(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/offline/sync_picker/\(testData.id)")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions?.isModal, true)
    }

    // MARK: - didTapAnnouncements

    func test_didTapAnnouncements_withSingleUnreadAnnouncement_shouldRouteToAnnouncement() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            singleUnreadAnnouncementId: testData.announcementId
        ))
        let vc = UIViewController()

        testee.didTapAnnouncements(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/courses/\(testData.id)/announcements/\(testData.announcementId)")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    func test_didTapAnnouncements_withMultipleUnreadAnnouncements_shouldRouteToAnnouncementsList() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            singleUnreadAnnouncementId: nil
        ))
        let vc = UIViewController()

        testee.didTapAnnouncements(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/courses/\(testData.id)/announcements")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    // MARK: - Equatability

    func test_equatable_withSameModel_shouldBeEqual() {
        let vm1 = makeViewModel(model: .make(id: testData.id, title: testData.title))
        let vm2 = makeViewModel(model: .make(id: testData.id, title: testData.title))

        XCTAssertEqual(vm1, vm2)
    }

    func test_equatable_withDifferentModels_shouldNotBeEqual() {
        let vm1 = makeViewModel(model: .make(title: "title 1"))
        let vm2 = makeViewModel(model: .make(title: "title 2"))

        XCTAssertNotEqual(vm1, vm2)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        model: CoursesAndGroupsWidgetCourseItem = .make()
    ) -> CourseCardViewModel {
        CourseCardViewModel(
            model: model,
            didSaveChanges: .init(),
            router: router
        )
    }
}
