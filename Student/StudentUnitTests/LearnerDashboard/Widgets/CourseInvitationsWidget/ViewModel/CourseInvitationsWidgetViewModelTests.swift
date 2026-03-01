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
import CombineSchedulers
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class CourseInvitationsWidgetViewModelTests: StudentTestCase {

    private var testee: CourseInvitationsWidgetViewModel!
    private var mockInteractor: CoursesInteractorMock!
    private var snackBarViewModel: SnackBarViewModel!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        mockInteractor = CoursesInteractorMock()
        snackBarViewModel = SnackBarViewModel(scheduler: scheduler.eraseToAnyScheduler())
    }

    override func tearDown() {
        testee = nil
        mockInteractor = nil
        snackBarViewModel = nil
        scheduler = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_stateIsLoading() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        XCTAssertEqual(testee.state, .loading)
    }

    func testInit_invitationsAreEmpty() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        XCTAssertTrue(testee.invitations.isEmpty)
    }

    func testInit_widgetConfigIsCorrect() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        XCTAssertTrue(testee.isFullWidth)
        XCTAssertFalse(testee.isEditable)
    }

    // MARK: - Refresh Success Cases

    func testRefresh_withNoInvitations_stateBecomesEmpty() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        mockInteractor.mockCoursesResult = .make()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .empty)
    }

    func testRefresh_withInvitations_stateBecomesData() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course = makeCourseWithInvitation(
            id: "1",
            name: "Biology 101",
            enrollmentId: "e1",
            sectionId: "s1"
        )
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .data)
    }

    func testRefresh_createsCorrectNumberOfCardViewModels() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course1 = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        let course2 = makeCourseWithInvitation(id: "2", name: "Chemistry 201", enrollmentId: "e2", sectionId: "s2")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course1, course2],
            invitedCourses: [course1, course2]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.invitations.count, 2)
    }

    func testRefresh_cardViewModelsHaveCorrectProperties() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let section = makeSection(id: "s1", name: "Section A")
        let course = makeCourseWithInvitation(
            id: "1",
            name: "Biology 101",
            enrollmentId: "e1",
            sectionId: "s1",
            sections: [section]
        )
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.invitations.first?.id, "e1")
        XCTAssertEqual(testee.invitations.first?.displayName, "Biology 101, Section A")
    }

    func testRefresh_passesIgnoreCacheParameter() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        mockInteractor.mockCoursesResult = .make()

        XCTAssertFinish(testee.refresh(ignoreCache: true), timeout: 5)
    }

    // MARK: - Refresh Filtering

    func testRefresh_onlyIncludesCoursesWithInvitedEnrollments() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let invitedCourse = makeCourseWithInvitation(
            id: "1",
            name: "Biology 101",
            enrollmentId: "e1",
            sectionId: "s1"
        )
        let activeCourse = makeCourse(id: "2", name: "Chemistry 201")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [invitedCourse, activeCourse],
            invitedCourses: [invitedCourse]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.invitations.count, 1)
        XCTAssertEqual(testee.invitations.first?.displayName, "Biology 101")
    }

    func testRefresh_skipsEnrollmentsWithoutIds() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let courseWithoutEnrollmentId = makeCourseWithInvitation(
            id: "1",
            name: "Biology 101",
            enrollmentId: nil,
            sectionId: "s1"
        )
        mockInteractor.mockCoursesResult = .make(
            allCourses: [courseWithoutEnrollmentId],
            invitedCourses: [courseWithoutEnrollmentId]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertTrue(testee.invitations.isEmpty)
        XCTAssertEqual(testee.state, .empty)
    }

    func testRefresh_mapsSectionNameFromCourseSectionID() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let section = makeSection(id: "s1", name: "Advanced Section")
        let course = makeCourseWithInvitation(
            id: "1",
            name: "Biology 101",
            enrollmentId: "e1",
            sectionId: "s1",
            sections: [section]
        )
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.invitations.first?.displayName, "Biology 101, Advanced Section")
    }

    // MARK: - Refresh Failure

    func testRefresh_onError_stateBecomesError() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        mockInteractor.mockCoursesResult = .make()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
    }

    // MARK: - Titles

    func testTitle_showsCorrectCount() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course1 = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        let course2 = makeCourseWithInvitation(id: "2", name: "Chemistry 201", enrollmentId: "e2", sectionId: "s2")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course1, course2],
            invitedCourses: [course1, course2]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.widgetTitle, "Course Invitations (2)")
    }

    func testAccessibilityTitle_includesFormattedCount() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertTrue(testee.widgetAccessibilityTitle.contains("Course Invitations"))
        XCTAssertTrue(testee.widgetAccessibilityTitle.contains("1"))
    }

    // MARK: - Invitation Removal

    func testRemoveInvitation_removesFromList() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course1 = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        let course2 = makeCourseWithInvitation(id: "2", name: "Chemistry 201", enrollmentId: "e2", sectionId: "s2")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course1, course2],
            invitedCourses: [course1, course2]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.invitations.count, 2)

        let removalExpectation = self.expectation(description: "removal")
        testee.invitations.first?.accept()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            removalExpectation.fulfill()
        }
        wait(for: [removalExpectation], timeout: 3)

        XCTAssertEqual(testee.invitations.count, 1)
        XCTAssertEqual(testee.invitations.first?.displayName, "Chemistry 201")
    }

    func testRemoveInvitation_lastRemoval_stateBecomesEmpty() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .data)

        let removalExpectation = self.expectation(description: "removal")
        testee.invitations.first?.accept()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            removalExpectation.fulfill()
        }
        wait(for: [removalExpectation], timeout: 3)

        XCTAssertTrue(testee.invitations.isEmpty)
        XCTAssertEqual(testee.state, .empty)
    }

    func testRemoveInvitation_nonLastRemoval_stateStaysData() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let course1 = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        let course2 = makeCourseWithInvitation(id: "2", name: "Chemistry 201", enrollmentId: "e2", sectionId: "s2")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course1, course2],
            invitedCourses: [course1, course2]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        testee.invitations.first?.accept()
        scheduler.advance(by: .seconds(3))

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Layout Identifier

    func testLayoutIdentifier_changesWithStateAndCount() {
        let config = DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true)
        testee = CourseInvitationsWidgetViewModel(
            config: config,
            interactor: mockInteractor,
            snackBarViewModel: snackBarViewModel
        )

        let initialId = testee.layoutIdentifier

        let course = makeCourseWithInvitation(id: "1", name: "Biology 101", enrollmentId: "e1", sectionId: "s1")
        mockInteractor.mockCoursesResult = .make(
            allCourses: [course],
            invitedCourses: [course]
        )

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        let afterRefreshId = testee.layoutIdentifier
        XCTAssertNotEqual(initialId, afterRefreshId)
    }

    // MARK: - Test Helpers

    private func makeCourse(id: String, name: String) -> Course {
        let course: Course = databaseClient.insert()
        course.id = id
        course.name = name

        try? databaseClient.save()
        return course
    }

    private func makeCourseWithInvitation(
        id: String,
        name: String,
        enrollmentId: String?,
        sectionId: String,
        sections: [CourseSection] = []
    ) -> Course {
        let course: Course = databaseClient.insert()
        course.id = id
        course.name = name
        course.sections = Set(sections)

        let enrollment: Enrollment = databaseClient.insert()
        enrollment.id = enrollmentId
        enrollment.state = .invited
        enrollment.courseSectionID = sectionId
        enrollment.course = course

        try? databaseClient.save()
        return course
    }

    private func makeSection(id: String, name: String) -> CourseSection {
        let section: CourseSection = databaseClient.insert()
        section.id = id
        section.name = name

        try? databaseClient.save()
        return section
    }
}
