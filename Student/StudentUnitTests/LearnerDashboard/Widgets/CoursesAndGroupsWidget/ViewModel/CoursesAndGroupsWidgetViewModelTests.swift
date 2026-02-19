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

import Combine
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class CoursesAndGroupsWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        course1: CoursesAndGroupsWidgetCourseItem.make(id: "course1", title: "course title 1"),
        course2: CoursesAndGroupsWidgetCourseItem.make(id: "course2", title: "course title 2"),
        group1: CoursesAndGroupsWidgetGroupItem.make(id: "group1", title: "group title 1"),
        group2: CoursesAndGroupsWidgetGroupItem.make(id: "group2", title: "group title 2")
    )
    private lazy var testData = Self.testData

    private var testee: CoursesAndGroupsWidgetViewModel!
    private var interactor: CoursesAndGroupsWidgetInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldSetupCorrectly() {
        testee = makeViewModel(config: .make(id: .coursesAndGroups, order: 42))

        XCTAssertEqual(testee.config.id, .coursesAndGroups)
        XCTAssertEqual(testee.config.order, 42)
        XCTAssertEqual(testee.isFullWidth, false)
        XCTAssertEqual(testee.isEditable, false)

        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.courseCards.isEmpty, true)
        XCTAssertEqual(testee.groupCards.isEmpty, true)

        XCTAssertEqual(testee.coursesSectionTitle, "Courses (0)")
        XCTAssertEqual(testee.coursesSectionAccessibilityTitle, "Courses, 0 items")
        XCTAssertEqual(testee.groupsSectionTitle, "Groups (0)")
        XCTAssertEqual(testee.groupsSectionAccessibilityTitle, "Groups, 0 items")
    }

    // MARK: - Layout identifier

    func test_layoutIdentifier_shouldChangeAfterRefresh() {
        testee = makeViewModel()

        interactor.getCoursesAndGroupsOutput = ([], [])
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        let emptyLayoutIdentifier = testee.layoutIdentifier

        interactor.getCoursesAndGroupsOutput = ([testData.course1], [])
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        let courseLayoutIdentifier = testee.layoutIdentifier

        interactor.getCoursesAndGroupsOutput = ([], [testData.group1])
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        let groupLayoutIdentifier = testee.layoutIdentifier

        interactor.getCoursesAndGroupsOutput = ([testData.course1], [testData.group1])
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        let courseAndGroupLayoutIdentifier = testee.layoutIdentifier

        XCTAssertNotEqual(courseLayoutIdentifier, emptyLayoutIdentifier)
        XCTAssertNotEqual(courseLayoutIdentifier, groupLayoutIdentifier)
        XCTAssertNotEqual(courseLayoutIdentifier, courseAndGroupLayoutIdentifier)
    }

    // MARK: - showGrades

    func test_showGrades_shouldFollowInteractorSubject() {
        testee = makeViewModel()

        // WHEN interactor sends true
        interactor.showGrades.send(true)
        // THEN
        waitUntil(shouldFail: true) {
            testee.showGrades == true
        }

        // WHEN interactor sends false
        interactor.showGrades.send(false)
        // THEN
        waitUntil(shouldFail: true) {
            testee.showGrades == false
        }
    }

    // MARK: - showColorOverlay

    func test_showColorOverlay_shouldFollowInteractorSubject() {
        testee = makeViewModel()

        // WHEN interactor sends false
        interactor.showColorOverlay.send(false)
        // THEN
        waitUntil(shouldFail: true) { testee.showColorOverlay == false }

        // WHEN interactor sends true
        interactor.showColorOverlay.send(true)
        // THEN
        waitUntil(shouldFail: true) { testee.showColorOverlay == true }
    }

    // MARK: - Refresh

    func test_refresh_shouldCallInteractor() {
        testee = makeViewModel()
        XCTAssertEqual(interactor.getCoursesAndGroupsCallCount, 0)

        XCTAssertFinish(testee.refresh(ignoreCache: true))

        XCTAssertEqual(interactor.getCoursesAndGroupsCallCount, 1)
        XCTAssertEqual(interactor.getCoursesAndGroupsInput, true)
    }

    // MARK: - Refresh - State

    func test_refresh_shouldUpdateState() {
        testee = makeViewModel()

        // WHEN interactor outputs 1-1 items
        interactor.getCoursesAndGroupsOutput = ([testData.course1], [testData.group1])
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        // THEN state is data
        waitUntil(shouldFail: true) {
            testee.state == .data
        }

        // WHEN interactor outputs 0-0 items
        interactor.getCoursesAndGroupsOutput = ([], [])
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        // THEN state is empty
        waitUntil(shouldFail: true) {
            testee.state == .empty
        }

        // WHEN interactor outputs failure
        interactor.getCoursesAndGroupsOutputError = MockError()
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        // THEN state is error
        waitUntil(shouldFail: true) {
            testee.state == .error
        }
    }

    func test_refresh_withOnlyCourses_shouldSetDataState() {
        testee = makeViewModel()

        interactor.getCoursesAndGroupsOutput = ([testData.course1], [])
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.state, .data)
    }

    func test_refresh_withOnlyGroups_shouldSetDataState() {
        testee = makeViewModel()

        interactor.getCoursesAndGroupsOutput = ([], [testData.group1])
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Refresh - Cards

    func test_refresh_shouldCreateCardViewModels() {
        testee = makeViewModel()

        interactor.getCoursesAndGroupsOutput = (
            [testData.course1, testData.course2],
            [testData.group1, testData.group2]
        )
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.courseCards.count, 2)
        XCTAssertEqual(testee.courseCards.first?.id, testData.course1.id)
        XCTAssertEqual(testee.courseCards.first?.title, testData.course1.title)
        XCTAssertEqual(testee.courseCards.last?.id, testData.course2.id)
        XCTAssertEqual(testee.courseCards.last?.title, testData.course2.title)

        XCTAssertEqual(testee.groupCards.count, 2)
        XCTAssertEqual(testee.groupCards.first?.id, testData.group1.id)
        XCTAssertEqual(testee.groupCards.first?.title, testData.group1.title)
        XCTAssertEqual(testee.groupCards.last?.id, testData.group2.id)
        XCTAssertEqual(testee.groupCards.last?.title, testData.group2.title)
    }

    // MARK: - Refresh - Section titles

    func test_refresh_shouldUpdateSectionTitles() {
        testee = makeViewModel()

        interactor.getCoursesAndGroupsOutput = ([testData.course1, testData.course2], [testData.group1])
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.coursesSectionTitle, "Courses (2)")
        XCTAssertEqual(testee.coursesSectionAccessibilityTitle, "Courses, 2 items")
        XCTAssertEqual(testee.groupsSectionTitle, "Groups (1)")
        XCTAssertEqual(testee.groupsSectionAccessibilityTitle, "Groups, 1 item")
    }

    // MARK: - didTapAllCourses

    func test_didTapAllCourses_shouldCallRouter() {
        testee = makeViewModel()

        let vc = UIViewController()
        testee.didTapAllCourses(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/courses")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        config: DashboardWidgetConfig = .make(id: .coursesAndGroups)
    ) -> CoursesAndGroupsWidgetViewModel {
        CoursesAndGroupsWidgetViewModel(
            config: config,
            interactor: interactor,
            environment: env
        )
    }
}
