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
        colorString: "#4A90D9",
        imageUrl: URL(string: "https://example.com/image.jpg")!,
        grade: "some grade"
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
            colorString: testData.colorString,
            imageUrl: testData.imageUrl,
            grade: testData.grade
        ))

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.courseColor.hexString, testData.colorString.lowercased())
        XCTAssertEqual(testee.imageUrl, testData.imageUrl)
        XCTAssertEqual(testee.grade, testData.grade)
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

    // MARK: - didTapCard

    func test_didTapCard_withColorString_shouldRouteWithContextColor() {
        testee = makeViewModel(model: .make(id: testData.id, colorString: testData.colorString))
        let vc = UIViewController()

        testee.didTapCard(from: .init(vc))

        XCTAssertEqual(router.lastRoutedTo("/courses/course1?contextColor=4A90D9"), true)
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    func test_didTapCard_withNoColorString_shouldRouteWithoutContextColor() {
        testee = makeViewModel(model: .make(id: testData.id, colorString: nil))
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
            router: router
        )
    }
}
