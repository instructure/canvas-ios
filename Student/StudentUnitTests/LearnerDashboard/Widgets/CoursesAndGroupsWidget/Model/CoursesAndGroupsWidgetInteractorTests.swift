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

final class CoursesAndGroupsWidgetInteractorTests: StudentTestCase {

    private static let testData = (
        courseId1: "course1",
        courseName1: "some courseName1",
        courseId2: "course2",
        courseName2: "some courseName2",
        groupId1: "group1",
        groupName1: "some groupName1",
        groupId2: "group2",
        groupName2: "some groupName2"
    )
    private lazy var testData = Self.testData

    private var testee: CoursesAndGroupsWidgetInteractorLive!
    private var coursesInteractor: CoursesInteractorMock!

    override func setUp() {
        super.setUp()
        coursesInteractor = .init()
        setupDefaultAPIMocks()
    }

    override func tearDown() {
        testee = nil
        coursesInteractor = nil
        super.tearDown()
    }

    // MARK: - showGrades

    func test_showGrades_initialValue_whenUserDefaultsIsFalse_shouldBeFalse() {
        env.userDefaults?.showGradesOnDashboard = false
        testee = makeInteractor()

        XCTAssertEqual(testee.showGrades.value, false)
    }

    func test_showGrades_initialValue_whenUserDefaultsIsTrue_shouldBeTrue() {
        env.userDefaults?.showGradesOnDashboard = true
        testee = makeInteractor()

        XCTAssertEqual(testee.showGrades.value, true)
    }

    func test_showGrades_whenNotificationIsPosted_shouldUpdateValue() {
        testee = makeInteractor()
        XCTAssertEqual(testee.showGrades.value, true)

        env.userDefaults?.showGradesOnDashboard = false

        waitUntil(shouldFail: true) {
            testee.showGrades.value == false
        }
    }

    // MARK: - showColorOverlay

    func test_showColorOverlay_initialValue_shouldBeTrue() {
        testee = makeInteractor()

        XCTAssertEqual(testee.showColorOverlay.value, true)
    }

    func test_showGrades_whenUserSettingsIsUpdated_shouldUpdateValue() {
        testee = makeInteractor()

        // WHEN hideDashcardColorOverlays is true
        let userSettings = UserSettings.save(.make(hide_dashcard_color_overlays: true), in: databaseClient)

        // THEN showColorOverlay should be false
        waitUntil(shouldFail: true) {
            testee.showColorOverlay.value == false
        }

        // WHEN hideDashcardColorOverlays is false
        userSettings.hideDashcardColorOverlays = false

        // THEN showColorOverlay should be true
        waitUntil(shouldFail: true) {
            testee.showColorOverlay.value == true
        }
    }

    // MARK: - getCoursesAndGroups

    func test_getCoursesAndGroups_shouldReturnMappedCourseItems() {
        let course1 = Course.save(.make(id: ID(testData.courseId1), name: testData.courseName1), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2), name: testData.courseName2), in: databaseClient)
        try? databaseClient.save()

        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0, shortName: testData.courseName1),
            .make(id: ID(testData.courseId2), position: 1, shortName: testData.courseName2)
        ])

        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (courses, groups) in
            XCTAssertEqual(courses.count, 2)
            XCTAssertEqual(courses.first?.id, self.testData.courseId1)
            XCTAssertEqual(courses.first?.title, self.testData.courseName1)
            XCTAssertEqual(courses.last?.id, self.testData.courseId2)
            XCTAssertEqual(courses.last?.title, self.testData.courseName2)
            XCTAssertEqual(groups.isEmpty, true)
        }
    }

    func test_getCoursesAndGroups_shouldReturnMappedGroupItems() {
        api.mock(GetFavoriteGroupsRequest(context: .currentUser), value: [
            .make(id: ID(testData.groupId1), name: testData.groupName1, members_count: 42, course_id: nil)
        ])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (_, groups) in
            XCTAssertEqual(groups.count, 1)
            XCTAssertEqual(groups.first?.id, self.testData.groupId1)
            XCTAssertEqual(groups.first?.title, self.testData.groupName1)
            XCTAssertEqual(groups.first?.memberCount, 42)
        }
    }

    // MARK: - Course sorting

    func test_getCoursesAndGroups_shouldSortCoursesByDashboardCardPosition() {
        let course1 = Course.save(.make(id: ID(testData.courseId1), name: testData.courseName1), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2), name: testData.courseName2), in: databaseClient)
        try? databaseClient.save()

        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId2), position: 0),
            .make(id: ID(testData.courseId1), position: 1)
        ])

        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (courses, _) in
            XCTAssertEqual(courses.first?.id, self.testData.courseId2)
            XCTAssertEqual(courses.last?.id, self.testData.courseId1)
        }
    }

    func test_getCoursesAndGroups_whenPositionsAreEqual_shouldSortCoursesByName() {
        let course1 = Course.save(.make(id: ID(testData.courseId1), name: testData.courseName1), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2), name: testData.courseName2), in: databaseClient)
        try? databaseClient.save()

        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0, shortName: testData.courseName1),
            .make(id: ID(testData.courseId2), position: 0, shortName: testData.courseName2)
        ])

        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (courses, _) in
            XCTAssertEqual(courses.first?.id, self.testData.courseId1)
            XCTAssertEqual(courses.last?.id, self.testData.courseId2)
        }
    }

    func test_getCoursesAndGroups_whenPositionsAndNamesAreEqual_shouldSortCoursesByID() {
        let course1 = Course.save(.make(id: ID(testData.courseId1), name: testData.courseName1), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2), name: testData.courseName2), in: databaseClient)
        try? databaseClient.save()

        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId2), position: 0, shortName: "same name"),
            .make(id: ID(testData.courseId1), position: 0, shortName: "same name")
        ])

        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (courses, _) in
            XCTAssertEqual(courses.first?.id, self.testData.courseId1)
            XCTAssertEqual(courses.last?.id, self.testData.courseId2)
        }
    }

    // MARK: - Course filtering

    func test_getCoursesAndGroups_shouldExcludeCoursesMissingFromDashboardCards() {
        let course1 = Course.save(.make(id: ID(testData.courseId1)), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2)), in: databaseClient)
        try? databaseClient.save()

        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0)
        ])

        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (courses, _) in
            XCTAssertEqual(courses.count, 1)
            XCTAssertEqual(courses.first?.id, self.testData.courseId1)
        }
    }

    // MARK: - Group filtering

    func test_getCoursesAndGroups_shouldFilterInactiveGroups() {
        api.mock(GetFavoriteGroupsRequest(context: .currentUser), value: [
            .make(id: ID(testData.groupId1), name: testData.groupName1, course_id: nil),
            .make(id: ID(testData.groupId2), name: testData.groupName2, course_id: "nonexistent_course_id")
        ])
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { (_, groups) in
            XCTAssertEqual(groups.count, 1)
            XCTAssertEqual(groups.first?.id, self.testData.groupId1)
        }
    }

    // MARK: - reorderCourses

    func test_reorderCourses_whenOrderDiffers_shouldUpdateCardPositions() {
        let course1 = Course.save(.make(id: ID(testData.courseId1)), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2)), in: databaseClient)
        try? databaseClient.save()
        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0),
            .make(id: ID(testData.courseId2), position: 1)
        ])
        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()
        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { _ in }
        api.mock(PutDashboardCardPositions(cards: []))

        testee.reorderCourses(newOrder: [testData.courseId2, testData.courseId1])

        XCTAssertEqual(fetchCard(testData.courseId1)?.position, 1)
        XCTAssertEqual(fetchCard(testData.courseId2)?.position, 0)
    }

    func test_reorderCourses_whenOrderDiffers_shouldSendPutRequest() {
        let course1 = Course.save(.make(id: ID(testData.courseId1)), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2)), in: databaseClient)
        try? databaseClient.save()
        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0),
            .make(id: ID(testData.courseId2), position: 1)
        ])
        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()
        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { _ in }
        let putExpectation = expectation(description: "PUT request sent")
        api.mock(PutDashboardCardPositions(cards: []), expectation: putExpectation)

        testee.reorderCourses(newOrder: [testData.courseId2, testData.courseId1])

        waitForExpectations(timeout: 5)
    }

    func test_reorderCourses_whenOrderIsUnchanged_shouldNotSendPutRequest() {
        let course1 = Course.save(.make(id: ID(testData.courseId1)), in: databaseClient)
        let course2 = Course.save(.make(id: ID(testData.courseId2)), in: databaseClient)
        try? databaseClient.save()
        api.mock(GetDashboardCardsRequest(), value: [
            .make(id: ID(testData.courseId1), position: 0),
            .make(id: ID(testData.courseId2), position: 1)
        ])
        coursesInteractor.mockCoursesResult = .make(allCourses: [course1, course2])
        testee = makeInteractor()
        XCTAssertFirstValue(testee.getCoursesAndGroups(ignoreCache: false), timeout: 5) { _ in }
        let noRequestExpectation = expectation(description: "PUT request should not be sent")
        noRequestExpectation.isInverted = true
        api.mock(PutDashboardCardPositions(cards: []), expectation: noRequestExpectation)

        testee.reorderCourses(newOrder: [testData.courseId1, testData.courseId2])

        waitForExpectations(timeout: 0.5)
    }

    // MARK: - Private helpers

    private func makeInteractor() -> CoursesAndGroupsWidgetInteractorLive {
        CoursesAndGroupsWidgetInteractorLive(
            coursesInteractor: coursesInteractor,
            env: env
        )
    }

    private func setupDefaultAPIMocks() {
        api.mock(GetDashboardCardsRequest(), value: [])
        api.mock(GetFavoriteGroupsRequest(context: .currentUser), value: [])
        api.mock(GetUserSettingsRequest(userID: "self"), value: .make())
    }

    private func fetchCard(_ id: String) -> DashboardCard? {
        databaseClient.fetch(scope: .where(\DashboardCard.id, equals: id, ascending: true)).first
    }
}
