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

final class ConferencesWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        courseId: "course1",
        courseName: "some courseName",
        groupId: "group1",
        groupName: "some groupName",
        conferenceId1: "conf1",
        conferenceTitle1: "some conferenceTitle1",
        conferenceId2: "conf2",
        conferenceTitle2: "some conferenceTitle2"
    )
    private lazy var testData = Self.testData

    private var testee: ConferencesWidgetViewModel!
    private var coursesInteractor: CoursesInteractorMock!
    private var snackBarViewModel: SnackBarViewModel!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        coursesInteractor = CoursesInteractorMock()
        snackBarViewModel = SnackBarViewModel()
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDown() {
        testee = nil
        coursesInteractor = nil
        snackBarViewModel = nil
        subscriptions = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldSetupCorrectly() {
        let config = DashboardWidgetConfig(id: .conferences, order: 42, isVisible: true)
        testee = makeViewModel(config: config)

        XCTAssertEqual(testee.config.id, .conferences)
        XCTAssertEqual(testee.config.order, 42)
        XCTAssertEqual(testee.isFullWidth, true)
        XCTAssertEqual(testee.isEditable, false)
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.conferences.isEmpty, true)
    }

    // MARK: - Refresh with no conferences

    func test_refresh_withNoConferences_shouldSetEmptyState() {
        setupEmptyConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.conferences.isEmpty, true)
    }

    // MARK: - Refresh with conferences

    func test_refresh_withConferences_shouldSetDataState() {
        setupConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.conferences.count, 2)
    }

    func test_refresh_shouldCreateConferenceCardViewModels() {
        setupConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.conferences.first?.id, testData.conferenceId1)
        XCTAssertEqual(testee.conferences.first?.title, testData.conferenceTitle1)
        XCTAssertEqual(testee.conferences.first?.contextName, testData.courseName)
        XCTAssertEqual(testee.conferences.last?.id, testData.conferenceId2)
        XCTAssertEqual(testee.conferences.last?.title, testData.conferenceTitle2)
        XCTAssertEqual(testee.conferences.last?.contextName, testData.groupName)
    }

    func test_refresh_withMissingContext_shouldFilterOutConference() {
        setupConferencesWithMissingContext()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.conferences.count, 1)
        XCTAssertEqual(testee.conferences.first?.id, testData.conferenceId1)
    }

    // MARK: - Widget titles

    func test_widgetTitle_shouldIncludeConferenceCount() {
        setupConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.widgetTitle, "Live Conferences (2)")
    }

    func test_widgetTitle_withNoConferences_shouldShowZeroCount() {
        setupEmptyConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.widgetTitle, "Live Conferences (0)")
    }

    // MARK: - Error handling

    func test_refresh_onError_shouldSetErrorState() {
        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [],
            invitedCourses: [],
            groups: []
        )
        api.mock(GetLiveConferences(), error: NSError.instructureError("Test error"))
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .error)
    }

    // MARK: - Layout identifier

    func test_layoutIdentifier_shouldChangeWithStateAndCount() {
        setupConferences()
        testee = makeViewModel()
        let initialId = testee.layoutIdentifier

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        let afterRefreshId = testee.layoutIdentifier
        XCTAssertNotEqual(initialId, afterRefreshId)
    }

    // MARK: - Conference dismissal

    func test_dismissConference_shouldRemoveFromList() {
        setupConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.conferences.count, 2)

        testee.conferences.first?.dismiss()

        waitUntil(shouldFail: false) {
            self.testee.conferences.count == 1 &&
            self.testee.conferences.first?.id == self.testData.conferenceId2
        }
    }

    func test_dismissConference_whenLastConference_shouldSetEmptyState() {
        setupSingleConference()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .data)

        testee.conferences.first?.dismiss()

        waitUntil(shouldFail: false) {
            self.testee.conferences.isEmpty &&
            self.testee.state == .empty
        }
    }

    func test_dismissConference_shouldPersistIsIgnoredToDatabase() {
        setupSingleConference()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        testee.conferences.first?.dismiss()

        waitUntil(shouldFail: false) {
            let conference: Conference? = self.databaseClient.first(
                where: #keyPath(Conference.id),
                equals: self.testData.conferenceId1
            )
            return conference?.isIgnored == true
        }
    }

    // MARK: - Context resolution

    func test_contextResolution_shouldMatchCourseIds() {
        let course = Course.save(.make(id: ID(testData.courseId), name: testData.courseName), in: databaseClient)
        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [course],
            invitedCourses: [],
            groups: []
        )

        api.mock(GetLiveConferences(), value: .init(conferences: [
            .make(context_id: ID(testData.courseId), context_type: "course", id: testData.conferenceId1, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle1)
        ]))

        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.conferences.count, 1)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        config: DashboardWidgetConfig = DashboardWidgetConfig(id: .conferences, order: 0, isVisible: true)
    ) -> ConferencesWidgetViewModel {
        ConferencesWidgetViewModel(
            config: config,
            interactor: coursesInteractor,
            snackBarViewModel: snackBarViewModel,
            context: databaseClient,
            environment: env
        )
    }

    private func setupEmptyConferences() {
        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [],
            invitedCourses: [],
            groups: []
        )
        api.mock(GetLiveConferences(), value: .init(conferences: []))
    }

    private func setupSingleConference() {
        // Save course to database and set up mock interactor result
        let course = Course.save(.make(id: ID(testData.courseId), name: testData.courseName), in: databaseClient)
        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [course],
            invitedCourses: [],
            groups: []
        )

        api.mock(GetLiveConferences(), value: .init(conferences: [
            .make(context_id: ID(testData.courseId), context_type: "course", id: testData.conferenceId1, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle1)
        ]))
    }

    private func setupConferences() {
        // Save courses and groups to database and set up mock interactor result
        let course = Course.save(.make(id: ID(testData.courseId), name: testData.courseName), in: databaseClient)
        let group = Group.save(.make(id: ID(testData.groupId), name: testData.groupName), in: databaseClient)
        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [course],
            invitedCourses: [],
            groups: [group]
        )

        api.mock(GetLiveConferences(), value: .init(conferences: [
            .make(context_id: ID(testData.courseId), context_type: "course", id: testData.conferenceId1, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle1),
            .make(context_id: ID(testData.groupId), context_type: "group", id: testData.conferenceId2, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle2)
        ]))
    }

    private func setupConferencesWithMissingContext() {
        // Save only one course to database - the other conference context won't be found
        let course = Course.save(.make(id: ID(testData.courseId), name: testData.courseName), in: databaseClient)
        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = CoursesResult(
            allCourses: [course],
            invitedCourses: [],
            groups: []
        )

        api.mock(GetLiveConferences(), value: .init(conferences: [
            .make(context_id: ID(testData.courseId), context_type: "course", id: testData.conferenceId1, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle1),
            .make(context_id: ID("nonexistent-course"), context_type: "course", id: testData.conferenceId2, started_at: Clock.now.addMinutes(-60), title: testData.conferenceTitle2)
        ]))
    }
}
